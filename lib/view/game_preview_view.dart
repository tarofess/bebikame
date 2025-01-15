import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:bebikame/get_it.dart';
import 'package:bebikame/service/audio_service.dart';
import 'package:bebikame/service/permission_handler_service.dart';
import 'package:bebikame/service/video_service.dart';
import 'package:bebikame/view/game/animal_game.dart';
import 'package:bebikame/view/game/bubble_game.dart';
import 'package:bebikame/view/game/fireworks_game.dart';
import 'package:bebikame/view/game/music_game.dart';
import 'package:bebikame/view/game/night_game.dart';
import 'package:bebikame/view/game/vehicle_game.dart';
import 'package:bebikame/view/widget/loading_overlay.dart';
import 'package:bebikame/provider/game_provider.dart';
import 'package:bebikame/view/dialog/confirmation_dialog.dart';
import 'package:bebikame/view/dialog/error_dialog.dart';

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
              try {
                await _handleStartRecordingButtonPress(context);
              } catch (e) {
                if (context.mounted) {
                  await showErrorDialog(context, e.toString());
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

  Future<void> _handleStartRecordingButtonPress(BuildContext context) async {
    final result = await showConfirmationDialog(
      context: context,
      title: 'ゲーム開始',
      content: 'このゲームで録画を開始しますか？',
    );
    if (!result) return;

    if (context.mounted) await _prepareRecording(context);
  }

  Future<void> _prepareRecording(BuildContext context) async {
    final permissionHandlerService = getIt<PermissionHandlerService>();
    final isAllPermissionsGranted =
        await permissionHandlerService.requestPermissions();

    if (isAllPermissionsGranted) {
      if (context.mounted) await _handlePermissionGranted(context);
    } else {
      if (context.mounted) await _handlePermissionDenied(context);
    }
  }

  Future<void> _handlePermissionGranted(BuildContext context) async {
    final videoService = getIt<VideoService>();
    final audioService = getIt<AudioService>();
    await LoadingOverlay.of(context).during(
      () async {
        await videoService.initializeCamera();
        await audioService.fadeOutStop('bgm');
      },
    );
    if (context.mounted) {
      context.pushReplacement('/game_view');
    }
  }

  Future<void> _handlePermissionDenied(BuildContext context) async {
    await showErrorDialog(
      context,
      'カメラ、マイク、フォトライブラリへのアクセスが全て許可されていません。\n'
      '動画を撮影するために設定から全てのアクセスを許可してください。',
    );
    openAppSettings();
  }
}
