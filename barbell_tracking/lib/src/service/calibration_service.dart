import 'package:barbell_tracking/src/domain/model/barbell_detection.dart';
import 'package:barbell_tracking/src/domain/model/calibration_data.dart';

/// 캘리브레이션 서비스 - 픽셀-미터 변환을 위한 보정
class CalibrationService {
  /// 바벨 플레이트를 기준으로 캘리브레이션
  static CalibrationData calibrateFromPlate({
    required BarbellDetection detection,
    required double plateSize,
    required int imageWidth,
    required int imageHeight,
  }) {
    final platePixels = detection.boxHeight * imageHeight;

    return CalibrationData(
      referenceLength: plateSize,
      referenceLengthPixels: platePixels,
      imageWidth: imageWidth,
      imageHeight: imageHeight,
    );
  }

  /// 바벨 길이를 기준으로 캘리브레이션
  static CalibrationData calibrateFromBarbell({
    required BarbellDetection detection,
    required double barbellLength,
    required int imageWidth,
    required int imageHeight,
  }) {
    final barbellPixels = detection.boxWidth * imageWidth;

    return CalibrationData(
      referenceLength: barbellLength,
      referenceLengthPixels: barbellPixels,
      imageWidth: imageWidth,
      imageHeight: imageHeight,
    );
  }

  /// 수동 캘리브레이션
  static CalibrationData calibrateManual({
    required double referenceLength,
    required double referenceLengthPixels,
    required int imageWidth,
    required int imageHeight,
  }) {
    return CalibrationData(
      referenceLength: referenceLength,
      referenceLengthPixels: referenceLengthPixels,
      imageWidth: imageWidth,
      imageHeight: imageHeight,
    );
  }

  /// 기본 캘리브레이션 (추정값 사용)
  static CalibrationData defaultCalibration({
    required int imageWidth,
    required int imageHeight,
  }) {
    final estimatedPixelsPerMeter = imageHeight / 2.5;

    return CalibrationData(
      referenceLength: 1.0,
      referenceLengthPixels: estimatedPixelsPerMeter,
      imageWidth: imageWidth,
      imageHeight: imageHeight,
      cameraDistance: 2.5,
    );
  }

  /// 여러 프레임의 감지 결과를 평균하여 캘리브레이션 정확도 향상
  static CalibrationData calibrateFromMultipleFrames({
    required List<BarbellDetection> detections,
    required double referenceSize,
    required int imageWidth,
    required int imageHeight,
    bool useWidth = false,
  }) {
    if (detections.isEmpty) {
      return defaultCalibration(
        imageWidth: imageWidth,
        imageHeight: imageHeight,
      );
    }

    final filteredDetections =
        detections.where((d) => d.confidence > 0.7).toList();

    if (filteredDetections.isEmpty) {
      return defaultCalibration(
        imageWidth: imageWidth,
        imageHeight: imageHeight,
      );
    }

    double totalPixels = 0;
    for (final detection in filteredDetections) {
      if (useWidth) {
        totalPixels += detection.boxWidth * imageWidth;
      } else {
        totalPixels += detection.boxHeight * imageHeight;
      }
    }
    final averagePixels = totalPixels / filteredDetections.length;

    return CalibrationData(
      referenceLength: referenceSize,
      referenceLengthPixels: averagePixels,
      imageWidth: imageWidth,
      imageHeight: imageHeight,
    );
  }

  /// 캘리브레이션 검증
  static bool validateCalibration(CalibrationData calibration) {
    final pixelsPerMeter = calibration.pixelsPerMeter;
    if (pixelsPerMeter < 50 || pixelsPerMeter > 1000) {
      return false;
    }
    return true;
  }
}
