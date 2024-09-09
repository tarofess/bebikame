import 'dart:io';
import 'package:bebikame/get_it.dart';
import 'package:bebikame/service/audio_service.dart';
import 'package:bebikame/service/dialog_service.dart';
import 'package:bebikame/service/navigation_service.dart';
import 'package:bebikame/video_saver.dart';
import 'package:bebikame/view/game_selection_view.dart';
import 'package:bebikame/view/game_view.dart';
import 'package:bebikame/view/widget/loading_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:video_player/video_player.dart';

class VideoPreviewView extends HookConsumerWidget {
  final String? videoPath;
  final navigationService = getIt<NavigationService>();
  final dialogService = getIt<DialogService>();
  final audioService = getIt<AudioService>();

  VideoPreviewView({super.key, required this.videoPath});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final videoPlayerController = useState<VideoPlayerController?>(null);
    final isInitialized = useState(false);
    final isVideoPlaying = useState(false);

    useEffect(() {
      Future<void> initializeVideo() async {
        if (videoPath != null) {
          final controller = VideoPlayerController.file(File(videoPath!));
          videoPlayerController.value = controller;

          try {
            await controller.initialize();
            await controller.setLooping(true);
            isInitialized.value = true;
          } catch (e) {
            if (context.mounted) {
              await dialogService.showErrorDialog(context, e.toString());
            }
          }
        }
      }

      initializeVideo();

      return () {
        videoPlayerController.value?.dispose();
      };
    }, []);

    Future<void> retakeVideo() async {
      final result = await dialogService.showConfirmationDialog(
          context, '再撮影', 'もう一度撮影し直しますか？', 'はい', 'いいえ');
      if (!result) return;

      if (context.mounted) {
        await LoadingOverlay.of(context)
            .during(() => Future.delayed(const Duration(seconds: 2)));
        if (context.mounted) {
          navigationService.pushReplacementWithAnimationFromBottom(
              context, GameView());
        }
      }
    }

    Future<void> saveVideo() async {
      final saveResult = await dialogService.showConfirmationDialog(
          context, '動画の保存', '撮影した動画を保存しますか？', 'はい', 'いいえ');
      if (saveResult) {
        if (videoPath != null) {
          await VideoSaver.saveVideo(videoPath!);
          if (context.mounted) {
            await dialogService.showMessageDialog(
                context, '保存完了', '動画を保存しました。');
          }
        } else {
          throw Exception('動画の保存に失敗しました。');
        }
      }
    }

    Future<void> returnToGameSelectionView() async {
      final result = await dialogService.showConfirmationDialog(
          context, '確認', 'ゲーム選択画面に戻りますか？', 'はい', 'いいえ');
      if (result) {
        audioService.fadeInStart('bgm');
        if (context.mounted) {
          navigationService.pushAndRemoveUntil(context, GameSelectionView());
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('ビデオプレビュー'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.redo),
          onPressed: () async => await retakeVideo(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save_alt),
            onPressed: () async {
              try {
                await saveVideo();
              } catch (e) {
                if (context.mounted) {
                  await dialogService.showErrorDialog(context, e.toString());
                }
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () async {
              await returnToGameSelectionView();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: videoPath == null
              ? const Text('動画が見つかりません')
              : !isInitialized.value
                  ? const CircularProgressIndicator()
                  : Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.rotationX(3.14159),
                      child: VideoPlayer(videoPlayerController.value!),
                    ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (videoPlayerController.value != null) {
            isVideoPlaying.value
                ? videoPlayerController.value!.pause()
                : videoPlayerController.value!.play();
            isVideoPlaying.value = !isVideoPlaying.value;
          }
        },
        child: Icon(
          isVideoPlaying.value ? Icons.pause : Icons.play_arrow,
        ),
      ),
    );
  }
}
