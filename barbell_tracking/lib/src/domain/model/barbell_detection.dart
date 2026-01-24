import 'dart:ui';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'barbell_detection.freezed.dart';
part 'barbell_detection.g.dart';

/// 바벨 감지 결과
@freezed
class BarbellDetection with _$BarbellDetection {
  const BarbellDetection._();

  const factory BarbellDetection({
    /// 프레임 인덱스
    required int frameIndex,

    /// 타임스탬프 (초 단위)
    required double timestamp,

    /// 바벨 중심점 (normalized 0-1)
    required double centerX,
    required double centerY,

    /// 바운딩 박스 (normalized 0-1)
    required double boxLeft,
    required double boxTop,
    required double boxWidth,
    required double boxHeight,

    /// 감지 신뢰도 (0-1)
    required double confidence,
  }) = _BarbellDetection;

  factory BarbellDetection.fromJson(Map<String, dynamic> json) =>
      _$BarbellDetectionFromJson(json);

  /// 중심점 Offset 반환
  Offset get centerPoint => Offset(centerX, centerY);

  /// 화면 좌표로 변환된 중심점
  Offset centerPointScaled(Size screenSize) => Offset(
        centerX * screenSize.width,
        centerY * screenSize.height,
      );

  /// 화면 좌표로 변환된 바운딩 박스
  Rect boundingBoxScaled(Size screenSize) => Rect.fromLTWH(
        boxLeft * screenSize.width,
        boxTop * screenSize.height,
        boxWidth * screenSize.width,
        boxHeight * screenSize.height,
      );
}
