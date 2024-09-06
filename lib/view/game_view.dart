import 'package:bebikame/view/game/animal_game.dart';
import 'package:bebikame/view/game/bubble_game.dart';
import 'package:bebikame/view/game/fireworks_game.dart';
import 'package:bebikame/view/game/music_game.dart';
import 'package:bebikame/view/game/night_game.dart';
import 'package:bebikame/view/game/vehicle_game.dart';
import 'package:bebikame/viewmodel/provider/selected_game_provider.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class GameView extends ConsumerWidget {
  const GameView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(selectedGameProvider);

    return Scaffold(
      body: switch (index) {
        0 => const AnimalGame(),
        1 => const VehicleGame(),
        2 => const BubbleGame(),
        3 => const NightGame(),
        4 => const FireworksGame(),
        5 => const MusicGame(),
        _ => const Text('なし'),
      },
    );
  }
}
