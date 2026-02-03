/// Model configuration and metadata.
class BarbellModelConfig {
  /// Model version identifier
  static const String version = '1.0.0';

  /// Training run identifier
  static const String trainingRun = 'barbell_yolov8s';

  /// Model architecture
  static const String architecture = 'YOLOv8s';

  /// Input image size (square)
  static const int inputSize = 640;

  /// Number of detection classes
  static const int numClasses = 2;

  /// Class labels
  static const List<String> labels = ['barbell_endpoint', 'barbell_collar'];

  /// Default confidence threshold
  static const double defaultConfidenceThreshold = 0.25;

  /// Default NMS IoU threshold
  static const double defaultNmsThreshold = 0.45;

  /// Model performance metrics (from training)
  static const double mapAt50 = 0.981;
  static const double mapAt50To95 = 0.821;
  static const double precision = 0.953;
  static const double recall = 0.931;

  /// YOLOv8 output dimensions
  /// Output shape: [1, (4 + numClasses), numAnchors]
  static const int outputBoxDim = 4; // x, y, w, h
  static const int numAnchors = 8400;

  /// TFLite specific
  static const String tfliteFileName = 'barbell_detector.tflite';
  static const int tfliteInputChannels = 3; // RGB

  /// CoreML specific
  static const String coremlPackageName = 'barbell_detector';
  static const String coremlModelClass = 'barbell_detector';
}
