import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class GameViewModel {
  void startCountdown(ValueNotifier<Timer?> timer,
      ValueNotifier<int?> shootingTime, VoidCallback moveToVideoPreview) {
    if (timer.value != null || shootingTime.value == null) return;

    timer.value = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (shootingTime.value! > 1) {
        shootingTime.value = shootingTime.value! - 1;
      } else {
        timer.cancel();
        moveToVideoPreview();
      }
    });
  }
}

final gameViewModel = Provider((ref) => GameViewModel());
