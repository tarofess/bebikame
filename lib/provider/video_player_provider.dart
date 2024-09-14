import 'dart:io';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:video_player/video_player.dart';

final videoPlayerProvider = FutureProvider.family
    .autoDispose<VideoPlayerController, String?>((ref, videoPath) async {
  if (videoPath == null) {
    throw Exception('動画が見つからないため再生できません。');
  }
  final controller = VideoPlayerController.file(File(videoPath));
  await controller.initialize();
  await controller.setLooping(true);
  return controller;
});
