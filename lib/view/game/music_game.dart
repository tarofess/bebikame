import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MusicGame extends HookWidget {
  const MusicGame({super.key});

  @override
  Widget build(BuildContext context) {
    final pianoScale = useState(1.0);
    final violinScale = useState(1.0);
    final acousticScale = useState(1.0);
    final snareScale = useState(1.0);
    final guitarScale = useState(1.0);

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
              colorFilter: ColorFilter.mode(
                Colors.white.withOpacity(0.5),
                BlendMode.dstATop,
              ),
            ),
          ),
        ),
        Center(
          child: buildMusicImage('piano', pianoScale, animateScale),
        ),
        Positioned(
          top: 0.r,
          left: 40.r,
          child: buildMusicImage('violin', violinScale, animateScale),
        ),
        Positioned(
          top: 0.r,
          right: 60.r,
          child: buildMusicImage('acoustic', acousticScale, animateScale),
        ),
        Positioned(
          bottom: 20.r,
          left: 120.r,
          child: buildMusicImage('snare', snareScale, animateScale),
        ),
        Positioned(
          bottom: 0.r,
          right: 20.r,
          child: buildMusicImage('guitar', guitarScale, animateScale),
        ),
      ],
    );
  }

  Widget buildMusicImage(String fileName, ValueNotifier<double> scale,
      Function(ValueNotifier<double>) animateScale) {
    return GestureDetector(
      onTap: () => animateScale(scale),
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
