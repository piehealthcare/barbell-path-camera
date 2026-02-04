import 'dart:math';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:point_barbell_path/core/l10n/generated/app_localizations.dart';
import 'package:barbell_tracking/barbell_tracking.dart';

import '../../core/router/app_router.dart';
import '../../core/utils/exercise_utils.dart';
import '../recording/service/recording_service.dart';
import 'service/platform_ml_service.dart';
import 'widgets/tracking_controls.dart';

class TrackingScreen extends ConsumerStatefulWidget {
  final String exerciseType;

  const TrackingScreen({super.key, required this.exerciseType});

  @override
  ConsumerState<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends ConsumerState<TrackingScreen>
    with WidgetsBindingObserver {
  CameraController? _cameraController;
  late final PlatformMLService _mlService;
  final RecordingService _recordingService = RecordingService();

  // Dual ByteTrackers like the working example
  late ByteTracker _leftTracker;
  late ByteTracker _rightTracker;

  bool _isInitialized = false;
  bool _isInitializing = false;
  bool _isTracking = false;
  bool _isProcessingFrame = false;
  int _frameCount = 0;
  final int _frameSkip = 0;
  int _currentSetNumber = 0;
  String? _recordedVideoPath;

  // Detection results
  List<Rect> _currentBoxes = [];
  TrackResult? _leftTrackResult;
  TrackResult? _rightTrackResult;

  late ScaleConfig _scaleConfig;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    final exerciseType = _parseExerciseType(widget.exerciseType);
    _scaleConfig = exerciseType.defaultScaleConfig;
    _initTrackers();
    _mlService = PlatformMLService();
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

  ExerciseType _parseExerciseType(String type) {
    switch (type) {
      case 'squat':
        return ExerciseType.squat;
      case 'benchPress':
        return ExerciseType.benchPress;
      case 'deadlift':
        return ExerciseType.deadlift;
      case 'overheadPress':
        return ExerciseType.overheadPress;
      default:
        return ExerciseType.custom;
    }
  }

  Future<void> _initCamera() async {
    if (_isInitializing) return;
    _isInitializing = true;

    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty || !mounted) return;

      final camera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.bgra8888,
      );

      await _cameraController!.initialize();
      await _mlService.initialize();

      // Start image stream immediately (like the working example)
      await _cameraController!.startImageStream(_onCameraFrame);

