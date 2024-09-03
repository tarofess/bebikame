import 'package:bebikame/main.dart';
import 'package:bebikame/service/navigation_service.dart';
import 'package:bebikame/view/game/animal_game.dart';
import 'package:bebikame/view/game/bubble_game.dart';
import 'package:bebikame/view/game/fireworks_game.dart';
import 'package:bebikame/view/game/music_game.dart';
import 'package:bebikame/view/game/night_game.dart';
import 'package:bebikame/view/game/vehicle_game.dart';
import 'package:bebikame/view/game_view.dart';
import 'package:bebikame/viewmodel/provider/game_type_provider.dart';
import 'package:bebikame/viewmodel/provider/selected_game_provider.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class GamePreviewView extends ConsumerWidget {
  final navigationService = getIt<NavigationService>();

  GamePreviewView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameType = ref.watch(gameTypeProvider);
    final index = ref.watch(selectedGameProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(gameType[index]),
        actions: [
          IconButton(
            icon: const Icon(Icons.check_circle),
            onPressed: () {
              navigationService.push(context, const GameView());
            },
          ),
        ],
      ),
      body: Center(
        child: switch (index) {
          0 => const AnimalGame(),
          1 => const VehicleGame(),
          2 => const NightGame(),
          3 => const BubbleGame(),
          4 => const FireworksGame(),
          5 => const MusicGame(),
          _ => const Text('なし'),
        },
      ),
    );
  }
}
