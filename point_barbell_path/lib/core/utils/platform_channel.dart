import 'package:flutter/services.dart';

abstract final class PlatformChannels {
  static const barbellDetector = MethodChannel('barbell_detector');
  static const videoCompositor = MethodChannel('video_compositor');
}
