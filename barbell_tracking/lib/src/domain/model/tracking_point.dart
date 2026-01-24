import 'dart:ui';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'tracking_point.freezed.dart';
part 'tracking_point.g.dart';

/// 추적 포인트 - 각 프레임에서 측정된 바벨 위치 및 운동학 데이터
@freezed
class TrackingPoint with _$TrackingPoint {
  const TrackingPoint._();

  const factory TrackingPoint({
    /// 타임스탬프 (초 단위)
    required double timestamp,

    /// 위치 (normalized 0-1)
    required double positionX,
    required double positionY,

    /// Y축 속도 (m/s) - 상하 운동
    required double velocityY,

    /// Y축 가속도 (m/s²)
    required double accelerationY,

    /// 순간 파워 (W) - 옵션
    double? power,

    /// 감지 신뢰도
    @Default(1.0) double confidence,
  }) = _TrackingPoint;

  factory TrackingPoint.fromJson(Map<String, dynamic> json) =>
      _$TrackingPointFromJson(json);

  /// 위치 Offset 반환
  Offset get position => Offset(positionX, positionY);

  /// 화면 좌표로 변환된 위치
  Offset positionScaled(Size screenSize) => Offset(
        positionX * screenSize.width,
        positionY * screenSize.height,
      );
}
