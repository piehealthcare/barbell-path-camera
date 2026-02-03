import 'dart:typed_data';

import 'detection_result.dart';

/// Platform-agnostic interface for barbell detection.
///
/// Implement this interface for each platform:
/// - iOS: CoreML via VNCoreMLRequest
/// - Android: TFLite via Interpreter
/// - Desktop: ONNX Runtime or TFLite
abstract class BarbellDetectorInterface {
  /// Whether the model is loaded and ready for inference.
  bool get isInitialized;

  /// Initialize the detector (load model, allocate buffers).
  Future<bool> initialize();

  /// Run detection on a camera frame.
  ///
  /// [frameBytes] - Raw pixel data (platform-specific format)
  /// [width] - Frame width in pixels
  /// [height] - Frame height in pixels
  /// [rotation] - Camera rotation in degrees (0, 90, 180, 270)
  Future<List<BarbellDetection>> detect({
    required Uint8List frameBytes,
    required int width,
    required int height,
    int rotation = 0,
  });

  /// Release model resources.
  Future<void> dispose();
}
