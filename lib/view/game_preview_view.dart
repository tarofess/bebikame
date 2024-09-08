import 'package:bebikame/get_it.dart';
import 'package:bebikame/service/dialog_service.dart';
import 'package:bebikame/service/navigation_service.dart';
import 'package:bebikame/view/game/animal_game.dart';
import 'package:bebikame/view/game/bubble_game.dart';
import 'package:bebikame/view/game/fireworks_game.dart';
import 'package:bebikame/view/game/music_game.dart';
import 'package:bebikame/view/game/night_game.dart';
import 'package:bebikame/view/game/vehicle_game.dart';
import 'package:bebikame/view/game_view.dart';
import 'package:bebikame/viewmodel/provider/game_provider.dart';
import 'package:bebikame/viewmodel/provider/selected_game_provider.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class GamePreviewView extends ConsumerWidget {
  final navigationService = getIt<NavigationService>();
  final dialogService = getIt<DialogService>();

  GamePreviewView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameType = ref.watch(gameProvider);
    final index = ref.watch(selectedGameProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(gameType[index]['name']!),
        actions: [
          IconButton(
            icon: const Icon(Icons.check_circle),
            onPressed: () async {
              final result = await dialogService.showConfirmationDialog(
                context,
                gameType[index]['name']!,
                'このゲームで録画を開始しますか？',
                '開始する',
                'キャンセル',
              );
              if (result == true && context.mounted) {
                navigationService.push(context, GameView());
              }
            },
          ),
        ],
      ),
      body: Center(
        child: switch (index) {
          0 => const AnimalGame(),
          1 => const VehicleGame(),
          2 => const BubbleGame(),
          3 => const NightGame(),
          4 => const FireworksGame(),
          5 => const MusicGame(),
          _ => const Text('なし'),
        },
      ),
    );
  }
}
