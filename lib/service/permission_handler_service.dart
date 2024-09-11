import 'dart:io';

import 'package:permission_handler/permission_handler.dart';

class PermissionHandlerService {
  Future<bool> requestPermissions() async {
    try {
      final cameraStatus = await Permission.camera.request();
      final microphoneStatus = await Permission.microphone.request();
      final storageStatus = Platform.isIOS
          ? await Permission.photos.request()
          : await Permission.storage.request();

      if (cameraStatus.isGranted &&
          microphoneStatus.isGranted &&
          (storageStatus.isGranted || storageStatus.isLimited)) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      throw Exception('権限の設定中に予期せぬエラーが発生しました。');
    }
  }
}
