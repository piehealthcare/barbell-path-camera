/// Reusable barbell detection ML models and inference interface.
///
/// This package provides:
/// - Pre-trained barbell detection model files (CoreML, TFLite, PyTorch)
/// - Model metadata (input/output specs, labels, version)
/// - Platform-agnostic inference interface
/// - Helper utilities for model integration
library barbell_ml_models;

export 'src/model_config.dart';
export 'src/model_paths.dart';
export 'src/detection_result.dart';
export 'src/barbell_detector_interface.dart';
