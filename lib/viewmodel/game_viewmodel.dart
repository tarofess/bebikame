import 'dart:async';

import 'package:bebikame/service/shared_preferences_service.dart';
import 'package:bebikame/service/video_service.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class GameViewModel {
  Future<void> startRecording(
    ValueNotifier<int?> shootingTime,
    SharedPreferencesService sharedPrefService,
    VideoService videoService,
    ValueNotifier<Timer?> timer,
    VoidCallback onCountdownComplete,
  ) async {
    shootingTime.value = await sharedPrefService.getShootingTime() ?? 15;
    await videoService.initializeCamera();
    await videoService.startRecording();
    _startCountdown(timer, shootingTime, onCountdownComplete);
  }

  void cleanUp(VideoService videoService, ValueNotifier<Timer?> timer) {
    timer.value?.cancel();
    videoService.dispose();
  }

  void _startCountdown(ValueNotifier<Timer?> timer,
      ValueNotifier<int?> shootingTime, VoidCallback onCountdownComplete) {
    if (timer.value != null || shootingTime.value == null) return;

    timer.value = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (shootingTime.value! > 1) {
        shootingTime.value = shootingTime.value! - 1;
      } else {
        timer.cancel();
        onCountdownComplete();
      }
    });
  }
}

final gameViewModel = Provider((ref) => GameViewModel());
