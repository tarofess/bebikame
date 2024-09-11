import 'dart:async';
import 'package:flutter/foundation.dart';

class TimerService {
  Timer? _timer;
  final ValueNotifier<int> _remainingTime = ValueNotifier(0);

  ValueNotifier<int> get remainingTime => _remainingTime;

  void startCountdown(int duration, VoidCallback onComplete) {
    if (_timer != null) return;

    _remainingTime.value = duration;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime.value > 1) {
        _remainingTime.value--;
      } else {
        stopTimer();
        onComplete();
      }
    });
  }

  void stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void dispose() {
    stopTimer();
    _remainingTime.dispose();
  }
}
