import 'package:flutter/material.dart';

class NightGame extends StatelessWidget {
  const NightGame({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: Image.asset('assets/images/night/bg_night.jpg').image,
          fit: BoxFit.cover,
          alignment: const Alignment(-1.0, -1.0),
        ),
      ),
    );
  }
}
