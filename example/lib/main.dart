import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:camera/camera.dart';
import 'byte_tracker.dart';

late List<CameraDescription> cameras;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Barbell Path Tracking',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Barbell Path Camera'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.fitness_center, size: 80, color: Colors.blue),
            const SizedBox(height: 24),
            const Text(
              '바벨 패스 트래킹',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'YOLOv8 + ByteTrack 실시간 바벨 트래킹',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 48),
            ElevatedButton.icon(
              onPressed: () => _startTracking(context),
              icon: const Icon(Icons.play_arrow),
              label: const Text('트래킹 시작'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _startTracking(BuildContext context) async {
    final status = await Permission.camera.request();
    if (status.isDenied) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('카메라 권한이 필요합니다')),
        );
      }
      return;
    }

    if (context.mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const TrackingPage()),
      );
    }
  }
}

/// Exercise type for scale configuration
enum ExerciseType {
  squat('스쿼트'),
  benchPress('벤치프레스'),
  overheadPress('오버헤드프레스'),
  custom('커스텀');

  final String label;
  const ExerciseType(this.label);

  ScaleConfig get defaultConfig {
    switch (this) {
      case ExerciseType.squat:
        return ScaleConfig.squat;
      case ExerciseType.benchPress:
        return ScaleConfig.benchPress;
      case ExerciseType.overheadPress:
        return ScaleConfig.overheadPress;
      case ExerciseType.custom:
        return ScaleConfig.uncalibrated;
    }
  }
}

class TrackingPage extends StatefulWidget {
  const TrackingPage({super.key});

  @override
  State<TrackingPage> createState() => _TrackingPageState();
}

class _TrackingPageState extends State<TrackingPage> {
  CameraController? _cameraController;
  bool _isInitialized = false;

  // Native CoreML channel
  static const _channel = MethodChannel('barbell_detector');

  // Exercise type and scale config
  ExerciseType _exerciseType = ExerciseType.squat;
  ScaleConfig? _customScaleConfig;
  ScaleConfig get _scaleConfig => _customScaleConfig ?? _exerciseType.defaultConfig;

  // Calibration state
  bool _isCalibrating = false;
  double? _lastDetectedWidth; // For plate-based calibration

  // ByteTrackers with enhanced settings
  late ByteTracker _leftTracker;
  late ByteTracker _rightTracker;

  int _frameCount = 0;
  int _detectionCount = 0;
  bool _isTracking = false;
  bool _isProcessing = false;
  int _frameSkip = 0;
  int _currentFrameSkip = 0;
  int _currentSetNumber = 0;

  List<Rect> _currentBoxes = [];
  TrackResult? _leftTrackResult;
  TrackResult? _rightTrackResult;

  // Path visualization settings
  Color _leftPathColor = Colors.cyan;
  Color _rightPathColor = Colors.orange;
  bool _showPredictedPath = true;
  bool _showExerciseStats = true;
  bool _showVelocityZone = false; // 속도 표시 비활성화
  bool _audioFeedback = false;

  @override
  void initState() {
    super.initState();
    _initTrackers();
    _initCamera();
  }

  void _initTrackers() {
    _leftTracker = ByteTracker(
      highConfThreshold: 0.5,
      lowConfThreshold: 0.1,
      distanceThreshold: 0.2,
      maxPredictionFrames: 15,
      maxPredictionDistance: 0.2,
      predictionConfidenceDecay: 0.9,
      smoothingWindow: 3,
      minRepAmplitude: 0.08,
      scaleConfig: _scaleConfig,
    );
    _rightTracker = ByteTracker(
      highConfThreshold: 0.5,
      lowConfThreshold: 0.1,
      distanceThreshold: 0.2,
      maxPredictionFrames: 15,
      maxPredictionDistance: 0.2,
      predictionConfidenceDecay: 0.9,
      smoothingWindow: 3,
      minRepAmplitude: 0.08,
      scaleConfig: _scaleConfig,
    );
  }

  void _updateScaleConfig() {
    _leftTracker.scaleConfig = _scaleConfig;
    _rightTracker.scaleConfig = _scaleConfig;
  }

  Future<void> _initCamera() async {
    if (cameras.isEmpty) return;

    final backCamera = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );

    _cameraController = CameraController(
      backCamera,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.bgra8888,
    );

    await _cameraController!.initialize();
    await _cameraController!.startImageStream(_processImage);

