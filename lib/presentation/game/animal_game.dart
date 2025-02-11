import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:bebikame/service/audio_service.dart';
import 'package:bebikame/presentation/dialog/error_dialog.dart';

class AnimalGame extends HookWidget {
  const AnimalGame({super.key});

  @override
  Widget build(BuildContext context) {
    final catScale = useState(1.0);
    final chickenScale = useState(1.0);
    final goatScale = useState(1.0);
    final elephantScale = useState(1.0);
    final dogScale = useState(1.0);
    final audioService = useMemoized(() => AudioService(), []);

    useEffect(() {
      return () {
        audioService.dispose();
      };
    }, []);

    void animateScale(ValueNotifier<double> scale) {
      scale.value = 1.5;
      Future.delayed(const Duration(milliseconds: 200), () {
        scale.value = 1.0;
      });
    }

    Future<void> playSound(String fileName) async {
      try {
        await audioService.stop('animal/$fileName');
        await audioService.play('animal/$fileName');
      } catch (e) {
        if (context.mounted) showErrorDialog(context, e.toString());
      }
    }

    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            'assets/images/animal/bg_animal.jpg',
            fit: BoxFit.cover,
          ),
        ),
        SafeArea(
          child: Stack(
            children: [
              Center(
                child:
                    buildAnimalImage('cat', catScale, animateScale, playSound),
              ),
              Positioned(
                top: 20.r,
                left: 20.r,
                child: buildAnimalImage(
                    'chicken', chickenScale, animateScale, playSound),
              ),
              Positioned(
                top: 20.r,
                right: 20.r,
                child: buildAnimalImage(
                    'goat', goatScale, animateScale, playSound),
              ),
              Positioned(
                bottom: 20.r,
                left: 20.r,
                child:
                    buildAnimalImage('dog', dogScale, animateScale, playSound),
              ),
              Positioned(
                bottom: 20.r,
                right: 20.r,
                child: buildAnimalImage(
                    'elephant', elephantScale, animateScale, playSound),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildAnimalImage(
    String fileName,
    ValueNotifier<double> scale,
    Function(ValueNotifier<double>) animateScale,
    Future<void> Function(String) playSound,
  ) {
    return GestureDetector(
      onTap: () {
        animateScale(scale);
        playSound(fileName);
      },
      child: AnimatedScale(
        scale: scale.value,
        duration: const Duration(milliseconds: 200),
        child: Image.asset(
          'assets/images/animal/$fileName.png',
          width: 110.r,
          height: 110.r,
        ),
      ),
    );
  }
}
