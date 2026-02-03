import 'dart:typed_data';

import '../../../core/utils/platform_channel.dart';

class RecordingService {
  bool _isRecording = false;
  bool get isRecording => _isRecording;

  Future<bool> startRecording({
    required int width,
    required int height,
    required int fps,
    required int bitrate,
  }) async {
    try {
      final result = await PlatformChannels.videoCompositor.invokeMethod<bool>(
        'startRecording',
        {
          'width': width,
          'height': height,
          'fps': fps,
          'bitrate': bitrate,
        },
      );
      _isRecording = result ?? false;
      return _isRecording;
    } catch (e) {
      _isRecording = false;
      return false;
    }
  }

  Future<void> addFrame({
    required Uint8List cameraFrame,
    required int width,
    required int height,
    Uint8List? overlayPng,
  }) async {
    if (!_isRecording) return;

    try {
      await PlatformChannels.videoCompositor.invokeMethod(
        'addFrame',
        {
          'cameraFrame': cameraFrame,
          'width': width,
          'height': height,
          'overlayPng': ?overlayPng,
        },
      );
    } catch (_) {}
  }

  Future<String?> stopRecording() async {
    if (!_isRecording) return null;

    try {
      final path = await PlatformChannels.videoCompositor
          .invokeMethod<String>('stopRecording');
      _isRecording = false;
      return path;
    } catch (e) {
      _isRecording = false;
      return null;
    }
  }

  Future<void> dispose() async {
    if (_isRecording) {
      await stopRecording();
    }
  }
}
