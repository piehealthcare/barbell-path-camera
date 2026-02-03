import 'dart:io';
import 'package:flutter/services.dart';

/// Utility for locating and loading model files.
class BarbellModelPaths {
  BarbellModelPaths._();

  /// Relative path to TFLite model within this package's models directory.
  static const String tfliteRelativePath = 'models/tflite/barbell_detector.tflite';

  /// Relative path to CoreML model within this package's models directory.
  static const String coremlRelativePath = 'models/coreml/barbell_detector.mlpackage';

  /// Relative path to PyTorch model (for re-export/conversion).
  static const String pytorchRelativePath = 'models/pytorch/best.pt';

  /// Labels file path.
  static const String labelsPath = 'models/labels.txt';

  /// Android asset path (after copying to app's assets).
  static const String androidAssetPath = 'barbell_detector.tflite';

  /// Get the platform-appropriate model identifier.
  ///
  /// - iOS: Returns CoreML model class name
  /// - Android: Returns TFLite asset path
  static String get platformModelId {
    if (Platform.isIOS || Platform.isMacOS) {
      return 'barbell_detector';
    }
    return androidAssetPath;
  }

  /// Load TFLite model bytes from Flutter assets.
  ///
  /// Use this when the model is bundled as a Flutter asset.
  static Future<ByteData> loadTfliteModelBytes() async {
    return rootBundle.load('packages/barbell_ml_models/$tfliteRelativePath');
  }
}
