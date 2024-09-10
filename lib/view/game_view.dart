import 'dart:async';

import 'package:bebikame/config/get_it.dart';
import 'package:bebikame/service/video_service.dart';
import 'package:bebikame/service/dialog_service.dart';
import 'package:bebikame/service/navigation_service.dart';
import 'package:bebikame/service/shared_preferences_service.dart';
import 'package:bebikame/view/game/animal_game.dart';
import 'package:bebikame/view/game/bubble_game.dart';
import 'package:bebikame/view/game/fireworks_game.dart';
import 'package:bebikame/view/game/music_game.dart';
import 'package:bebikame/view/game/night_game.dart';
import 'package:bebikame/view/game/vehicle_game.dart';
import 'package:bebikame/view/video_preview_view.dart';
import 'package:bebikame/viewmodel/game_viewmodel.dart';
import 'package:bebikame/viewmodel/provider/selected_game_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class GameView extends HookConsumerWidget {
  final sharedPrefService = getIt<SharedPreferencesService>();
  final navigationService = getIt<NavigationService>();
  final videoService = getIt<VideoService>();
  final dialogService = getIt<DialogService>();

  GameView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.watch(gameViewModel);
    final index = ref.watch(selectedGameProvider);
    final shootingTime = useState<int?>(0);
    final timer = useState<Timer?>(null);

    useEffect(() {
      Future<void> startRecording() async {
        try {
          shootingTime.value = await sharedPrefService.getShootingTime() ?? 15;
          await videoService.initializeCamera();
          await videoService.startRecording();
          vm.startCountdown(timer, shootingTime, () async {
            final videoPath = await videoService.stopRecording();
            if (context.mounted) {
              navigationService.pushAndRemoveUntil(
                  context, VideoPreviewView(videoPath: videoPath));
            }
          });
        } catch (e) {
          if (context.mounted) {
            await dialogService.showErrorDialog(
              context,
              '撮影開始時に予期せぬエラーが発生しました。\n'
              'ゲームプレビュー画面に戻ります。',
            );
            if (context.mounted) navigationService.pop(context);
          }
        }
      }

      startRecording();
      return () {
        timer.value?.cancel();
        videoService.dispose();
      };
    }, []);

    return Scaffold(
      body: Stack(
        children: [
          switch (index) {
            0 => const AnimalGame(),
            1 => const VehicleGame(),
            2 => const BubbleGame(),
            3 => const NightGame(),
            4 => const FireworksGame(),
            5 => const MusicGame(),
            _ => const Text('なし'),
          },
          Positioned(
            bottom: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                (shootingTime.value ?? 0).toString(),
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