      if (mounted) {
        setState(() => _isInitialized = true);
      }
    } catch (e) {
      debugPrint('Camera init error: $e');
    } finally {
      _isInitializing = false;
    }
  }

  void _startTracking() {
    if (!_isInitialized) return;

    _currentSetNumber++;
    _leftTracker.startNewSet();
    _rightTracker.startNewSet();
    _frameCount = 0;

    _recordingService.startRecording(
      width: 1280,
      height: 720,
      fps: 30,
      bitrate: 4000000,
    );

    setState(() => _isTracking = true);
  }

  Future<void> _stopTracking() async {
    _leftTracker.finishSet();
    _rightTracker.finishSet();
    _recordedVideoPath = await _recordingService.stopRecording();
    setState(() => _isTracking = false);
  }

  void _newSet() {
    _currentSetNumber++;
    _leftTracker.startNewSet();
    _rightTracker.startNewSet();
    setState(() {});
  }

  Future<void> _finishSession() async {
    if (_isTracking) await _stopTracking();

    // Use left tracker stats (typically the primary tracker)
    final stats = _leftTrackResult?.exerciseStats ?? ExerciseStats.empty();

    if (!mounted) return;

    final avgVelocity = stats.repHistory.isNotEmpty
        ? stats.repHistory
                .map((r) => r.meanVelocity)
                .reduce((a, b) => a + b) /
            stats.repHistory.length
        : 0.0;
    final peakVelocity = stats.repHistory.isNotEmpty
        ? stats.repHistory
            .map((r) => r.peakVelocity)
            .reduce((a, b) => a > b ? a : b)
        : 0.0;

    context.pushReplacement(AppRoutes.review, extra: {
      'exerciseType': widget.exerciseType,
      'totalReps': stats.repCount,
      'totalSets': _currentSetNumber,
      'avgVelocity': avgVelocity,
      'peakVelocity': peakVelocity,
      if (_recordedVideoPath != null) 'videoPath': _recordedVideoPath,
    });
  }

  Future<void> _onCameraFrame(CameraImage image) async {
    if (_isProcessingFrame || !_isTracking) return;

    if (_frameSkip > 0) {
      _frameCount++;
      if (_frameCount % (_frameSkip + 1) != 0) return;
    }

    _isProcessingFrame = true;
    _frameCount++;

    try {
      final detections = await _mlService.detectBarbell(image);

      if (!mounted) {
        _isProcessingFrame = false;
        return;
      }

      final boxes = <Rect>[];
      for (final det in detections) {
        boxes.add(Rect.fromCenter(
          center: Offset(det.x, det.y),
          width: det.width,
          height: det.height,
        ));
      }

      _updateTrackers(detections);

      if (_recordingService.isRecording && image.planes.isNotEmpty) {
        _recordingService.addFrame(
          cameraFrame: image.planes[0].bytes,
          width: image.width,
          height: image.height,
        );
      }

      if (mounted) {
        setState(() {
          _currentBoxes = boxes;
        });
      }
    } catch (e) {
      debugPrint('Detection error: $e');
    }

    _isProcessingFrame = false;
  }

  void _updateTrackers(List<Detection> detections) {
    final prevLeftRepCount =
        _leftTrackResult?.exerciseStats.repCount ?? 0;
    final prevRightRepCount =
        _rightTrackResult?.exerciseStats.repCount ?? 0;

    if (detections.isEmpty) {
      _leftTrackResult = _leftTracker.update([]);
      _rightTrackResult = _rightTracker.update([]);
      if (mounted) setState(() {});
      return;
    }

    // Sort detections by x position, split into left/right
    detections.sort((a, b) => a.x.compareTo(b.x));

    final leftDetections = [detections.first];
    final rightDetections =
        detections.length >= 2 ? [detections.last] : <Detection>[];

    _leftTrackResult = _leftTracker.update(leftDetections);
    _rightTrackResult = _rightTracker.update(rightDetections);

    // Haptic feedback on rep completion
    final newLeftRepCount =
        _leftTrackResult?.exerciseStats.repCount ?? 0;
    final newRightRepCount =
        _rightTrackResult?.exerciseStats.repCount ?? 0;
    if (newLeftRepCount > prevLeftRepCount ||
        newRightRepCount > prevRightRepCount) {
      HapticFeedback.mediumImpact();
    }

    if (mounted) setState(() {});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_cameraController == null ||
        !_cameraController!.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      if (_isTracking) _stopTracking();
      _cameraController?.dispose();
      _cameraController = null;
      setState(() => _isInitialized = false);
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.stopImageStream().catchError((_) {});
    _cameraController?.dispose();
    _mlService.dispose();
    _recordingService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final leftStats = _leftTrackResult?.exerciseStats;
    final rightStats = _rightTrackResult?.exerciseStats;
    final repCount =
        (leftStats?.repCount ?? 0) > (rightStats?.repCount ?? 0)
            ? leftStats?.repCount ?? 0
            : rightStats?.repCount ?? 0;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera preview (fill entire screen)
          if (_isInitialized && _cameraController != null)
            Positioned.fill(
              child: CameraPreview(_cameraController!),
            )
          else
            const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),

          // Bounding boxes (always visible when detections exist)
          if (_currentBoxes.isNotEmpty)
            Positioned.fill(
              child: CustomPaint(
                painter: _BoundingBoxPainter(boxes: _currentBoxes),
              ),
            ),

          // Path overlay (only when tracking)
          if (_isTracking)
            Positioned.fill(
              child: CustomPaint(
                painter: _DualPathPainter(
                  leftResult: _leftTrackResult,
                  rightResult: _rightTrackResult,
                ),
              ),
            ),

          // Top bar
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            right: 16,
            child: Row(
              children: [
                IconButton(
                  icon:
                      const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    if (_isTracking) _stopTracking();
                    context.pop();
                  },
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
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
                          color:
                              _isTracking ? Colors.green : Colors.orange,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isTracking
                            ? '${ExerciseUtils.displayName(widget.exerciseType, l10n)} SET $_currentSetNumber'
                            : ExerciseUtils.displayName(
                                widget.exerciseType, l10n),
                        style: const TextStyle(
                            color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),

          // Exercise stats panel (left side, like the example)
          if (_isTracking)
            Positioned(
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
                    Row(
                      children: [
                        const Icon(Icons.fitness_center,
                            color: Colors.white, size: 16),
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
                    if (leftStats != null)
                      _PhaseIndicator(phase: leftStats.phase),
                    if (leftStats?.lastRepDuration != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        '${l10n.rom}: ${leftStats!.lastRepDuration!.toStringAsFixed(2)}s',
                        style: const TextStyle(
                            color: Colors.white54, fontSize: 11),
                      ),
                    ],
                    const SizedBox(height: 8),
                    // Path consistency gauge
                    _PathConsistencyGauge(
                      leftResult: _leftTrackResult,
                      rightResult: _rightTrackResult,
                    ),
                  ],
                ),
              ),
            ),

          // Detection info panel (right side)
          if (_isTracking)
            Positioned(
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
                    Text('Frame: $_frameCount',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 11)),
                    const Divider(color: Colors.white24, height: 12),
                    _TrackInfo(
                        label: 'L',
                        result: _leftTrackResult,
                        color: Colors.cyan),
                    const SizedBox(height: 4),
                    _TrackInfo(
                        label: 'R',
                        result: _rightTrackResult,
                        color: Colors.orange),
                  ],
                ),
              ),
            ),

          // Speed color legend (shown when tracking)
          if (_isTracking)
            Positioned(
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
                    const Text('SPEED',
                        style: TextStyle(
                            color: Colors.white70,
                            fontSize: 9,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    _buildSpeedLegendRow(Colors.blue, 'FAST'),
                    _buildSpeedLegendRow(Colors.cyan, 'QUICK'),
                    _buildSpeedLegendRow(Colors.green, 'NORMAL'),
                    _buildSpeedLegendRow(Colors.orange, 'SLOW'),
                    _buildSpeedLegendRow(Colors.red, 'GRIND'),
                  ],
                ),
              ),
            ),

          // Bottom controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: TrackingControls(
              isTracking: _isTracking,
              onStart: _startTracking,
              onStop: _stopTracking,
              onNewSet: _isTracking ? _newSet : null,
              onFinish: _finishSession,
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildSpeedLegendRow(Color color, String label) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 3,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
          const SizedBox(width: 4),
          Text(label,
              style: const TextStyle(color: Colors.white54, fontSize: 8)),
        ],
      ),
    );
  }
}

