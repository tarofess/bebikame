import 'package:flutter/material.dart';

class BubbleGame extends StatelessWidget {
  const BubbleGame({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: Image.asset('assets/images/bg_bubble.jpg').image,
          fit: BoxFit.cover,
          alignment: const Alignment(-1.0, -1.0),
        ),
      ),
    );
  }
}
