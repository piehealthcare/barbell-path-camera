import 'dart:math';

import 'package:camera/camera.dart' as camera;
import 'package:flutter/foundation.dart';
import 'package:barbell_tracking/src/domain/model/barbell_detection.dart';

/// Mock ML 추론 서비스 - 실제 모델 없이 테스트용 감지 결과 생성
class MockMLInferenceService {
  bool _isInitialized = false;
  final Random _random = Random();

  // 시뮬레이션용 상태
  double _simulatedY = 0.5;
  double _direction = -1; // -1: 올라감, 1: 내려감

  bool get isInitialized => _isInitialized;
  int get inputWidth => 640;
  int get inputHeight => 640;

  /// 초기화 (항상 성공)
  Future<void> initialize({String? modelPath}) async {
    if (_isInitialized) return;

    debugPrint('Mock ML 서비스 초기화 - 테스트 모드');
    await Future.delayed(const Duration(milliseconds: 500)); // 로딩 시뮬레이션
    _isInitialized = true;
  }

  /// 바벨 감지 시뮬레이션
  Future<BarbellDetection?> detectBarbell(
    camera.CameraImage image, {
    required double timestamp,
    required int frameIndex,
  }) async {
    if (!_isInitialized) return null;

    // 바벨 움직임 시뮬레이션 (위아래로 반복)
    _updateSimulatedPosition();

    // 10% 확률로 감지 실패 시뮬레이션
    if (_random.nextDouble() < 0.1) {
      return null;
    }

    // 약간의 노이즈 추가
    final noiseX = (_random.nextDouble() - 0.5) * 0.02;
    final noiseY = (_random.nextDouble() - 0.5) * 0.01;

    return BarbellDetection(
      frameIndex: frameIndex,
      timestamp: timestamp,
      centerX: 0.5 + noiseX,
      centerY: _simulatedY + noiseY,
      boxLeft: 0.35 + noiseX,
      boxTop: _simulatedY - 0.05 + noiseY,
      boxWidth: 0.3,
      boxHeight: 0.1,
      confidence: 0.85 + _random.nextDouble() * 0.1,
    );
  }

  /// 시뮬레이션 위치 업데이트
  void _updateSimulatedPosition() {
    // 매 프레임마다 위치 변경
    final speed = 0.005 + _random.nextDouble() * 0.003;
    _simulatedY += _direction * speed;

    // 범위 제한 및 방향 전환
    if (_simulatedY < 0.25) {
      _simulatedY = 0.25;
      _direction = 1; // 아래로
    } else if (_simulatedY > 0.75) {
      _simulatedY = 0.75;
      _direction = -1; // 위로
    }
  }

  /// 리소스 해제
  Future<void> dispose() async {
    _isInitialized = false;
  }

  /// 시뮬레이션 리셋
  void reset() {
    _simulatedY = 0.5;
    _direction = -1;
  }
}