/// Path consistency gauge - shows how stable the barbell path is
/// Green = very consistent, Yellow = moderate, Red = unstable
class _PathConsistencyGauge extends StatelessWidget {
  final TrackResult? leftResult;
  final TrackResult? rightResult;

  const _PathConsistencyGauge({this.leftResult, this.rightResult});

  /// Calculate path consistency score (0.0 = bad, 1.0 = perfect)
  /// Based on X-axis standard deviation of recent path points
  double _calculateConsistency(TrackResult? result) {
    if (result == null || !result.hasTrack || result.path.length < 10) {
      return 1.0; // Not enough data, assume good
    }

    // Use last 30 points for recent consistency
    final recentPath = result.path.length > 30
        ? result.path.sublist(result.path.length - 30)
        : result.path;

    // Calculate mean X
    final meanX = recentPath.map((p) => p.x).reduce((a, b) => a + b) /
        recentPath.length;

    // Calculate standard deviation of X positions
    final variance = recentPath
            .map((p) => (p.x - meanX) * (p.x - meanX))
            .reduce((a, b) => a + b) /
        recentPath.length;
    final stdDev = sqrt(variance);

    // Map stdDev to score: 0.0 stdDev = 1.0 score, 0.05+ stdDev = 0.0 score
    return (1.0 - (stdDev / 0.05)).clamp(0.0, 1.0);
  }

  Color _scoreToColor(double score) {
    if (score >= 0.8) return Colors.green;
    if (score >= 0.6) return Colors.lightGreen;
    if (score >= 0.4) return Colors.yellow;
    if (score >= 0.2) return Colors.orange;
    return Colors.red;
  }

