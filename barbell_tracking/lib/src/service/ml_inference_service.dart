import 'dart:async';
import 'package:camera/camera.dart' as camera;
import 'package:flutter/foundation.dart';
import 'package:ultralytics_yolo/ultralytics_yolo.dart';

import '../domain/model/barbell_detection.dart';

/// Ultralytics YOLO 기반 바벨 감지 서비스
class MLInferenceService {
  UltralyticsYoloCameraController? _controller;
  ObjectDetector? _detector;
  bool _isInitialized = false;
  bool _isModelLoaded = false;

  // 바벨 감지를 위한 신뢰도 임계값
  static const double confidenceThreshold = 0.5;
  static const double iouThreshold = 0.4;

  // 감지 결과 스트림
  StreamSubscription? _detectionSubscription;
  BarbellDetection? _lastDetection;
  int _frameCount = 0;
  final Stopwatch _stopwatch = Stopwatch();

  bool get isInitialized => _isInitialized && _isModelLoaded;

  /// YOLO 모델 초기화 및 로드
  Future<void> initialize({
    String modelPath = 'barbell_detector',
  }) async {
    try {
      // ObjectDetector 생성
      _detector = ObjectDetector(model: LocalYoloModel(
        id: 'barbell',
        task: Task.detect,
        format: Format.coreml, // iOS용
        modelPath: modelPath,
      ));

      await _detector!.loadModel();
      _isModelLoaded = true;
      _isInitialized = true;
      debugPrint('Ultralytics YOLO 모델 로드 완료: $modelPath');
    } catch (e) {
      debugPrint('YOLO 모델 초기화 실패: $e');
      _isInitialized = false;
      _isModelLoaded = false;
    }
  }

  /// 카메라 컨트롤러 생성 (실시간 감지용)
  Future<UltralyticsYoloCameraController?> createCameraController() async {
    if (_detector == null) {
      debugPrint('Detector가 초기화되지 않음');
      return null;
    }

    try {
      _controller = UltralyticsYoloCameraController(
        detector: _detector!,
        lensDirection: CameraLensDirection.back,
      );

      await _controller!.initialize();
      _stopwatch.start();

      debugPrint('카메라 컨트롤러 생성 완료');
      return _controller;
    } catch (e) {
      debugPrint('카메라 컨트롤러 생성 실패: $e');
      return null;
    }
  }

  /// 감지 결과 스트림 구독
  void startDetectionStream(void Function(BarbellDetection? detection) onDetection) {
    if (_controller == null) return;

    _detectionSubscription = _controller!.detectionResultStream.listen((results) {
      _frameCount++;
      final timestamp = _stopwatch.elapsedMilliseconds / 1000.0;

      if (results == null || results.isEmpty) {
        onDetection(null);
        return;
      }

      // barbell 클래스 필터링 및 가장 높은 신뢰도 선택
      final barbellResults = results.where((r) =>
        r.label.toLowerCase().contains('barbell') &&
        r.confidence >= confidenceThreshold
      ).toList();

      if (barbellResults.isEmpty) {
        // barbell이 없으면 가장 신뢰도 높은 것 선택
        final best = results.reduce((a, b) =>
          a.confidence > b.confidence ? a : b
        );
        if (best.confidence >= confidenceThreshold) {
          _lastDetection = _convertToDetection(best, timestamp, _frameCount);
          onDetection(_lastDetection);
        } else {
          onDetection(null);
        }
        return;
      }

      // barbell 중 가장 높은 신뢰도 선택
      final best = barbellResults.reduce((a, b) =>
        a.confidence > b.confidence ? a : b
      );
      _lastDetection = _convertToDetection(best, timestamp, _frameCount);
      onDetection(_lastDetection);
    });
  }

  /// 감지 결과 스트림 중지
  void stopDetectionStream() {
    _detectionSubscription?.cancel();
    _detectionSubscription = null;
  }

  /// 단일 이미지에서 바벨 감지
  Future<BarbellDetection?> detectBarbell(
    camera.CameraImage cameraImage, {
    required double timestamp,
    required int frameIndex,
  }) async {
    // ultralytics_yolo는 스트림 기반이므로 이 메서드는 호환성을 위해 유지
    // 실제 감지는 스트림을 통해 수행
    return _lastDetection;
  }

  /// DetectionResult를 BarbellDetection으로 변환
  BarbellDetection _convertToDetection(
    DetectedObject result,
    double timestamp,
    int frameIndex,
  ) {
    final rect = result.boundingBox;

    // 정규화된 좌표 (0-1) - boundingBox는 이미 정규화됨
    return BarbellDetection(
      frameIndex: frameIndex,
      timestamp: timestamp,
      centerX: rect.center.dx,
      centerY: rect.center.dy,
      boxLeft: rect.left,
      boxTop: rect.top,
      boxWidth: rect.width,
      boxHeight: rect.height,
      confidence: result.confidence,
    );
  }

  /// 리소스 해제
  Future<void> dispose() async {
    stopDetectionStream();
    _controller?.dispose();
    _stopwatch.stop();
    _controller = null;
    _detector = null;
    _isInitialized = false;
    _isModelLoaded = false;
  }
}
