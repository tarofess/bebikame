import 'dart:io';

import 'package:camera/camera.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';

class VideoService {
  CameraController? controller;
  bool isRecording = false;

  Future<void> initializeCamera() async {
    try {
      final cameras = await availableCameras();
      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );
      controller = CameraController(
        frontCamera,
        ResolutionPreset.high,
        enableAudio: true,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );
      await controller!.initialize();
      controller!.lockCaptureOrientation(DeviceOrientation.landscapeRight);
    } catch (e) {
      throw Exception('カメラの初期化に失敗しました。');
    }
  }

  Future<void> startRecording() async {
    if (controller == null || isRecording) return;

    try {
      await controller!.startVideoRecording();
      isRecording = true;
    } catch (e) {
      throw Exception('動画撮影の開始に失敗しました。');
    }
  }

  Future<String?> stopRecording() async {
    if (controller == null || !isRecording) return null;

    try {
      final file = await controller!.stopVideoRecording();
      final rotatedVideoPath = await _rotateVideo180Degrees(file.path);
      isRecording = false;
      return rotatedVideoPath;
    } catch (e) {
      throw Exception('動画撮影の停止に失敗しました: $e');
    }
  }

  Future<void> saveVideo(String videoPath) async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      await _saveVideoAndroid(videoPath);
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      await _saveVideoIOS(videoPath);
    } else {
      throw Exception('未対応のプラットフォームです。');
    }
  }

  Future<void> _saveVideoAndroid(String videoPath) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final savedVideoPath =
          '${directory.path}/bebikame_video_${DateTime.now().millisecondsSinceEpoch}.mp4';
      await File(videoPath).copy(savedVideoPath);
    } catch (e) {
      throw Exception('動画の保存に失敗しました。');
    }
  }

  Future<void> _saveVideoIOS(String videoPath) async {
    try {
      final result = await ImageGallerySaver.saveFile(
        videoPath,
        name: "bebikame_video_${DateTime.now().millisecondsSinceEpoch}.mp4",
      );
      if (!result['isSuccess']) {
        throw Exception('動画の保存に失敗しました。');
      }
    } catch (e) {
      throw Exception('動画の保存に失敗しました。');
    }
  }

  Future<String?> _rotateVideo180Degrees(String inputPath) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final outputPath =
          '${directory.path}/rotated_video_${DateTime.now().millisecondsSinceEpoch}.mp4';

      final command = '-i $inputPath '
          '-vf "transpose=2,transpose=2" '
          '-c:v h264 '
          '-b:v 2M '
          '-maxrate 2M '
          '-bufsize 1M '
          '-c:a copy '
          '-metadata:s:v:0 rotate=0 '
          '-movflags +faststart '
          '$outputPath';

      final session = await FFmpegKit.execute(command);
      final returnCode = await session.getReturnCode();

      if (ReturnCode.isSuccess(returnCode)) {
        return outputPath;
      } else {
        throw Exception('撮影された動画の調整中にエラーが発生しました。');
      }
    } catch (e) {
      rethrow;
    }
  }

  void dispose() {
    controller?.dispose();
  }
}
