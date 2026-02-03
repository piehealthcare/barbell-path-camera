import 'package:permission_handler/permission_handler.dart';

class PermissionHelper {
  static Future<bool> requestCamera() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  static Future<bool> requestStorage() async {
    final status = await Permission.photos.request();
    return status.isGranted || status.isLimited;
  }

  static Future<bool> checkCamera() async {
    return await Permission.camera.isGranted;
  }

  static Future<bool> checkStorage() async {
    final status = await Permission.photos.status;
    return status.isGranted || status.isLimited;
  }

  static Future<Map<String, bool>> requestAll() async {
    final camera = await requestCamera();
    final storage = await requestStorage();
    return {
      'camera': camera,
      'storage': storage,
    };
  }
}
