import 'package:flutter/material.dart';

class VehicleGame extends StatelessWidget {
  const VehicleGame({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: Image.asset('assets/images/vehicle/bg_vehicle.jpg').image,
          fit: BoxFit.cover,
          alignment: const Alignment(1.0, 1.0),
        ),
      ),
    );
  }
}
