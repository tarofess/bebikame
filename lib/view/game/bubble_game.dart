import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BubbleGame extends HookWidget {
  const BubbleGame({super.key});

  @override
  Widget build(BuildContext context) {
    final bubbleVisibilities = List.generate(7, (_) => useState(true));

    void toggleVisibility(ValueNotifier<bool> visibility) {
      visibility.value = false;
      Future.delayed(const Duration(milliseconds: 2000), () {
        visibility.value = true;
      });
    }

    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            'assets/images/bubble/bg_bubble.jpg',
            fit: BoxFit.cover,
          ),
        ),
        SafeArea(
          child: Stack(
            children: [
              Center(
                child:
                    buildBubbleImage(bubbleVisibilities[0], toggleVisibility),
              ),
              Positioned(
                top: 20.r,
                left: 150.r,
                child:
                    buildBubbleImage(bubbleVisibilities[1], toggleVisibility),
              ),
              Positioned(
                top: 20.r,
                right: 150.r,
                child:
                    buildBubbleImage(bubbleVisibilities[2], toggleVisibility),
              ),
              Positioned(
                bottom: 20.r,
                left: 150.r,
                child:
                    buildBubbleImage(bubbleVisibilities[3], toggleVisibility),
              ),
              Positioned(
                bottom: 20.r,
                right: 150.r,
                child:
                    buildBubbleImage(bubbleVisibilities[4], toggleVisibility),
              ),
              Positioned(
                top: 130.r,
                left: 20.r,
                child:
                    buildBubbleImage(bubbleVisibilities[5], toggleVisibility),
              ),
              Positioned(
                bottom: 130.r,
                right: 20.r,
                child:
                    buildBubbleImage(bubbleVisibilities[6], toggleVisibility),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildBubbleImage(ValueNotifier<bool> visibility,
      Function(ValueNotifier<bool>) toggleVisibility) {
    return GestureDetector(
      onTap: () => toggleVisibility(visibility),
      child: visibility.value
          ? Image.asset(
              'assets/images/bubble/bubble.png',
              width: 80.r,
              height: 80.r,
            )
          : TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: const Duration(seconds: 1),
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: child,
                );
              },
              child: Image.asset(
                'assets/images/bubble/bubble.png',
                width: 80.r,
                height: 80.r,
              ),
            ),
    );
  }
}
