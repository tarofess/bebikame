import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:bebikame/service/audio_service.dart';
import 'package:bebikame/view/dialog/error_dialog.dart';

class MusicGame extends HookWidget {
  const MusicGame({super.key});

  @override
  Widget build(BuildContext context) {
    final pianoScale = useState(1.0);
    final violinScale = useState(1.0);
    final acousticScale = useState(1.0);
    final drumScale = useState(1.0);
    final guitarScale = useState(1.0);
    final pianoTappable = useState(true);
    final violinTappable = useState(true);
    final acousticTappable = useState(true);
    final drumTappable = useState(true);
    final guitarTappable = useState(true);
    final audioService = useMemoized(() => AudioService(), []);

    useEffect(() {
      return () {
        audioService.dispose();
      };
    }, []);

    void animateScale(ValueNotifier<double> scale, ValueNotifier<bool> tappable,
        int durationMs) {
      scale.value = 1.5;
      tappable.value = false;
      Future.delayed(Duration(milliseconds: durationMs), () {
        scale.value = 1.0;
        tappable.value = true;
      });
    }

    Future<void> playSound(String fileName) async {
      try {
        await audioService.play('music/$fileName');
      } catch (e) {
        if (context.mounted) showErrorDialog(context, e.toString());
      }
    }

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: Image.asset('assets/images/music/bg_music.jpg').image,
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                Colors.white.withOpacity(0.9),
                BlendMode.dstATop,
              ),
            ),
          ),
        ),
        Center(
          child: buildMusicImage(
            'piano',
            pianoScale,
            animateScale,
            playSound,
            3800,
            pianoTappable,
          ),
        ),
        Positioned(
          top: 0.r,
          left: 40.r,
          child: buildMusicImage(
            'violin',
            violinScale,
            animateScale,
            playSound,
            4100,
            violinTappable,
          ),
        ),
        Positioned(
          top: 0.r,
          right: 60.r,
          child: buildMusicImage(
            'acoustic',
            acousticScale,
            animateScale,
            playSound,
            5000,
            acousticTappable,
          ),
        ),
        Positioned(
          bottom: 20.r,
          left: 120.r,
          child: buildMusicImage(
            'drum',
            drumScale,
            animateScale,
            playSound,
            4700,
            drumTappable,
          ),
        ),
        Positioned(
          bottom: 0.r,
          right: 20.r,
          child: buildMusicImage(
            'guitar',
            guitarScale,
            animateScale,
            playSound,
            2800,
            guitarTappable,
          ),
        ),
      ],
    );
  }

  Widget buildMusicImage(
    String fileName,
    ValueNotifier<double> scale,
    Function(ValueNotifier<double>, ValueNotifier<bool>, int) animateScale,
    Function(String) playSound,
    int durationMs,
    ValueNotifier<bool> tappable,
  ) {
    return GestureDetector(
      onTap: tappable.value
          ? () {
              animateScale(scale, tappable, durationMs);
              playSound(fileName);
            }
          : null,
      child: AnimatedScale(
        scale: scale.value,
        duration: const Duration(milliseconds: 200),
        child: Image.asset(
          'assets/images/music/$fileName.png',
          width: 150.r,
          height: 150.r,
        ),
      ),
    );
  }
}
