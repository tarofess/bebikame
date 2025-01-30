import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:bebikame/service/audio_service.dart';
import 'package:bebikame/presentation/dialog/error_dialog.dart';

class BubbleGame extends HookWidget {
  const BubbleGame({super.key});

  @override
  Widget build(BuildContext context) {
    final bubbleVisibilities = List.generate(7, (_) => useState(true));
    final bubbleInteractable = List.generate(7, (_) => useState(true));
    final audioService = useMemoized(() => AudioService(), []);

    useEffect(() {
      return () {
        audioService.dispose();
      };
    }, []);

    Future<void> playSound() async {
      try {
        await audioService.stop('bubble/bubble');
        await audioService.play('bubble/bubble');
      } catch (e) {
        if (context.mounted) showErrorDialog(context, e.toString());
      }
    }

    void toggleVisibility(ValueNotifier<bool> visibility,
        ValueNotifier<bool> interactable, int index) {
      if (interactable.value) {
        playSound();
        visibility.value = false;
        interactable.value = false;
        Future.delayed(const Duration(milliseconds: 1000), () {
          visibility.value = true;
          interactable.value = true;
        });
      }
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
                child: buildBubbleImage(
                  bubbleVisibilities[0],
                  bubbleInteractable[0],
                  toggleVisibility,
                  0,
                ),
              ),
              Positioned(
                top: 20.r,
                left: 150.r,
                child: buildBubbleImage(
                  bubbleVisibilities[1],
                  bubbleInteractable[1],
                  toggleVisibility,
                  1,
                ),
              ),
              Positioned(
                top: 20.r,
                right: 150.r,
                child: buildBubbleImage(
                  bubbleVisibilities[2],
                  bubbleInteractable[2],
                  toggleVisibility,
                  2,
                ),
              ),
              Positioned(
                bottom: 20.r,
                left: 150.r,
                child: buildBubbleImage(
                  bubbleVisibilities[3],
                  bubbleInteractable[3],
                  toggleVisibility,
                  3,
                ),
              ),
              Positioned(
                bottom: 20.r,
                right: 150.r,
                child: buildBubbleImage(
                  bubbleVisibilities[4],
                  bubbleInteractable[4],
                  toggleVisibility,
                  4,
                ),
              ),
              Positioned(
                top: 130.r,
                left: 20.r,
                child: buildBubbleImage(
                  bubbleVisibilities[5],
                  bubbleInteractable[5],
                  toggleVisibility,
                  5,
                ),
              ),
              Positioned(
                bottom: 130.r,
                right: 20.r,
                child: buildBubbleImage(
                  bubbleVisibilities[6],
                  bubbleInteractable[6],
                  toggleVisibility,
                  6,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildBubbleImage(
    ValueNotifier<bool> visibility,
    ValueNotifier<bool> interactable,
    void Function(ValueNotifier<bool>, ValueNotifier<bool>, int)
        toggleVisibility,
    int index,
  ) {
    return GestureDetector(
      onTap: () {
        toggleVisibility(visibility, interactable, index);
      },
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
