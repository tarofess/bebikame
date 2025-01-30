import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:video_player/video_player.dart';

import 'package:bebikame/service/get_it.dart';
import 'package:bebikame/service/audio_service.dart';
import 'package:bebikame/service/video_service.dart';
import 'package:bebikame/presentation/widget/loading_indicator.dart';
import 'package:bebikame/presentation/widget/loading_overlay.dart';
import 'package:bebikame/application/provider/video_player_provider.dart';
import 'package:bebikame/presentation/dialog/confirmation_dialog.dart';
import 'package:bebikame/presentation/dialog/error_dialog.dart';
import 'package:bebikame/presentation/dialog/message_dialog.dart';
import 'package:bebikame/domain/result.dart';
import 'package:bebikame/application/provider/save_video_usecase_provider.dart';

class VideoPreviewView extends HookConsumerWidget {
  final String? _videoPath;

  const VideoPreviewView({
    super.key,
    required String? videoPath,
  }) : _videoPath = videoPath;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final videoPlayerState = ref.watch(videoPlayerProvider(_videoPath));
    final videoPlayerController = useState<VideoPlayerController?>(null);
    final isVideoPlaying = useState(false);

    useEffect(() {
      return () {
        videoPlayerController.value?.dispose();
      };
    }, []);

    return Scaffold(
      appBar: _buildAppBar(context, ref, videoPlayerController),
      body: videoPlayerState.when(
        data: (controller) {
          videoPlayerController.value = controller;
          return VideoPlayer(controller);
        },
        loading: () {
          return const LoadingIndicator();
        },
        error: (e, stackTrace) {
          return Center(
            child: Text(
              e.toString(),
              style: const TextStyle(fontSize: 18),
            ),
          );
        },
      ),
      floatingActionButton: videoPlayerController.value == null
          ? null
          : FloatingActionButton(
              child: Icon(
                isVideoPlaying.value ? Icons.pause : Icons.play_arrow,
              ),
              onPressed: () => _togglePlayButton(
                videoPlayerController,
                isVideoPlaying,
              ),
            ),
    );
  }

  AppBar _buildAppBar(
    BuildContext context,
    WidgetRef ref,
    ValueNotifier<VideoPlayerController?> videoPlayerController,
  ) {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      title: const Text('ビデオプレビュー'),
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.redo),
        onPressed: () async {
          await _retakeVideo(context);
        },
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.save_alt),
          onPressed: videoPlayerController.value == null
              ? null
              : () async {
                  await _saveVideo(context, ref);
                },
        ),
        IconButton(
          icon: const Icon(Icons.exit_to_app),
          onPressed: () async {
            await _returnToGameSelectionView(context);
          },
        ),
      ],
    );
  }

  Future<void> _retakeVideo(BuildContext context) async {
    final videoService = getIt<VideoService>();

    final result = await showConfirmationDialog(
      context: context,
      title: '再撮影',
      content: 'もう一度撮影し直しますか？',
    );
    if (!result) return;

    if (context.mounted) {
      try {
        await LoadingOverlay.of(context).during(
          () => videoService.initializeCamera(),
        );
        if (context.mounted) context.pushReplacement('/game_view');
      } catch (e) {
        if (context.mounted) {
          await showErrorDialog(context, e.toString());
        }
      }
    }
  }

  Future<void> _saveVideo(BuildContext context, WidgetRef ref) async {
    final isConfirmed = await showConfirmationDialog(
      context: context,
      title: '動画の保存',
      content: '撮影した動画を保存しますか？',
    );
    if (!isConfirmed) return;

    if (context.mounted) {
      final result = await LoadingOverlay.of(context).during(
        () => ref.read(saveVideoUsecaseProvider).execute(_videoPath),
      );

      switch (result) {
        case Success():
          if (context.mounted) {
            await showMessageDialog(
              context: context,
              title: '保存完了',
              content: '動画を保存しました。',
            );
          }
          break;
        case Failure(message: final message):
          if (context.mounted) showErrorDialog(context, message);
      }
    }
  }

  Future<void> _returnToGameSelectionView(BuildContext context) async {
    final isConfirmed = await showConfirmationDialog(
      context: context,
      title: '確認',
      content: 'ゲーム選択画面に戻りますか？',
    );
    if (!isConfirmed) return;

    try {
      final audioService = getIt<AudioService>();
      await audioService.fadeInStart('bgm');

      if (context.mounted) context.pushReplacement('/');
    } catch (e) {
      if (context.mounted) {
        await showErrorDialog(context, e.toString());
      }
    }
  }

  void _togglePlayButton(
    ValueNotifier<VideoPlayerController?> videoPlayerController,
    ValueNotifier<bool> isVideoPlaying,
  ) {
    if (videoPlayerController.value != null) {
      isVideoPlaying.value
          ? videoPlayerController.value!.pause()
          : videoPlayerController.value!.play();

      isVideoPlaying.value = !isVideoPlaying.value;
    }
  }
}
