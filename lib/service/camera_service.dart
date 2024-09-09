import 'package:camera/camera.dart';
import 'package:flutter/services.dart';

class CameraService {
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
      isRecording = false;
      return file.path;
    } catch (e) {
      throw Exception('動画撮影の停止に失敗しました: $e');
    }
  }

  void dispose() {
    controller?.dispose();
  }
}
