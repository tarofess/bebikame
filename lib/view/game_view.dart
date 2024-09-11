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
import 'package:bebikame/view/widget/loading_overlay.dart';
import 'package:bebikame/viewmodel/game_viewmodel.dart';
import 'package:bebikame/viewmodel/provider/selected_game_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class GameView extends HookConsumerWidget {
  final _sharedPrefService = getIt<SharedPreferencesService>();
  final _navigationService = getIt<NavigationService>();
  final _videoService = getIt<VideoService>();
  final _dialogService = getIt<DialogService>();

  GameView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.watch(gameViewModel);
    final index = ref.watch(selectedGameProvider);

    useEffect(() {
      try {
        vm.startRecording(
          _sharedPrefService,
          _videoService,
          () async {
            await LoadingOverlay.of(context).during(() async {
              final videoPath = await _videoService.stopRecording();
              if (context.mounted) {
                _navigationService.pushAndRemoveUntil(
                    context, VideoPreviewView(videoPath: videoPath));
              }
            });
          },
        );
      } catch (e) {
        if (context.mounted) {
          _dialogService.showErrorDialog(
            context,
            '撮影開始時に予期せぬエラーが発生しました。\n'
            '動画を撮影することができません。',
          );
          if (context.mounted) _navigationService.pop(context);
        }
      }
      return () {
        vm.cleanUp(_videoService);
      };
    }, []);

    return Scaffold(
      body: Stack(
        children: [
          switch (index) {
            0 => AnimalGame(),
            1 => VehicleGame(),
            2 => BubbleGame(),
            3 => NightGame(),
            4 => FireworksGame(),
            5 => MusicGame(),
            _ => const Text('なし'),
          },
          _buildCountdownText(vm.remainingTime),
        ],
      ),
    );
  }

  Widget _buildCountdownText(ValueNotifier<int> remainingTime) {
    return Positioned(
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
        child: ValueListenableBuilder<int>(
          valueListenable: remainingTime,
          builder: (context, value, child) {
            return Text(
              value.toString(),
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            );
          },
        ),
      ),
    );
  }
}
