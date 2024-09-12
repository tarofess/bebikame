import 'package:bebikame/config/get_it.dart';
import 'package:bebikame/service/audio_service.dart';
import 'package:bebikame/service/dialog_service.dart';
import 'package:bebikame/service/navigation_service.dart';
import 'package:bebikame/service/video_service.dart';
import 'package:bebikame/view/game_selection_view.dart';
import 'package:bebikame/view/game_view.dart';
import 'package:bebikame/view/widget/loading_overlay.dart';
import 'package:bebikame/viewmodel/provider/video_player_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:video_player/video_player.dart';

class VideoPreviewView extends HookConsumerWidget {
  final String? _videoPath;
  final _navigationService = getIt<NavigationService>();
  final _dialogService = getIt<DialogService>();
  final _videoService = getIt<VideoService>();

  VideoPreviewView({super.key, required String? videoPath})
      : _videoPath = videoPath;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final videoPlayer = ref.watch(videoPlayerProvider(_videoPath));
    final videoPlayerController = useState<VideoPlayerController?>(null);
    final isVideoPlaying = useState(false);

    useEffect(() {
      return () {
        videoPlayerController.value?.dispose();
      };
    }, []);

    return Scaffold(
      body: videoPlayer.when(
        data: (controller) {
          videoPlayerController.value = controller;
          return VideoPlayer(controller);
        },
        loading: () => CircularProgressIndicator(
          color: Theme.of(context).colorScheme.inversePrimary,
        ),
        error: (e, _) => Center(
          child: Text(
            e.toString(),
            style: const TextStyle(fontSize: 18),
          ),
        ),
      ),
      appBar: _buildAppBar(context, videoPlayerController),
      floatingActionButton: videoPlayerController.value == null
          ? null
          : FloatingActionButton(
              child:
                  Icon(isVideoPlaying.value ? Icons.pause : Icons.play_arrow),
              onPressed: () =>
                  _togglePlayButton(videoPlayerController, isVideoPlaying),
            ),
    );
  }

  AppBar _buildAppBar(BuildContext context,
      ValueNotifier<VideoPlayerController?> videoPlayerController) {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      title: const Text('ビデオプレビュー'),
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.redo),
        onPressed: () async {
          try {
            await _retakeVideo(context);
          } catch (e) {
            if (context.mounted) {
              await _dialogService.showErrorDialog(context, e.toString());
            }
          }
        },
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.save_alt),
          onPressed: videoPlayerController.value == null
              ? null
              : () async {
                  try {
                    await _saveVideo(context);
                  } catch (e) {
                    if (context.mounted) {
                      await _dialogService.showErrorDialog(
                          context, e.toString());
                    }
                  }
                },
        ),
        IconButton(
          icon: const Icon(Icons.exit_to_app),
          onPressed: () async {
            try {
              await _returnToGameSelectionView(context);
            } catch (e) {
              if (context.mounted) {
                await _dialogService.showErrorDialog(context, e.toString());
              }
            }
          },
        ),
      ],
    );
  }

  Future<void> _retakeVideo(BuildContext context) async {
    final result = await _dialogService.showConfirmationDialog(
        context, '再撮影', 'もう一度撮影し直しますか？', 'はい', 'いいえ');
    if (!result) return;

    if (context.mounted) {
      await LoadingOverlay.of(context).during(
        () => _videoService.initializeCamera(),
      );
      if (context.mounted) {
        _navigationService.pushReplacementWithAnimationFromBottom(
          context,
          GameView(),
        );
      }
    }
  }

  Future<void> _saveVideo(BuildContext context) async {
    final result = await _dialogService.showConfirmationDialog(
        context, '動画の保存', '撮影した動画を保存しますか？', 'はい', 'いいえ');
    if (!result) return;

    if (_videoPath == null) {
      throw Exception('撮影した動画が見つからないため保存できませんでした。');
    }

    if (context.mounted) {
      await LoadingOverlay.of(context).during(
        () => _videoService.saveVideo(_videoPath),
      );
      if (context.mounted) {
        await _dialogService.showMessageDialog(context, '保存完了', '動画を保存しました。');
      }
    }
  }

  Future<void> _returnToGameSelectionView(BuildContext context) async {
    final result = await _dialogService.showConfirmationDialog(
        context, '確認', 'ゲーム選択画面に戻りますか？', 'はい', 'いいえ');
    if (!result) return;

    final audioService = getIt<AudioService>();
    await audioService.fadeInStart('bgm');
    if (context.mounted) {
      _navigationService.pushAndRemoveUntil(context, GameSelectionView());
    }
  }

  void _togglePlayButton(
      ValueNotifier<VideoPlayerController?> videoPlayerController,
      ValueNotifier<bool> isVideoPlaying) {
    if (videoPlayerController.value != null) {
      isVideoPlaying.value
          ? videoPlayerController.value!.pause()
          : videoPlayerController.value!.play();
      isVideoPlaying.value = !isVideoPlaying.value;
    }
  }
}
