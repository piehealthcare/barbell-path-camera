import 'tracker/byte_tracker.dart';
import 'tracker/track_models.dart';
import 'scale/scale_config.dart';
import 'analysis/exercise_analyzer.dart';
import 'analysis/vbt_zones.dart';

export 'tracker/byte_tracker.dart';
export 'tracker/track_models.dart';
export 'tracker/path_smoother.dart';
export 'tracker/kalman_filter.dart';
export 'scale/scale_config.dart';
export 'analysis/exercise_analyzer.dart';
export 'analysis/vbt_zones.dart';

/// Exercise type with default scale configurations
enum ExerciseType {
  squat,
  benchPress,
  deadlift,
  overheadPress,
  custom,
}

/// Extension for ExerciseType
extension ExerciseTypeExtension on ExerciseType {
  String get displayName {
    switch (this) {
      case ExerciseType.squat:
        return 'Squat';
      case ExerciseType.benchPress:
        return 'Bench Press';
      case ExerciseType.deadlift:
        return 'Deadlift';
      case ExerciseType.overheadPress:
        return 'Overhead Press';
      case ExerciseType.custom:
        return 'Custom';
    }
  }

  String get displayNameKo {
    switch (this) {
      case ExerciseType.squat:
        return '스쿼트';
      case ExerciseType.benchPress:
        return '벤치프레스';
      case ExerciseType.deadlift:
        return '데드리프트';
      case ExerciseType.overheadPress:
        return '오버헤드프레스';
      case ExerciseType.custom:
        return '사용자 지정';
    }
  }

  ScaleConfig get defaultScaleConfig {
    switch (this) {
      case ExerciseType.squat:
        return ScaleConfig.squat;
      case ExerciseType.benchPress:
        return ScaleConfig.benchPress;
      case ExerciseType.deadlift:
        return ScaleConfig.squat;
      case ExerciseType.overheadPress:
        return ScaleConfig.overheadPress;
      case ExerciseType.custom:
        return const ScaleConfig();
    }
  }
}

/// Main service for barbell path tracking
///
/// This is the primary entry point for using the barbell tracking library.
/// It provides a simplified API for:
/// - Real-time barbell detection and tracking
/// - Exercise metrics calculation (reps, velocity, ROM)
/// - VBT (Velocity Based Training) zone detection
/// - Path visualization data
///
/// Example usage:
/// ```dart
/// final service = BarbellTrackingService(
///   exerciseType: ExerciseType.squat,
/// );
///
/// // Process detection from ML model
/// final result = service.processDetection(
///   x: 0.5,
///   y: 0.6,
///   width: 0.1,
///   height: 0.05,
///   confidence: 0.85,
/// );
///
/// // Access metrics
/// print('Reps: ${result.exerciseStats.repCount}');
/// print('Speed: ${result.speedMps} m/s');
/// print('Zone: ${result.velocityZone}');
/// ```
class BarbellTrackingService {
  final ByteTracker _tracker;
  ExerciseType _exerciseType;

  BarbellTrackingService({
    ExerciseType exerciseType = ExerciseType.squat,
    double highConfThreshold = 0.6,
    double lowConfThreshold = 0.1,
    int smoothingWindow = 3,
    double minRepAmplitude = 0.08,
  }) : _exerciseType = exerciseType,
       _tracker = ByteTracker(
         highConfThreshold: highConfThreshold,
         lowConfThreshold: lowConfThreshold,
         scaleConfig: exerciseType.defaultScaleConfig,
         smoothingWindow: smoothingWindow,
         minRepAmplitude: minRepAmplitude,
       );

  /// Process a single detection from ML model
  TrackResult processDetection({
    required double x,
    required double y,
    required double width,
    required double height,
    required double confidence,
  }) {
    final detection = Detection(
      x: x,
      y: y,
      width: width,
      height: height,
      confidence: confidence,
    );
    return _tracker.update([detection]);
  }

