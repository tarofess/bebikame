import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:photo_manager/photo_manager.dart';

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
      controller!.lockCaptureOrientation(DeviceOrientation.landscapeLeft);
    } catch (e) {
      throw Exception('カメラの初期化に失敗しました。\n再度お試しください。');
    }
  }

  Future<void> startRecording() async {
    if (controller == null || isRecording) return;

    try {
      await controller!.startVideoRecording();
      isRecording = true;
    } catch (e) {
      throw Exception('動画撮影の開始に失敗しました。\n再度お試しください。');
    }
  }

  Future<String?> stopRecording() async {
    if (controller == null || !isRecording) return null;

    try {
      final file = await controller!.stopVideoRecording();
      isRecording = false;
      return file.path;
    } catch (e) {
      throw Exception('撮影された動画を処理している間にエラーが発生しました。');
    }
  }

  Future<void> saveVideo(String videoPath) async {
    try {
      final file = File(videoPath);
      await PhotoManager.editor.saveVideo(file);
    } catch (e) {
      throw Exception('動画の保存に失敗しました。\n端末の容量などを確認して再度お試しください。');
    }
  }

  void dispose() {
    controller?.dispose();
  }
}