  String _scoreToLabel(double score) {
    if (score >= 0.8) return 'STABLE';
    if (score >= 0.6) return 'GOOD';
    if (score >= 0.4) return 'OK';
    if (score >= 0.2) return 'DRIFT';
    return 'UNSTABLE';
  }

  @override
  Widget build(BuildContext context) {
    final leftScore = _calculateConsistency(leftResult);
    final rightScore = _calculateConsistency(rightResult);
    // Use the better-tracked side, or average if both exist
    final hasLeft = leftResult?.hasTrack ?? false;
    final hasRight = rightResult?.hasTrack ?? false;
    final score = hasLeft && hasRight
        ? (leftScore + rightScore) / 2
        : hasLeft
            ? leftScore
            : rightScore;

    final color = _scoreToColor(score);
    final label = _scoreToLabel(score);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              score >= 0.6 ? Icons.check_circle : Icons.warning,
              color: color,
              size: 12,
            ),
            const SizedBox(width: 4),
            Text(
              'PATH $label',
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        // Progress bar
        SizedBox(
          width: 80,
          height: 4,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: score,
              backgroundColor: Colors.white12,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
      ],
    );
  }
}

class _PhaseIndicator extends StatelessWidget {
  final MovementPhase phase;

  const _PhaseIndicator({required this.phase});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    switch (phase) {
      case MovementPhase.idle:
        color = Colors.grey;
        label = 'IDLE';
      case MovementPhase.ascending:
        color = Colors.green;
        label = 'UP';
      case MovementPhase.descending:
        color = Colors.orange;
        label = 'DOWN';
      case MovementPhase.atTop:
        color = Colors.cyan;
        label = 'TOP';
      case MovementPhase.atBottom:
        color = Colors.purple;
        label = 'BOTTOM';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(80),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _TrackInfo extends StatelessWidget {
  final String label;
  final TrackResult? result;
  final Color color;

  const _TrackInfo({
    required this.label,
    required this.result,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (result == null || !result!.hasTrack) {
      return Text('$label: -',
          style: TextStyle(color: color.withAlpha(128), fontSize: 11));
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$label: ',
            style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.bold)),
        Text(result!.isDetected ? 'DET' : 'PRED',
            style:
                TextStyle(color: color.withAlpha(180), fontSize: 10)),
        Text(' (${result!.path.length}pts)',
            style:
                TextStyle(color: color.withAlpha(150), fontSize: 9)),
      ],
    );
  }
}

class _BoundingBoxPainter extends CustomPainter {
  final List<Rect> boxes;

  _BoundingBoxPainter({required this.boxes});

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

class _DualPathPainter extends CustomPainter {
  final TrackResult? leftResult;
  final TrackResult? rightResult;

  _DualPathPainter({this.leftResult, this.rightResult});

  @override
  void paint(Canvas canvas, Size size) {
    if (leftResult != null && leftResult!.hasTrack) {
      _drawPath(canvas, size, leftResult!);
    }
    if (rightResult != null && rightResult!.hasTrack) {
      _drawPath(canvas, size, rightResult!);
    }
  }

  /// Calculate velocity between two consecutive TrackPoints (pixels/sec)
  double _segmentSpeed(TrackPoint a, TrackPoint b, Size size) {
    final dt = b.timestamp.difference(a.timestamp).inMicroseconds / 1e6;
    if (dt <= 0) return 0;
    final dx = (b.x - a.x) * size.width;
    final dy = (b.y - a.y) * size.height;
    return sqrt(dx * dx + dy * dy) / dt;
  }

