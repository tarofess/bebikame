import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:bebikame/service/get_it.dart';
import 'package:bebikame/service/audio_service.dart';
import 'package:bebikame/service/timer_service.dart';
import 'package:bebikame/service/video_service.dart';
import 'package:bebikame/presentation/game/animal_game.dart';
import 'package:bebikame/presentation/game/bubble_game.dart';
import 'package:bebikame/presentation/game/fireworks_game.dart';
import 'package:bebikame/presentation/game/music_game.dart';
import 'package:bebikame/presentation/game/night_game.dart';
import 'package:bebikame/presentation/game/vehicle_game.dart';
import 'package:bebikame/presentation/widget/loading_indicator.dart';
import 'package:bebikame/presentation/widget/loading_overlay.dart';
import 'package:bebikame/application/provider/game_notifier.dart';
import 'package:bebikame/application/provider/start_recording_provider.dart';
import 'package:bebikame/presentation/widget/recording_progress_bar.dart';
import 'package:bebikame/presentation/dialog/error_dialog.dart';

class GameView extends HookConsumerWidget {
  final _videoService = getIt<VideoService>();
  final _timerService = getIt<TimerService>();

  GameView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final startRecording = ref.watch(startRecordingProvider);
    final gameName = ref.read(gameProvider.notifier).getSelectedGameName();
    final appLifecycleState = useAppLifecycleState();

    useEffect(() {
      // アプリがバックグラウンドに移動したら録画を終了する
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (appLifecycleState == AppLifecycleState.paused) {
          if (context.mounted) _stopRecording(context);
          _timerService.stopTimer();
        }
      });
      return;
    }, [appLifecycleState]);

    useEffect(() {
      Future<void> hideNavigationBar() async {
        if (Platform.isAndroid) {
          await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
        }
      }

      Future<void> showNavigationBar() async {
        if (Platform.isAndroid) {
          await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
        }
      }

      hideNavigationBar();

      return () {
        showNavigationBar();
        _videoService.dispose();
        _timerService.stopTimer();
      };
    }, []);

    return Scaffold(
      body: Stack(
        children: [
          switch (gameName) {
            '動物ゲーム' => const AnimalGame(),
            '乗り物ゲーム' => const VehicleGame(),
            'あわあわゲーム' => const BubbleGame(),
            '夜空ゲーム' => const NightGame(),
            '花火ゲーム' => const FireworksGame(),
            '音楽ゲーム' => const MusicGame(),
            _ => const Text('なし'),
          },
          startRecording.when(
            data: (shootingTime) {
              _timerService.startCountdown(
                shootingTime,
                onComplete: () {
                  if (context.mounted) _stopRecording(context);
                },
              );
              return Column(
                children: [
                  const RecordingProgressBar(),
                  Expanded(
                    child: Stack(
                      children: [
                        _buildCountdownText(_timerService.remainingTime),
                      ],
                    ),
                  ),
                ],
              );
            },
            loading: () {
              return const LoadingIndicator();
            },
            error: (e, _) {
              WidgetsBinding.instance.addPostFrameCallback((_) async {
                await _goBackWithBGMFadeIn(context, e);
              });
              return const SizedBox();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCountdownText(ValueNotifier<int> remainingTime) {
    return Positioned(
      bottom: 10.h,
      right: 20.w,
      child: Container(
        padding: EdgeInsets.all(8.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
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

  Future<void> _goBackWithBGMFadeIn(BuildContext context, Object e) async {
    try {
      final audioService = getIt<AudioService>();
      await audioService.fadeInStart('bgm');
      if (context.mounted) _goBack(context, e);
    } catch (audioError) {
      if (context.mounted) _goBack(context, e);
    }
  }

  void _goBack(BuildContext context, Object e) {
    context.pop();
    showErrorDialog(context, '$e\nゲーム選択画面に戻りました。');
  }

  Future<void> _stopRecording(BuildContext context) async {
    try {
      await LoadingOverlay.of(context).during(() async {
        final videoPath = await _videoService.stopRecording();
        if (context.mounted) {
          context.pushReplacement(
            '/video_preview_view',
            extra: {'videoPath': videoPath},
          );
        }
      });
    } catch (e) {
      try {
        if (context.mounted) await _goBackWithBGMFadeIn(context, e);
      } catch (e) {
        if (context.mounted) _goBack(context, e);
      }
    }
  }
}