    if (mounted) {
      setState(() => _isInitialized = true);
    }
  }

  Future<void> _processImage(CameraImage image) async {
    if (_isProcessing || !_isTracking) return;

    if (_frameSkip > 0) {
      _currentFrameSkip++;
      if (_currentFrameSkip < _frameSkip) {
        return;
      }
      _currentFrameSkip = 0;
    }

    _isProcessing = true;
    _frameCount++;

    try {
      final result = await _channel.invokeMethod('detectBarbell', {
        'width': image.width,
        'height': image.height,
        'planes': image.planes.map((p) {
          return {
            'bytes': p.bytes,
            'bytesPerRow': p.bytesPerRow,
          };
        }).toList(),
      });

      if (result != null && result is List) {
        final detections = <Detection>[];
        final boxes = <Rect>[];

        for (final det in result) {
          final x = (det['x'] as num).toDouble();
          final y = (det['y'] as num).toDouble();
          final w = (det['width'] as num).toDouble();
          final h = (det['height'] as num).toDouble();
          final conf = (det['confidence'] as num).toDouble();

          detections.add(Detection(
            x: x,
            y: y,
            width: w,
            height: h,
            confidence: conf,
          ));

          boxes.add(Rect.fromCenter(
            center: Offset(x, y),
            width: w,
            height: h,
          ));
        }

        if (detections.isNotEmpty) {
          _detectionCount++;
          // Track detected width for calibration
          _lastDetectedWidth = detections.first.width;
          _updateTrackers(detections);
        } else {
          _updateTrackers([]);
        }

        if (mounted) {
          setState(() {
            _currentBoxes = boxes;
          });
        }
      }
    } catch (e) {
      debugPrint('Detection error: $e');
    }

    _isProcessing = false;
  }

  void _updateTrackers(List<Detection> detections) {
    final prevLeftRepCount = _leftTrackResult?.exerciseStats.repCount ?? 0;
    final prevRightRepCount = _rightTrackResult?.exerciseStats.repCount ?? 0;

    if (detections.isEmpty) {
      _leftTrackResult = _leftTracker.update([]);
      _rightTrackResult = _rightTracker.update([]);
      if (mounted) setState(() {});
      return;
    }

    detections.sort((a, b) => a.x.compareTo(b.x));

    final leftDetections = detections.isNotEmpty ? [detections.first] : <Detection>[];
    final rightDetections = detections.length >= 2 ? [detections.last] : <Detection>[];

    _leftTrackResult = _leftTracker.update(leftDetections);
    _rightTrackResult = _rightTracker.update(rightDetections);

    // Audio feedback on rep completion
    if (_audioFeedback) {
      final newLeftRepCount = _leftTrackResult?.exerciseStats.repCount ?? 0;
      final newRightRepCount = _rightTrackResult?.exerciseStats.repCount ?? 0;
      if (newLeftRepCount > prevLeftRepCount || newRightRepCount > prevRightRepCount) {
        HapticFeedback.mediumImpact();
      }
    }

    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _cameraController?.stopImageStream();
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera preview
          if (_isInitialized && _cameraController != null)
            Positioned.fill(
              child: CameraPreview(_cameraController!),
            )
          else
            const Center(child: CircularProgressIndicator(color: Colors.white)),

          // Bounding boxes
          if (_currentBoxes.isNotEmpty)
            Positioned.fill(
              child: CustomPaint(
                painter: BoundingBoxPainter(boxes: _currentBoxes),
              ),
            ),

          // Path overlay
          if (_isTracking)
            Positioned.fill(
              child: CustomPaint(
                painter: EnhancedPathPainter(
                  leftResult: _leftTrackResult,
                  rightResult: _rightTrackResult,
                  leftColor: _leftPathColor,
                  rightColor: _rightPathColor,
                  showPredicted: _showPredictedPath,
                  showVelocityZone: _showVelocityZone,
                ),
              ),
            ),

          // Top bar
          _buildTopBar(),

          // Info panel (right)
          _buildInfoPanel(),

          // Exercise stats panel (left)
          if (_showExerciseStats) _buildExerciseStatsPanel(),

          // Velocity zone legend
          if (_showVelocityZone && _isTracking) _buildVelocityZoneLegend(),

          // Bottom controls
          _buildBottomControls(),

          // Settings button
          _buildSettingsButton(),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 8,
      left: 16,
      right: 16,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: _isTracking ? Colors.green : Colors.orange,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _isTracking
                      ? '${_exerciseType.label} SET $_currentSetNumber'
                      : _exerciseType.label,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildInfoPanel() {
    return Positioned(
      right: 16,
      top: MediaQuery.of(context).padding.top + 60,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('프레임: $_frameCount',
                style: const TextStyle(color: Colors.white70, fontSize: 11)),
            Text('감지: $_detectionCount',
                style: const TextStyle(color: Colors.white70, fontSize: 11)),
            const Divider(color: Colors.white24, height: 12),
            _buildTrackInfo('L', _leftTrackResult, _leftPathColor),
            const SizedBox(height: 4),
            _buildTrackInfo('R', _rightTrackResult, _rightPathColor),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackInfo(String label, TrackResult? result, Color color) {
    if (result == null || !result.hasTrack) {
      return Text('$label: -',
          style: TextStyle(color: color.withAlpha(128), fontSize: 11));
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$label: ',
            style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
        Text(result.isDetected ? '감지' : '예측',
            style: TextStyle(color: color.withAlpha(180), fontSize: 10)),
        Text(' (${result.path.length}pts)',
            style: TextStyle(color: color.withAlpha(150), fontSize: 9)),
      ],
    );
  }

  Widget _buildExerciseStatsPanel() {
    final leftStats = _leftTrackResult?.exerciseStats;
    final rightStats = _rightTrackResult?.exerciseStats;

    final repCount = (leftStats?.repCount ?? 0) > (rightStats?.repCount ?? 0)
        ? leftStats?.repCount ?? 0
        : rightStats?.repCount ?? 0;

    final stats = leftStats ?? ExerciseStats.empty();

    return Positioned(
      left: 16,
      top: MediaQuery.of(context).padding.top + 60,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Rep count with set info
            Row(
              children: [
                const Icon(Icons.fitness_center, color: Colors.white, size: 16),
                const SizedBox(width: 8),
                Text(
                  'REP $repCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Phase indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _getPhaseColor(stats.phase).withAlpha(80),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _phaseToString(stats.phase),
                style: TextStyle(
                  color: _getPhaseColor(stats.phase),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            if (stats.lastRepDuration != null) ...[
              const SizedBox(height: 8),
              _buildStatRow('마지막', '${stats.lastRepDuration!.toStringAsFixed(2)} s'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 50,
            child: Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10)),
          ),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildVelocityZoneLegend() {
    return Positioned(
      left: 16,
      bottom: 100 + MediaQuery.of(context).padding.bottom,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('VBT 존', style: TextStyle(color: Colors.white70, fontSize: 10)),
            const SizedBox(height: 4),
            _buildZoneRow(VelocityZone.speed, '> 1.3', 'Speed'),
            _buildZoneRow(VelocityZone.speedStrength, '1.0-1.3', 'Speed-Str'),
            _buildZoneRow(VelocityZone.power, '0.75-1.0', 'Power'),
            _buildZoneRow(VelocityZone.strengthSpeed, '0.5-0.75', 'Str-Speed'),
            _buildZoneRow(VelocityZone.strength, '< 0.5', 'Strength'),
          ],
        ),
      ),
    );
  }

  Widget _buildZoneRow(VelocityZone zone, String range, String label) {
    final color = _getVelocityZoneColor(zone);
    final currentZone = _leftTrackResult?.velocityZone ?? VelocityZone.strength;
    final isActive = currentZone == zone && _leftTrackResult?.hasTrack == true;

    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: isActive ? color : color.withAlpha(100),
              shape: BoxShape.circle,
              border: isActive ? Border.all(color: Colors.white, width: 1) : null,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            range,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.white54,
              fontSize: 9,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Color _getVelocityZoneColor(VelocityZone zone) {
    switch (zone) {
      case VelocityZone.speed:
        return Colors.red;
      case VelocityZone.speedStrength:
        return Colors.orange;
      case VelocityZone.power:
        return Colors.yellow;
      case VelocityZone.strengthSpeed:
        return Colors.lightGreen;
      case VelocityZone.strength:
        return Colors.blue;
    }
  }

  Color _getPhaseColor(MovementPhase phase) {
    switch (phase) {
      case MovementPhase.idle:
        return Colors.grey;
      case MovementPhase.ascending:
        return Colors.green;
      case MovementPhase.descending:
        return Colors.orange;
      case MovementPhase.atTop:
        return Colors.cyan;
      case MovementPhase.atBottom:
        return Colors.purple;
    }
  }

  String _phaseToString(MovementPhase phase) {
    switch (phase) {
      case MovementPhase.idle:
        return '정지';
      case MovementPhase.ascending:
        return '상승 (컨센트릭)';
      case MovementPhase.descending:
        return '하강 (이센트릭)';
      case MovementPhase.atTop:
        return '최고점';
      case MovementPhase.atBottom:
        return '최저점';
    }
  }

  Widget _buildSettingsButton() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 8,
      right: 16,
      child: IconButton(
        onPressed: _showSettingsDialog,
        icon: const Icon(Icons.settings, color: Colors.white),
      ),
    );
  }

  void _showSettingsDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('설정', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),

              // Exercise type
              const Text('운동 종류', style: TextStyle(color: Colors.white70, fontSize: 12)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: ExerciseType.values.map((type) {
                  final isSelected = _exerciseType == type;
                  return ChoiceChip(
                    label: Text(type.label),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _exerciseType = type;
                          _updateScaleConfig();
                        });
                        setModalState(() {});
                      }
                    },
                    selectedColor: Colors.blue,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.white70,
                    ),
                    backgroundColor: Colors.grey[800],
                  );
                }).toList(),
              ),
              const SizedBox(height: 8),
              Text(
                _scaleConfig.isCalibrated
                    ? '캘리브레이션: ${_scaleConfig.calibrationReference}'
                    : '캘리브레이션: 미설정 (추정값)',
                style: const TextStyle(color: Colors.white54, fontSize: 10),
              ),
              const SizedBox(height: 16),

              // Frame skip
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('프레임 스킵', style: TextStyle(color: Colors.white70)),
                  DropdownButton<int>(
                    value: _frameSkip,
                    dropdownColor: Colors.grey[800],
                    items: [0, 1, 2, 3].map((v) => DropdownMenuItem(
                      value: v,
                      child: Text(v == 0 ? '없음' : '$v', style: const TextStyle(color: Colors.white)),
                    )).toList(),
                    onChanged: (v) {
                      setState(() => _frameSkip = v ?? 0);
                      setModalState(() {});
                    },
                  ),
                ],
              ),

              // Toggles
              SwitchListTile(
                title: const Text('예측 패스 표시', style: TextStyle(color: Colors.white70)),
                value: _showPredictedPath,
                onChanged: (v) {
                  setState(() => _showPredictedPath = v);
                  setModalState(() {});
                },
                contentPadding: EdgeInsets.zero,
              ),
              SwitchListTile(
                title: const Text('운동 통계 표시', style: TextStyle(color: Colors.white70)),
                value: _showExerciseStats,
                onChanged: (v) {
                  setState(() => _showExerciseStats = v);
                  setModalState(() {});
                },
                contentPadding: EdgeInsets.zero,
              ),
              SwitchListTile(
                title: const Text('VBT 존 표시', style: TextStyle(color: Colors.white70)),
                value: _showVelocityZone,
                onChanged: (v) {
                  setState(() => _showVelocityZone = v);
                  setModalState(() {});
                },
                contentPadding: EdgeInsets.zero,
              ),
              SwitchListTile(
                title: const Text('Rep 완료 시 진동', style: TextStyle(color: Colors.white70)),
                value: _audioFeedback,
                onChanged: (v) {
                  setState(() => _audioFeedback = v);
                  setModalState(() {});
                },
                contentPadding: EdgeInsets.zero,
              ),

              // Path colors
              const SizedBox(height: 8),
              const Text('패스 색상', style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text('왼쪽: ', style: TextStyle(color: Colors.white54, fontSize: 12)),
                  ...([Colors.cyan, Colors.blue, Colors.green, Colors.purple]).map((c) =>
                    GestureDetector(
                      onTap: () {
                        setState(() => _leftPathColor = c);
                        setModalState(() {});
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: c,
                          shape: BoxShape.circle,
                          border: _leftPathColor == c
                              ? Border.all(color: Colors.white, width: 2)
                              : null,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text('오른쪽: ', style: TextStyle(color: Colors.white54, fontSize: 12)),
                  ...([Colors.orange, Colors.red, Colors.yellow, Colors.pink]).map((c) =>
                    GestureDetector(
                      onTap: () {
                        setState(() => _rightPathColor = c);
                        setModalState(() {});
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: c,
                          shape: BoxShape.circle,
                          border: _rightPathColor == c
                              ? Border.all(color: Colors.white, width: 2)
                              : null,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    return Positioned(
      bottom: 24 + MediaQuery.of(context).padding.bottom,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (!_isTracking)
            ElevatedButton.icon(
              onPressed: () => setState(() {
                _isTracking = true;
                _currentSetNumber++;
                _leftTracker.startNewSet();
                _rightTracker.startNewSet();
                _frameCount = 0;
                _detectionCount = 0;
              }),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.play_arrow),
              label: Text('SET $_currentSetNumber 시작'),
            ),
          if (_isTracking) ...[
            ElevatedButton.icon(
              onPressed: () => setState(() {
                _isTracking = false;
                _leftTracker.finishSet();
                _rightTracker.finishSet();
              }),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.stop),
              label: const Text('정지'),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: () => setState(() {
                _leftTracker.clearPath();
                _rightTracker.clearPath();
              }),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.refresh),
              label: const Text('패스'),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: () => setState(() {
                _currentSetNumber++;
                _leftTracker.startNewSet();
                _rightTracker.startNewSet();
              }),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.add),
              label: const Text('새 SET'),
            ),
          ],
        ],
      ),
    );
  }
}

