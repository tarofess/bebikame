import 'dart:async';
import 'package:bebikame/config/get_it.dart';
import 'package:bebikame/service/audio_service.dart';
import 'package:bebikame/service/dialog_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'dart:math';

class FireworksGame extends HookWidget {
  final dialogService = getIt<DialogService>();

  FireworksGame({super.key});

  @override
  Widget build(BuildContext context) {
    final fireworks = useState<List<Firework>>([]);
    final audioService = useMemoized(() => AudioService(), []);

    useEffect(() {
      return () {
        audioService.dispose();
      };
    }, []);

    Future<void> playSound() async {
      try {
        await audioService.stop('fireworks/fireworks');
        await audioService.play('fireworks/fireworks');
      } catch (e) {
        if (context.mounted) {
          dialogService.showErrorDialog(context, e.toString());
        }
      }
    }

    return GestureDetector(
      onTapDown: (TapDownDetails details) {
        fireworks.value = [
          ...fireworks.value,
          Firework(details.globalPosition),
        ];
        playSound();
      },
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: Image.asset('assets/images/fireworks/bg_fireworks.jpg')
                    .image,
                fit: BoxFit.fill,
                alignment: const Alignment(-1.0, -1.0),
              ),
            ),
          ),
          ...fireworks.value.map((firework) => firework),
        ],
      ),
    );
  }
}

class Firework extends HookWidget {
  final Offset position;

  Firework(this.position) : super(key: UniqueKey());

  @override
  Widget build(BuildContext context) {
    final fireworkType = useState(Random().nextInt(3) + 1);
    final frame = useState(0);

    useEffect(() {
      final timer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
        if (frame.value < 31) {
          frame.value++;
        } else {
          timer.cancel();
        }
      });
      return () => timer.cancel();
    }, []);

    return Positioned(
      left: position.dx - 200,
      top: position.dy - 200,
      child: Image.asset(
        'assets/images/fireworks/fireworks${fireworkType.value}/fireworks${fireworkType.value}-${frame.value}.png',
        width: 400,
        height: 400,
      ),
    );
  }
}
