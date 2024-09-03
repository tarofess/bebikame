import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class AnimalGame extends HookWidget {
  const AnimalGame({super.key});

  @override
  Widget build(BuildContext context) {
    final catScale = useState(1.0);
    final chickenScale = useState(1.0);
    final goatScale = useState(1.0);
    final elephantScale = useState(1.0);
    final dogScale = useState(1.0);

    void animateScale(ValueNotifier<double> scale) {
      scale.value = 1.5;
      Future.delayed(const Duration(milliseconds: 200), () {
        scale.value = 1.0;
      });
    }

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: Image.asset('assets/images/animal/bg_animal.jpg').image,
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
                'assets/images/animal/cat.png',
                width: 100,
                height: 100,
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
                'assets/images/animal/chicken.png',
                width: 100,
                height: 100,
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
                'assets/images/animal/goat.png',
                width: 100,
                height: 100,
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
                'assets/images/animal/elephant.png',
                width: 100,
                height: 100,
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
                'assets/images/animal/dog.png',
                width: 100,
                height: 100,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
