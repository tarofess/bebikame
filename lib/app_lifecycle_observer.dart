import 'package:bebikame/service/audio_service.dart';
import 'package:flutter/material.dart';

class AppLifecycleObserver extends WidgetsBindingObserver {
  final AudioService _audioService;

  AppLifecycleObserver(this._audioService);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _audioService.pause('bgm');
    } else if (state == AppLifecycleState.resumed) {
      _audioService.resume('bgm');
    }
  }
}
