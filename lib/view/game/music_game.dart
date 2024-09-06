import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:audioplayers/audioplayers.dart';

class MusicGame extends HookWidget {
  const MusicGame({super.key});

  @override
  Widget build(BuildContext context) {
    final pianoScale = useState(1.0);
    final violinScale = useState(1.0);
    final acousticScale = useState(1.0);
    final drumScale = useState(1.0);
    final guitarScale = useState(1.0);

    final audioPlayers = useMemoized(() => {
          'piano': AudioPlayer(),
          'violin': AudioPlayer(),
          'acoustic': AudioPlayer(),
          'drum': AudioPlayer(),
          'guitar': AudioPlayer(),
        });

    void animateScale(ValueNotifier<double> scale, int durationMs) {
      scale.value = 1.5;
      Future.delayed(Duration(milliseconds: durationMs), () {
        scale.value = 1.0;
      });
    }

    void playSound(String instrument) async {
      final player = audioPlayers[instrument]!;
      await player.play(AssetSource('sounds/music/$instrument.mp3'));
    }

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: Image.asset('assets/images/music/bg_music.jpg').image,
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                Colors.white.withOpacity(0.5),
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
            3400,
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
            4000,
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
            2800,
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
            4000,
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
            2000,
          ),
        ),
      ],
    );
  }

  Widget buildMusicImage(
    String fileName,
    ValueNotifier<double> scale,
    Function(ValueNotifier<double>, int) animateScale,
    Function(String) playSound,
    int durationMs,
  ) {
    return GestureDetector(
      onTap: () {
        animateScale(scale, durationMs);
        playSound(fileName);
      },
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
