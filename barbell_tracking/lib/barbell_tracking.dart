/// Barbell Path Camera - Real-time barbell tracking with ML detection
/// and VBT (Velocity Based Training) metrics calculation.
library barbell_tracking;

// Domain models
export 'src/domain/model/barbell_detection.dart';
export 'src/domain/model/barbell_path.dart';
export 'src/domain/model/calibration_data.dart';
export 'src/domain/model/rep_metrics.dart';
export 'src/domain/model/tracking_point.dart';
export 'src/domain/model/tracking_session.dart';

// Services
export 'src/service/calibration_service.dart';
export 'src/service/mock_ml_inference_service.dart';
export 'src/service/ml_inference_service.dart';
