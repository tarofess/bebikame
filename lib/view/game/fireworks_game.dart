import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'dart:math';

class FireworksGame extends HookWidget {
  const FireworksGame({super.key});

  @override
  Widget build(BuildContext context) {
    final fireworks = useState<List<Firework>>([]);

    return GestureDetector(
      onTapDown: (TapDownDetails details) {
        fireworks.value = [
          ...fireworks.value,
          Firework(details.globalPosition),
        ];
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
