import 'package:flutter/material.dart';

class AnimalGame extends StatelessWidget {
  const AnimalGame({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: Image.asset('assets/images/animal/bg_animal.jpg').image,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
