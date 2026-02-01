import 'dart:math';

/// Real-world scale configuration for converting normalized coordinates to actual measurements
class ScaleConfig {
  /// Pixels per meter (calculated from calibration)
  final double pixelsPerMeter;

  /// Frame rate for velocity calculations
  final double fps;

  /// Whether this config has been calibrated
  final bool isCalibrated;

  /// Reference object used for calibration
  final String? calibrationReference;

  const ScaleConfig({
    this.pixelsPerMeter = 1.0,
    this.fps = 30.0,
    this.isCalibrated = false,
    this.calibrationReference,
  });

  /// Create config from known plate diameter
  factory ScaleConfig.fromPlateSize({
    required double detectedWidthNormalized,
    required double actualDiameterMeters,
    double fps = 30.0,
  }) {
    final ppm = detectedWidthNormalized / actualDiameterMeters;
    return ScaleConfig(
      pixelsPerMeter: ppm,
      fps: fps,
      isCalibrated: true,
      calibrationReference: '${(actualDiameterMeters * 100).round()}cm plate',
    );
  }

  /// Create config from known distance measurement
  factory ScaleConfig.fromDistance({
    required double normalizedDistance,
    required double actualDistanceMeters,
    double fps = 30.0,
  }) {
    final ppm = normalizedDistance / actualDistanceMeters;
    return ScaleConfig(
      pixelsPerMeter: ppm,
      fps: fps,
      isCalibrated: true,
      calibrationReference: '${(actualDistanceMeters * 100).round()}cm reference',
    );
  }

  /// Create config from camera distance (rough estimation)
  factory ScaleConfig.fromCameraDistance({
    required double distanceMeters,
    double fovDegrees = 65.0,
    double fps = 30.0,
  }) {
    final fovRad = fovDegrees * pi / 180;
    final visibleHeight = 2 * distanceMeters * tan(fovRad / 2);
    final ppm = 1.0 / visibleHeight;
    return ScaleConfig(
      pixelsPerMeter: ppm,
      fps: fps,
      isCalibrated: true,
      calibrationReference: '${distanceMeters.toStringAsFixed(1)}m distance',
    );
  }

  /// Convert normalized velocity to m/s
  double normalizedToMps(double normalizedVelocity) {
    return normalizedVelocity * fps / pixelsPerMeter;
  }

  /// Convert normalized distance to meters
  double normalizedToMeters(double normalizedDistance) {
    return normalizedDistance / pixelsPerMeter;
  }

  /// Convert normalized distance to centimeters
  double normalizedToCm(double normalizedDistance) {
    return normalizedToMeters(normalizedDistance) * 100;
  }

  /// Convert normalized acceleration to m/s²
  double normalizedToMps2(double normalizedAccel) {
    return normalizedAccel * fps * fps / pixelsPerMeter;
  }

  /// Default uncalibrated config
  static const uncalibrated = ScaleConfig(
    pixelsPerMeter: 1.0,
    isCalibrated: false,
  );

  /// Preset for typical squat setup (~2.5m from camera)
  static final squat = ScaleConfig.fromCameraDistance(distanceMeters: 2.5);

  /// Preset for typical bench press setup (~2m from camera)
  static final benchPress = ScaleConfig.fromCameraDistance(distanceMeters: 2.0);

  /// Preset for overhead press (~2.5m from camera)
  static final overheadPress = ScaleConfig.fromCameraDistance(distanceMeters: 2.5);

  ScaleConfig copyWith({
    double? pixelsPerMeter,
    double? fps,
    bool? isCalibrated,
    String? calibrationReference,
  }) {
    return ScaleConfig(
      pixelsPerMeter: pixelsPerMeter ?? this.pixelsPerMeter,
      fps: fps ?? this.fps,
      isCalibrated: isCalibrated ?? this.isCalibrated,
      calibrationReference: calibrationReference ?? this.calibrationReference,
    );
  }
}

/// Standard weight plate diameters in meters
class PlateSizes {
  static const double kg20 = 0.450; // 45cm - Olympic 20kg
  static const double kg15 = 0.400; // 40cm - Olympic 15kg
  static const double kg10 = 0.350; // 35cm - Olympic 10kg
  static const double kg5 = 0.228;  // 22.8cm - Olympic 5kg
  static const double kg25 = 0.210; // 21cm - Olympic 2.5kg
  static const double kg125 = 0.190; // 19cm - Olympic 1.25kg

  static const Map<String, double> all = {
    '20kg (45cm)': kg20,
    '15kg (40cm)': kg15,
    '10kg (35cm)': kg10,
    '5kg (22.8cm)': kg5,
    '2.5kg (21cm)': kg25,
    '1.25kg (19cm)': kg125,
  };
}
