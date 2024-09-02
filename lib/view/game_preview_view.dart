import 'package:bebikame/view/game/animal_game.dart';
import 'package:bebikame/view/game/bubble_game.dart';
import 'package:bebikame/view/game/fireworks_game.dart';
import 'package:bebikame/view/game/music_game.dart';
import 'package:bebikame/view/game/night_game.dart';
import 'package:bebikame/view/game/vehicle_game.dart';
import 'package:bebikame/viewmodel/provider/game_type_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GamePreviewView extends ConsumerWidget {
  final int index;

  const GamePreviewView({super.key, required this.index});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameType = ref.watch(gameTypeProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(gameType[index]),
        actions: [
          IconButton(
            icon: const Icon(Icons.check_circle),
            onPressed: () {},
          ),
        ],
      ),
      body: Center(
        child: switch (index) {
          0 => const AnimalGame(),
          1 => const VehicleGame(),
          2 => const MusicGame(),
          3 => const NightGame(),
          4 => const BubbleGame(),
          5 => const FireworksGame(),
          _ => const Text('なし'),
        },
      ),
    );
  }
}
