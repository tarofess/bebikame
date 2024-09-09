import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';

class VideoSaver {
  static Future<void> saveVideo(String videoPath) async {
    var status = await Permission.storage.status;
    switch (status) {
      case PermissionStatus.granted:
        if (defaultTargetPlatform == TargetPlatform.android) {
          await _saveVideoAndroid(videoPath);
        } else if (defaultTargetPlatform == TargetPlatform.iOS) {
          await _saveVideoIOS(videoPath);
        } else {
          throw Exception('未対応のプラットフォームです。');
        }
        break;
      case PermissionStatus.denied:
        throw Exception('ストレージへのアクセス許可が必要です。');
      case PermissionStatus.permanentlyDenied:
        openAppSettings();
      default:
        throw Exception('ストレージへのアクセス許可が必要です。');
    }
  }

  static Future<void> _saveVideoAndroid(String videoPath) async {
    final directory = await getApplicationDocumentsDirectory();
    final savedVideoPath =
        '${directory.path}/bebikame_video_${DateTime.now().millisecondsSinceEpoch}.mp4';
    await File(videoPath).copy(savedVideoPath);
  }

  static Future<void> _saveVideoIOS(String videoPath) async {
    final result = await ImageGallerySaver.saveFile(
      videoPath,
      name: "bebikame_video_${DateTime.now().millisecondsSinceEpoch}.mp4",
    );

    if (!result['isSuccess']) {
      throw Exception('動画の保存に失敗しました。');
    }
  }
}
