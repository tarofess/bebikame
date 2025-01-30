import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:bebikame/presentation/game/animal_game.dart';
import 'package:bebikame/presentation/game/bubble_game.dart';
import 'package:bebikame/presentation/game/fireworks_game.dart';
import 'package:bebikame/presentation/game/music_game.dart';
import 'package:bebikame/presentation/game/night_game.dart';
import 'package:bebikame/presentation/game/vehicle_game.dart';
import 'package:bebikame/application/provider/game_notifier.dart';
import 'package:bebikame/presentation/dialog/confirmation_dialog.dart';
import 'package:bebikame/presentation/dialog/error_dialog.dart';
import 'package:bebikame/domain/result.dart';
import 'package:bebikame/application/provider/prepare_recording_usecase.dart';
import 'package:bebikame/presentation/widget/loading_overlay.dart';

class GamePreviewView extends ConsumerWidget {
  const GamePreviewView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameName = ref.read(gameProvider.notifier).getSelectedGameName();

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(gameName),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () async {
              final isConfirmed = await showConfirmationDialog(
                context: context,
                title: 'ゲーム開始',
                content: 'このゲームで録画を開始しますか？',
              );
              if (!isConfirmed) return;

              if (context.mounted) {
                final result = await LoadingOverlay.of(context).during(
                  () => ref.read(prepareRecordingUsecaseProvider).execute(),
                );

                switch (result) {
                  case Success():
                    if (context.mounted) context.pushReplacement('/game_view');
                    break;
                  case Failure(message: final message):
                    if (context.mounted) {
                      await showErrorDialog(context, message);
                    }
                }
              }
            },
          ),
        ],
      ),
      body: Center(
        child: switch (gameName) {
          '動物ゲーム' => const AnimalGame(),
          '乗り物ゲーム' => const VehicleGame(),
          'あわあわゲーム' => const BubbleGame(),
          '夜空ゲーム' => const NightGame(),
          '花火ゲーム' => const FireworksGame(),
          '音楽ゲーム' => const MusicGame(),
          _ => const Text('なし'),
        },
      ),
    );
  }
}
