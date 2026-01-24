import 'package:freezed_annotation/freezed_annotation.dart';

part 'calibration_data.freezed.dart';
part 'calibration_data.g.dart';

/// 캘리브레이션 데이터 - 픽셀-미터 변환을 위한 보정 정보
@freezed
class CalibrationData with _$CalibrationData {
  const CalibrationData._();

  const factory CalibrationData({
    /// 참조 길이 (미터) - 예: 바벨 길이 또는 플레이트 직경
    required double referenceLength,

    /// 참조 길이의 픽셀 수
    required double referenceLengthPixels,

    /// 카메라와 바벨 사이 거리 (미터) - 옵션
    double? cameraDistance,

    /// 카메라 해상도 너비
    required int imageWidth,

    /// 카메라 해상도 높이
    required int imageHeight,
  }) = _CalibrationData;

  factory CalibrationData.fromJson(Map<String, dynamic> json) =>
      _$CalibrationDataFromJson(json);

  /// 픽셀당 미터 비율
  double get pixelsPerMeter => referenceLengthPixels / referenceLength;

  /// 미터당 픽셀 비율
  double get metersPerPixel => referenceLength / referenceLengthPixels;

  /// 픽셀 거리를 미터로 변환
  double pixelsToMeters(double pixels) => pixels * metersPerPixel;

  /// 미터를 픽셀로 변환
  double metersToPixels(double meters) => meters * pixelsPerMeter;

  /// normalized 좌표를 미터로 변환 (Y축 기준)
  double normalizedToMetersY(double normalizedY) =>
      normalizedY * imageHeight * metersPerPixel;

  /// normalized 좌표를 미터로 변환 (X축 기준)
  double normalizedToMetersX(double normalizedX) =>
      normalizedX * imageWidth * metersPerPixel;
}

/// 표준 바벨 플레이트 크기 (직경, 미터 단위)
class StandardPlateSizes {
  static const double olympic25kg = 0.450; // 45cm
  static const double olympic20kg = 0.450;
  static const double olympic15kg = 0.400;
  static const double olympic10kg = 0.450;
  static const double olympic5kg = 0.450;
  static const double bumper = 0.450;

  /// 올림픽 바벨 길이
  static const double olympicBarbellLength = 2.20; // 220cm

  /// 올림픽 바벨 슬리브 간 거리
  static const double olympicBarbellInnerLength = 1.31; // 131cm
}
