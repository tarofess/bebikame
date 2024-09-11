import 'package:bebikame/config/get_it.dart';
import 'package:bebikame/service/audio_service.dart';
import 'package:bebikame/service/dialog_service.dart';
import 'package:bebikame/service/navigation_service.dart';
import 'package:bebikame/service/permission_handler_service.dart';
import 'package:bebikame/service/video_service.dart';
import 'package:bebikame/view/game/animal_game.dart';
import 'package:bebikame/view/game/bubble_game.dart';
import 'package:bebikame/view/game/fireworks_game.dart';
import 'package:bebikame/view/game/music_game.dart';
import 'package:bebikame/view/game/night_game.dart';
import 'package:bebikame/view/game/vehicle_game.dart';
import 'package:bebikame/view/game_view.dart';
import 'package:bebikame/view/widget/loading_overlay.dart';
import 'package:bebikame/viewmodel/provider/game_provider.dart';
import 'package:bebikame/viewmodel/provider/selected_game_provider.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

class GamePreviewView extends ConsumerWidget {
  final _navigationService = getIt<NavigationService>();
  final _dialogService = getIt<DialogService>();
  final _audioService = getIt<AudioService>();
  final _permissionHandlerService = getIt<PermissionHandlerService>();

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
            icon: const Icon(Icons.check),
            onPressed: () async {
              try {
                await _handleStartRecordingButtonPress(context);
              } catch (e) {
                if (context.mounted) {
                  await _dialogService.showErrorDialog(context, e.toString());
                }
              }
            },
          ),
        ],
      ),
      body: Center(
        child: switch (index) {
          0 => AnimalGame(),
          1 => VehicleGame(),
          2 => BubbleGame(),
          3 => NightGame(),
          4 => FireworksGame(),
          5 => MusicGame(),
          _ => const Text('なし'),
        },
      ),
    );
  }

  Future<void> _handleStartRecordingButtonPress(BuildContext context) async {
    final videoService = getIt<VideoService>();
    final result = await _dialogService.showConfirmationDialog(
        context, 'ゲーム開始', 'このゲームで録画を開始しますか？', '開始する', 'キャンセル');
    if (!result) return;

    bool isAllPermissionsGranted =
        await _permissionHandlerService.requestPermissions();

    if (isAllPermissionsGranted) {
      if (context.mounted) {
        await LoadingOverlay.of(context).during(
          () async {
            await videoService.initializeCamera();
            await _audioService.fadeOutStop('bgm');
          },
        );

        if (context.mounted) {
          _navigationService.pushReplacementWithAnimationFromBottom(
              context, GameView());
        }
      }
    } else {
      if (context.mounted) {
        await _dialogService.showErrorDialog(
          context,
          'カメラ、マイク、フォトライブラリへのアクセスが全て許可されていません。\n'
          '動画を撮影するために設定から全てのアクセスを許可してください。',
        );
        openAppSettings();
      }
    }
  }
}
