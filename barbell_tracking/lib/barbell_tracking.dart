/// Barbell Path Camera - Real-time barbell tracking with ML detection
/// and VBT (Velocity Based Training) metrics calculation.
///
/// This library provides:
/// - ByteTrack-based single object tracking for barbells
/// - Kalman filter for smooth position/velocity estimation
/// - Exercise analysis (rep counting, ROM, velocity metrics)
/// - VBT (Velocity Based Training) zone detection
/// - Real-world unit conversion (m/s, cm)
/// - Camera calibration utilities
/// - UI widgets for path visualization
///
/// ## Quick Start
///
/// ```dart
/// import 'package:barbell_tracking/barbell_tracking.dart';
///
/// // Create service
/// final service = BarbellTrackingService(
///   exerciseType: ExerciseType.squat,
/// );
///
/// // Process ML detection
/// final result = service.processDetection(
///   x: 0.5, y: 0.6,
///   width: 0.1, height: 0.05,
///   confidence: 0.85,
/// );
///
/// // Get metrics
/// print('Reps: ${result.exerciseStats.repCount}');
/// print('Velocity: ${result.speedMps} m/s');
/// print('Zone: ${result.velocityZone.displayName}');
/// ```
library;

// Main service (recommended entry point)
export 'src/barbell_tracking_service.dart';

// Tracker components
export 'src/tracker/byte_tracker.dart';
export 'src/tracker/track_models.dart';
export 'src/tracker/path_smoother.dart';
export 'src/tracker/kalman_filter.dart';

// Analysis
export 'src/analysis/exercise_analyzer.dart';
export 'src/analysis/vbt_zones.dart';

// Scale and calibration
export 'src/scale/scale_config.dart';

// UI widgets
export 'src/ui/path_painter.dart';

// Domain models (freezed)
export 'src/domain/model/barbell_detection.dart';
export 'src/domain/model/barbell_path.dart';
export 'src/domain/model/calibration_data.dart';
export 'src/domain/model/rep_metrics.dart' hide VelocityZone;
export 'src/domain/model/tracking_point.dart';
export 'src/domain/model/tracking_session.dart';

// Services
export 'src/service/calibration_service.dart';
export 'src/service/mock_ml_inference_service.dart';
export 'src/service/ml_inference_service.dart';
