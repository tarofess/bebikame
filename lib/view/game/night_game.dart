import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NightGame extends HookWidget {
  const NightGame({super.key});

  @override
  Widget build(BuildContext context) {
    final moonScale = useState(1.0);
    final starScale1 = useState(1.0);
    final starScale2 = useState(1.0);
    final starSmileScale = useState(1.0);

    void animateScale(ValueNotifier<double> scale) {
      scale.value = 1.2;
      Future.delayed(const Duration(milliseconds: 200), () {
        scale.value = 1.0;
      });
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
        child: buildNightImageSlow('moon', moonScale, animateScale),
      ),
      Positioned(
        bottom: 10.r,
        right: 140.r,
        child: buildNightImageReverse('star', starScale1, animateScale),
      ),
      Positioned(
        top: 10.r,
        left: 80.r,
        child: buildNightImage('star', starScale2, animateScale),
      ),
      Positioned(
        bottom: 50.r,
        left: 220.r,
        child: buildNightImage('star_smile', starSmileScale, animateScale),
      ),
    ]);
  }

  Widget buildNightImage(String fileName, ValueNotifier<double> scale,
      Function(ValueNotifier<double>) animateScale) {
    final rotationController = useAnimationController(
      duration: const Duration(milliseconds: 500),
    );

    return GestureDetector(
      onTap: () {
        animateScale(scale);
        rotationController.forward(from: 0);
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

  Widget buildNightImageReverse(String fileName, ValueNotifier<double> scale,
      Function(ValueNotifier<double>) animateScale) {
    final rotationController = useAnimationController(
      duration: const Duration(milliseconds: 500),
    );

    return GestureDetector(
      onTap: () {
        animateScale(scale);
        rotationController.forward(from: 0);
      },
      child: AnimatedScale(
        scale: scale.value,
        duration: const Duration(milliseconds: 1000),
        child: Transform.rotate(
          angle: -0.3,
          child: RotationTransition(
            turns: Tween(begin: 0.0, end: -1.0).animate(rotationController),
            child: Image.asset(
              'assets/images/night/$fileName.png',
              width: 120.r,
              height: 120.r,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildNightImageSlow(String fileName, ValueNotifier<double> scale,
      Function(ValueNotifier<double>) animateScale) {
    final rotationController = useAnimationController(
      duration: const Duration(seconds: 2),
    );

    return GestureDetector(
      onTap: () {
        animateScale(scale);
        rotationController.forward(from: 0);
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
