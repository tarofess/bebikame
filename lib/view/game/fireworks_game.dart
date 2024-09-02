import 'package:flutter/material.dart';

class FireworksGame extends StatelessWidget {
  const FireworksGame({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: Image.asset('assets/images/bg_fireworks.jpg').image,
          fit: BoxFit.cover,
          alignment: const Alignment(-1.0, -1.0),
        ),
      ),
    );
  }
}
