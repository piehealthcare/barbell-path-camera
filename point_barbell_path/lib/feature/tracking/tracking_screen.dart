import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:point_barbell_path/core/l10n/generated/app_localizations.dart';
import 'package:barbell_tracking/barbell_tracking.dart';

import '../../core/router/app_router.dart';
import '../../core/utils/exercise_utils.dart';
import '../../core/utils/permission_helper.dart';
import '../recording/service/recording_service.dart';
import 'service/platform_ml_service.dart';
import 'widgets/tracking_overlay.dart';
import 'widgets/tracking_controls.dart';
import 'widgets/tracking_stats_panel.dart';

class TrackingScreen extends ConsumerStatefulWidget {
  final String exerciseType;

  const TrackingScreen({super.key, required this.exerciseType});

  @override
  ConsumerState<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends ConsumerState<TrackingScreen>
    with WidgetsBindingObserver {
  CameraController? _cameraController;
  late final BarbellTrackingService _trackingService;
  late final PlatformMLService _mlService;
  final RecordingService _recordingService = RecordingService();

  bool _isInitialized = false;
  bool _isInitializing = false;
  bool _isTracking = false;
  bool _isProcessingFrame = false;
  int _frameCount = 0;
  final int _frameSkip = 2;
  int _currentSetNumber = 1;
  String? _recordedVideoPath;

  TrackResult? _lastResult;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    final exerciseType = _parseExerciseType(widget.exerciseType);
    _trackingService = BarbellTrackingService(exerciseType: exerciseType);
    _mlService = PlatformMLService();

    _initCamera();
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
      final hasPermission = await PermissionHelper.requestCamera();
      if (!hasPermission || !mounted) return;

      final cameras = await availableCameras();
      if (cameras.isEmpty) return;

      // Use the back camera
      final camera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        camera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.bgra8888,
      );

      await _cameraController!.initialize();
      await _mlService.initialize();
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
    if (_cameraController == null || !_isInitialized) return;

    _trackingService.startNewSet();
    _recordingService.startRecording(
      width: 1280,
      height: 720,
      fps: 30,
      bitrate: 4000000,
    );
    _cameraController!.startImageStream(_onCameraFrame);
    setState(() {
      _isTracking = true;
      _frameCount = 0;
    });
  }

  Future<void> _stopTracking() async {
    _cameraController?.stopImageStream();
    _trackingService.finishSet();
    _recordedVideoPath = await _recordingService.stopRecording();
    setState(() => _isTracking = false);
  }

  void _newSet() {
    _trackingService.startNewSet();
    setState(() {
      _currentSetNumber++;
    });
  }

  Future<void> _finishSession() async {
    if (_isTracking) await _stopTracking();

    final stats = _trackingService.exerciseStats;
    final sets = _trackingService.sets;

    if (!mounted) return;

    final avgVelocity = stats.repHistory.isNotEmpty
        ? stats.repHistory.map((r) => r.meanVelocity).reduce((a, b) => a + b) /
            stats.repHistory.length
        : 0.0;
    final peakVelocity = stats.repHistory.isNotEmpty
        ? stats.repHistory.map((r) => r.peakVelocity).reduce((a, b) => a > b ? a : b)
        : 0.0;

    context.pushReplacement(AppRoutes.review, extra: {
      'exerciseType': widget.exerciseType,
      'totalReps': stats.repCount,
      'totalSets': sets.length,
      'avgVelocity': avgVelocity,
      'peakVelocity': peakVelocity,
      if (_recordedVideoPath != null) 'videoPath': _recordedVideoPath,
    });
  }

  Future<void> _onCameraFrame(CameraImage image) async {
    _frameCount++;
    if (_isProcessingFrame || _frameCount % (_frameSkip + 1) != 0) return;

    _isProcessingFrame = true;

    try {
      final detections = await _mlService.detectBarbell(image);

      if (!mounted) return;

      TrackResult result;
      if (detections.isNotEmpty) {
        result = _trackingService.processDetections(detections);
      } else {
        result = _trackingService.processEmptyFrame();
      }

      if (_recordingService.isRecording && image.planes.isNotEmpty) {
        _recordingService.addFrame(
          cameraFrame: image.planes[0].bytes,
          width: image.width,
          height: image.height,
        );
      }

      setState(() {
        _lastResult = result;
      });
    } catch (e) {
      debugPrint('Detection error: $e');
    } finally {
      _isProcessingFrame = false;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      if (_isTracking) _stopTracking();
      _cameraController?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    _mlService.dispose();
    _recordingService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Camera preview
            if (_isInitialized && _cameraController != null)
              Center(
                child: CameraPreview(_cameraController!),
              )
            else
              const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),

            // Barbell path overlay
            if (_lastResult != null)
              TrackingOverlay(
                path: _lastResult!.path,
                scaleConfig: _lastResult!.scaleConfig,
                currentPosition: _lastResult!.hasTrack
                    ? [_lastResult!.x, _lastResult!.y]
                    : null,
              ),

            // Top bar - exercise info
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        if (_isTracking) _stopTracking();
                        context.pop();
                      },
                    ),
                    Text(
                      ExerciseUtils.displayName(widget.exerciseType, l10n),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    if (_isTracking)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'SET $_currentSetNumber',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Stats panel
            if (_lastResult != null)
              Positioned(
                left: 8,
                top: 80,
                child: TrackingStatsPanel(
                  exerciseStats: _lastResult!.exerciseStats,
                  speedMps: _lastResult!.speedMps,
                  velocityZone: _lastResult!.velocityZone,
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
      ),
    );
  }

}