  /// Process multiple detections from ML model
  TrackResult processDetections(List<Detection> detections) {
    return _tracker.update(detections);
  }

  /// Process frame with no detections (for prediction)
  TrackResult processEmptyFrame() {
    return _tracker.update([]);
  }

  /// Set exercise type (updates scale config)
  set exerciseType(ExerciseType type) {
    _exerciseType = type;
    _tracker.scaleConfig = type.defaultScaleConfig;
  }

  ExerciseType get exerciseType => _exerciseType;

  /// Set custom scale config
  set scaleConfig(ScaleConfig config) {
    _tracker.scaleConfig = config;
  }

  ScaleConfig get scaleConfig => _tracker.scaleConfig;

  /// Calibrate from plate size
  void calibrateFromPlate({
    required double detectedWidthNormalized,
    required double actualDiameterMeters,
    double fps = 30.0,
  }) {
    _tracker.scaleConfig = ScaleConfig.fromPlateSize(
      detectedWidthNormalized: detectedWidthNormalized,
      actualDiameterMeters: actualDiameterMeters,
      fps: fps,
    );
  }

  /// Calibrate from camera distance
  void calibrateFromDistance({
    required double distanceMeters,
    double fovDegrees = 65.0,
    double fps = 30.0,
  }) {
    _tracker.scaleConfig = ScaleConfig.fromCameraDistance(
      distanceMeters: distanceMeters,
      fovDegrees: fovDegrees,
      fps: fps,
    );
  }

  /// Start a new set
  void startNewSet() {
    _tracker.startNewSet();
  }

  /// Finish current set
  void finishSet() {
    _tracker.finishSet();
  }

  /// Reset all tracking data
  void reset() {
    _tracker.reset();
  }

  /// Clear path history only
  void clearPath() {
    _tracker.clearPath();
  }

  /// Reset exercise statistics only
  void resetExerciseStats() {
    _tracker.resetExerciseStats();
  }

  /// Get current path for visualization
  List<TrackPoint> get path => _tracker.path;

  /// Get current exercise stats
  ExerciseStats get exerciseStats => _tracker.exerciseStats;

  /// Get all completed sets
  List<SetInfo> get sets => _tracker.sets;

  /// Get current set
  SetInfo? get currentSet => _tracker.currentSet;

  /// Check if tracking is active
  bool get hasTrack => _tracker.hasTrack;

  /// Get current position (normalized 0-1)
  List<double>? get currentPosition => _tracker.currentPosition;

  /// Get current velocity (normalized)
  List<double>? get currentVelocity => _tracker.currentVelocity;

  /// Get current velocity zone
  VelocityZone? get currentVelocityZone {
    final velocity = currentVelocity;
    if (velocity == null) return null;
    final vyMps = scaleConfig.normalizedToMps(velocity[1]);
    return VelocityZoneExtension.fromMps(vyMps.abs());
  }
}

/// Configuration for BarbellTrackingService
class BarbellTrackingConfig {
  final ExerciseType exerciseType;
  final double highConfThreshold;
  final double lowConfThreshold;
  final int smoothingWindow;
  final double minRepAmplitude;
  final ScaleConfig? customScaleConfig;

  const BarbellTrackingConfig({
    this.exerciseType = ExerciseType.squat,
    this.highConfThreshold = 0.6,
    this.lowConfThreshold = 0.1,
    this.smoothingWindow = 3,
    this.minRepAmplitude = 0.08,
    this.customScaleConfig,
  });

  BarbellTrackingService createService() {
    final service = BarbellTrackingService(
      exerciseType: exerciseType,
      highConfThreshold: highConfThreshold,
      lowConfThreshold: lowConfThreshold,
      smoothingWindow: smoothingWindow,
      minRepAmplitude: minRepAmplitude,
    );
    if (customScaleConfig != null) {
      service.scaleConfig = customScaleConfig!;
    }
    return service;
  }
}