  /// Map speed to color:
  /// - Green: normal/consistent speed
  /// - Red/Orange: slow (grinding/sticking point)
  /// - Blue/Cyan: fast (explosive)
  /// Uses relative thresholds based on median speed of the path
  Color _speedToColor(double speed, double medianSpeed, double opacity) {
    if (medianSpeed <= 0) {
      return Colors.green.withAlpha((opacity * 255).toInt());
    }

    final ratio = speed / medianSpeed;

    if (ratio < 0.4) {
      // Very slow - deep red (sticking point)
      return Color.lerp(
        Colors.red[900]!,
        Colors.red,
        (ratio / 0.4).clamp(0.0, 1.0),
      )!.withAlpha((opacity * 255).toInt());
    } else if (ratio < 0.7) {
      // Slow - orange to yellow
      final t = ((ratio - 0.4) / 0.3).clamp(0.0, 1.0);
      return Color.lerp(
        Colors.orange,
        Colors.yellow,
        t,
      )!.withAlpha((opacity * 255).toInt());
    } else if (ratio < 1.3) {
      // Normal speed - green
      return Colors.green.withAlpha((opacity * 255).toInt());
    } else if (ratio < 2.0) {
      // Fast - cyan to light blue
      final t = ((ratio - 1.3) / 0.7).clamp(0.0, 1.0);
      return Color.lerp(
        Colors.cyan,
        Colors.lightBlue,
        t,
      )!.withAlpha((opacity * 255).toInt());
    } else {
      // Very fast - blue (explosive)
      return Colors.blue.withAlpha((opacity * 255).toInt());
    }
  }

  void _drawPath(Canvas canvas, Size size, TrackResult result) {
    final path = result.path;

    // Always draw current position indicator even with 0-1 points
    if (path.isEmpty && !result.hasTrack) return;

    // Calculate speeds for all segments
    final speeds = <double>[];
    for (int i = 1; i < path.length; i++) {
      speeds.add(_segmentSpeed(path[i - 1], path[i], size));
    }

    // Calculate median speed for relative comparison
    final sortedSpeeds = List<double>.from(speeds)..sort();
    final nonZeroSpeeds = sortedSpeeds.where((s) => s > 0).toList();
    final medianSpeed = nonZeroSpeeds.isNotEmpty
        ? nonZeroSpeeds[nonZeroSpeeds.length ~/ 2]
        : 1.0;

    final paint = Paint()
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final predictedPaint = Paint()
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    for (int i = 1; i < path.length; i++) {
      final start =
          Offset(path[i - 1].x * size.width, path[i - 1].y * size.height);
      final end =
          Offset(path[i].x * size.width, path[i].y * size.height);
      final opacity = (i / path.length).clamp(0.3, 1.0);
      final isPredicted = path[i].isPredicted || path[i - 1].isPredicted;
      final segSpeed = speeds[i - 1];

      if (isPredicted) {
        predictedPaint.color = Colors.white.withAlpha((opacity * 0.3 * 255).toInt());
        _drawDashedLine(canvas, start, end, predictedPaint);
      } else {
        final color = _speedToColor(segSpeed, medianSpeed, opacity);
        paint.color = color;
        // Thicker line for slow segments (sticking point emphasis)
        final ratio = medianSpeed > 0 ? segSpeed / medianSpeed : 1.0;
        paint.strokeWidth = ratio < 0.5 ? 6.0 : (ratio > 1.5 ? 3.0 : 4.0);
        canvas.drawLine(start, end, paint);
      }
    }

    // Current position indicator with velocity color
    final current =
        Offset(result.x * size.width, result.y * size.height);
    final currentSpeed = speeds.isNotEmpty ? speeds.last : 0.0;
    final currentColor = _speedToColor(currentSpeed, medianSpeed, 1.0);

    // Outer glow
    canvas.drawCircle(
        current, 20, Paint()..color = currentColor.withAlpha(38));
    canvas.drawCircle(
        current, 15, Paint()..color = currentColor.withAlpha(77));

    // Main circle
    final isDetected = result.isDetected;
    canvas.drawCircle(
        current,
        12,
        Paint()
          ..color =
              isDetected ? currentColor : currentColor.withAlpha(128)
          ..style =
              isDetected ? PaintingStyle.fill : PaintingStyle.stroke
          ..strokeWidth = 2);

    if (isDetected) {
      canvas.drawCircle(current, 4, Paint()..color = Colors.white);
    }
  }

  void _drawDashedLine(
      Canvas canvas, Offset start, Offset end, Paint paint) {
    const dashLength = 5.0;
    const gapLength = 3.0;

    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final len =
        (dx.abs() > dy.abs() ? dx.abs() : dy.abs());
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
