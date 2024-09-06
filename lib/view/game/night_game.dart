import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:audioplayers/audioplayers.dart';

class NightGame extends HookWidget {
  const NightGame({super.key});

  @override
  Widget build(BuildContext context) {
    final moonScale = useState(1.0);
    final starScale1 = useState(1.0);
    final starScale2 = useState(1.0);
    final starSmileScale = useState(1.0);
    final audioPlayer = useMemoized(() => AudioPlayer());
    final moonAudioPlayer = useMemoized(() => AudioPlayer());

    void animateScale(ValueNotifier<double> scale) {
      scale.value = 1.2;
      Future.delayed(const Duration(milliseconds: 200), () {
        scale.value = 1.0;
      });
    }

    void playSound(String soundFile) {
      audioPlayer.stop().then((_) {
        audioPlayer.play(AssetSource(soundFile));
      });
    }

    void playMoonSound(String soundFile) {
      moonAudioPlayer.play(AssetSource(soundFile));
    }

    return Stack(children: [
      Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: Image.asset('assets/images/night/bg_night.jpg').image,
            fit: BoxFit.cover,
            alignment: const Alignment(-1.0, -1.0),
          ),
        ),
      ),
      Positioned(
        top: 10.r,
        right: 60.r,
        child: buildMoonImage('moon', moonScale, animateScale, playMoonSound),
      ),
      Positioned(
        bottom: 10.r,
        right: 140.r,
        child: buildStarImage('star', starScale1, animateScale, playSound),
      ),
      Positioned(
        top: 10.r,
        left: 80.r,
        child: buildStarImage('star', starScale2, animateScale, playSound),
      ),
      Positioned(
        bottom: 50.r,
        left: 220.r,
        child: buildStarImage(
            'star_smile', starSmileScale, animateScale, playSound),
      ),
    ]);
  }

  Widget buildStarImage(
      String fileName,
      ValueNotifier<double> scale,
      Function(ValueNotifier<double>) animateScale,
      Function(String) playSound) {
    final rotationController = useAnimationController(
      duration: const Duration(milliseconds: 500),
    );

    return GestureDetector(
      onTap: () {
        animateScale(scale);
        rotationController.forward(from: 0);
        playSound('sounds/night/$fileName.mp3');
      },
      child: AnimatedScale(
        scale: scale.value,
        duration: const Duration(milliseconds: 1000),
        child: RotationTransition(
          turns: Tween(begin: 0.0, end: 1.0).animate(rotationController),
          child: Image.asset(
            'assets/images/night/$fileName.png',
            width: 120.r,
            height: 120.r,
          ),
        ),
      ),
    );
  }

  Widget buildMoonImage(
      String fileName,
      ValueNotifier<double> scale,
      Function(ValueNotifier<double>) animateScale,
      Function(String) playSound) {
    final rotationController = useAnimationController(
      duration: const Duration(milliseconds: 2200),
    );
    final isAnimating = useState(false);

    return GestureDetector(
      onTap: () {
        if (!isAnimating.value) {
          isAnimating.value = true;
          animateScale(scale);
          playSound('sounds/night/moon.mp3');
          rotationController.forward(from: 0).then((_) {
            isAnimating.value = false;
          });
        }
      },
      child: AnimatedScale(
        scale: scale.value,
        duration: const Duration(milliseconds: 1000),
        child: RotationTransition(
          turns: Tween(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(
              parent: rotationController,
              curve: Curves.easeInOut,
            ),
          ),
          child: Image.asset(
            'assets/images/night/$fileName.png',
            width: 120.r,
            height: 120.r,
          ),
        ),
      ),
    );
  }
}
