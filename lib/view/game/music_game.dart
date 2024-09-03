import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class MusicGame extends HookWidget {
  const MusicGame({super.key});

  @override
  Widget build(BuildContext context) {
    final catScale = useState(1.0);
    final chickenScale = useState(1.0);
    final goatScale = useState(1.0);
    final elephantScale = useState(1.0);
    final dogScale = useState(1.0);

    void animateScale(ValueNotifier<double> scale) {
      scale.value = 1.5;
      Future.delayed(const Duration(milliseconds: 1000), () {
        scale.value = 1.0;
      });
    }

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: Image.asset('assets/images/music/bg_music.jpg').image,
              fit: BoxFit.cover,
            ),
          ),
        ),
        // 中央
        Center(
          child: GestureDetector(
            onTap: () => animateScale(catScale),
            child: AnimatedScale(
              scale: catScale.value,
              duration: const Duration(milliseconds: 200),
              child: Image.asset(
                'assets/images/music/piano.png',
                width: 150,
                height: 150,
              ),
            ),
          ),
        ),
        // 左上
        Positioned(
          top: 20,
          left: 100,
          child: GestureDetector(
            onTap: () => animateScale(chickenScale),
            child: AnimatedScale(
              scale: chickenScale.value,
              duration: const Duration(milliseconds: 200),
              child: Image.asset(
                'assets/images/music/violin.png',
                width: 150,
                height: 150,
              ),
            ),
          ),
        ),
        // 右上
        Positioned(
          top: 20,
          right: 100,
          child: GestureDetector(
            onTap: () => animateScale(goatScale),
            child: AnimatedScale(
              scale: goatScale.value,
              duration: const Duration(milliseconds: 200),
              child: Image.asset(
                'assets/images/music/acoustic.png',
                width: 150,
                height: 150,
              ),
            ),
          ),
        ),
        // 左下
        Positioned(
          bottom: 20,
          left: 100,
          child: GestureDetector(
            onTap: () => animateScale(elephantScale),
            child: AnimatedScale(
              scale: elephantScale.value,
              duration: const Duration(milliseconds: 200),
              child: Image.asset(
                'assets/images/music/snare.png',
                width: 150,
                height: 150,
              ),
            ),
          ),
        ),
        // 右下
        Positioned(
          bottom: 20,
          right: 100,
          child: GestureDetector(
            onTap: () => animateScale(dogScale),
            child: AnimatedScale(
              scale: dogScale.value,
              duration: const Duration(milliseconds: 200),
              child: Image.asset(
                'assets/images/music/guitar.png',
                width: 150,
                height: 150,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
