import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:barbell_tracking/barbell_tracking.dart';

import '../../../core/utils/platform_channel.dart';

class PlatformMLService {
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    try {
      final result = await PlatformChannels.barbellDetector
          .invokeMethod<bool>('initialize');
      _isInitialized = result ?? false;
    } catch (e) {
      debugPrint('ML model initialization failed: $e');
      _isInitialized = false;
    }
  }

  Future<List<Detection>> detectBarbell(CameraImage image) async {
    try {
      final result = await PlatformChannels.barbellDetector.invokeMethod(
        'detectBarbell',
        {
          'width': image.width,
          'height': image.height,
          'planes': image.planes
              .map((p) => {
                    'bytes': p.bytes,
                    'bytesPerRow': p.bytesPerRow,
                    'bytesPerPixel': p.bytesPerPixel,
                    'height': p.height,
                    'width': p.width,
                  })
              .toList(),
        },
      );

      if (result == null || result is! List) return [];

      return result.map<Detection>((det) {
        return Detection(
          x: (det['x'] as num).toDouble(),
          y: (det['y'] as num).toDouble(),
          width: (det['width'] as num).toDouble(),
          height: (det['height'] as num).toDouble(),
          confidence: (det['confidence'] as num).toDouble(),
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> dispose() async {
    try {
      await PlatformChannels.barbellDetector.invokeMethod('dispose');
    } catch (_) {}
    _isInitialized = false;
  }
}
