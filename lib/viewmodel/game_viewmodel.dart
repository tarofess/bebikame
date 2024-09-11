// game_viewmodel.dart

import 'package:bebikame/service/shared_preferences_service.dart';
import 'package:bebikame/service/video_service.dart';
import 'package:bebikame/service/timer_service.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class GameViewModel {
  final TimerService _timerService = TimerService();

  ValueNotifier<int> get remainingTime => _timerService.remainingTime;

  Future<void> startRecording(
    SharedPreferencesService sharedPrefService,
    VideoService videoService,
    VoidCallback onCountdownComplete,
  ) async {
    final shootingTime = await sharedPrefService.getShootingTime() ?? 15;
    await videoService.initializeCamera();
    await videoService.startRecording();
    _timerService.startCountdown(shootingTime, onCountdownComplete);
  }

  void cleanUp(VideoService videoService) {
    _timerService.stopTimer();
    videoService.dispose();
  }

  void dispose() {
    _timerService.dispose();
  }
}

final gameViewModel = Provider((ref) => GameViewModel());