class BoundingBoxPainter extends CustomPainter {
  final List<Rect> boxes;

  BoundingBoxPainter({required this.boxes});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.greenAccent
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    for (final box in boxes) {
      final rect = Rect.fromLTRB(
        box.left * size.width,
        box.top * size.height,
        box.right * size.width,
        box.bottom * size.height,
      );
      canvas.drawRect(rect, paint);

      final center = rect.center;
      canvas.drawCircle(center, 6, Paint()..color = Colors.red);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class EnhancedPathPainter extends CustomPainter {
  final TrackResult? leftResult;
  final TrackResult? rightResult;
  final Color leftColor;
  final Color rightColor;
  final bool showPredicted;
  final bool showVelocityZone;

  EnhancedPathPainter({
    this.leftResult,
    this.rightResult,
    this.leftColor = Colors.cyan,
    this.rightColor = Colors.orange,
    this.showPredicted = true,
    this.showVelocityZone = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (leftResult != null && leftResult!.hasTrack) {
      _drawPath(canvas, size, leftResult!, leftColor);
    }
    if (rightResult != null && rightResult!.hasTrack) {
      _drawPath(canvas, size, rightResult!, rightColor);
    }
  }

  void _drawPath(Canvas canvas, Size size, TrackResult result, Color baseColor) {
    final path = result.path;
    if (path.length < 2) return;

    final detectedPaint = Paint()
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final predictedPaint = Paint()
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    for (int i = 1; i < path.length; i++) {
      final start = Offset(path[i - 1].x * size.width, path[i - 1].y * size.height);
      final end = Offset(path[i].x * size.width, path[i].y * size.height);
      final opacity = (i / path.length).clamp(0.2, 1.0);
      final isPredicted = path[i].isPredicted || path[i - 1].isPredicted;

      if (isPredicted) {
        if (!showPredicted) continue;
        predictedPaint.color = baseColor.withAlpha((opacity * 0.5 * 255).toInt());
        _drawDashedLine(canvas, start, end, predictedPaint);
      } else {
        detectedPaint.color = baseColor.withAlpha((opacity * 255).toInt());
        canvas.drawLine(start, end, detectedPaint);
      }
    }

    // Current position
    final current = Offset(result.x * size.width, result.y * size.height);

    // Outer glow
    canvas.drawCircle(current, 20, Paint()..color = baseColor.withAlpha(38));
    canvas.drawCircle(current, 15, Paint()..color = baseColor.withAlpha(77));

    // Main circle
    final isDetected = result.isDetected;
    canvas.drawCircle(current, 12, Paint()
      ..color = isDetected ? baseColor : baseColor.withAlpha(128)
      ..style = isDetected ? PaintingStyle.fill : PaintingStyle.stroke
      ..strokeWidth = 2);

    if (isDetected) {
      canvas.drawCircle(current, 4, Paint()..color = Colors.white);
    }
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    const dashLength = 5.0;
    const gapLength = 3.0;

    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final len = (dx.abs() > dy.abs() ? dx.abs() : dy.abs());
    if (len <= 0) return;

    final unitX = dx / len;
    final unitY = dy / len;

    var currentX = start.dx;
    var currentY = start.dy;
    var drawn = 0.0;

    while (drawn < len) {
      final dashEnd = (drawn + dashLength).clamp(0.0, len);
      final endX = start.dx + unitX * dashEnd;
      final endY = start.dy + unitY * dashEnd;

      canvas.drawLine(
        Offset(currentX, currentY),
        Offset(endX, endY),
        paint,
      );

      drawn += dashLength + gapLength;
      currentX = start.dx + unitX * drawn.clamp(0.0, len);
      currentY = start.dy + unitY * drawn.clamp(0.0, len);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
