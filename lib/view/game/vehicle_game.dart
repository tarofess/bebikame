import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class VehicleGame extends HookWidget {
  const VehicleGame({super.key});

  @override
  Widget build(BuildContext context) {
    final ambulancePosition = useState(Alignment.topLeft);
    final bicyclePosition = useState(Alignment.bottomLeft);
    final carPosition = useState(Alignment.centerRight);
    final motorcyclePosition = useState(Alignment.topRight);
    final patrolcarPosition = useState(Alignment.bottomRight);

    final isAnimating = useState<Set<String>>({});

    void animatePosition(ValueNotifier<Alignment> position, Alignment target,
        String vehicleName) {
      if (isAnimating.value.contains(vehicleName)) return;

      isAnimating.value = {...isAnimating.value, vehicleName};
      final originalPosition = position.value;
      position.value = target;
      Future.delayed(const Duration(milliseconds: 800), () {
        position.value = originalPosition;
        Future.delayed(const Duration(milliseconds: 800), () {
          isAnimating.value =
              isAnimating.value.where((v) => v != vehicleName).toSet();
        });
      });
    }

    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            'assets/images/vehicle/bg_vehicle.jpg',
            fit: BoxFit.cover,
          ),
        ),
        SafeArea(
          child: Stack(
            children: [
              buildVehicleImage(
                'car',
                carPosition,
                Alignment.centerLeft,
                (pos, target) => animatePosition(pos, target, 'car'),
                isAnimating,
              ),
              buildVehicleImage(
                'ambulance',
                ambulancePosition,
                Alignment.topRight,
                (pos, target) => animatePosition(pos, target, 'ambulance'),
                isAnimating,
              ),
              buildVehicleImage(
                'motorcycle',
                motorcyclePosition,
                Alignment.topLeft,
                (pos, target) => animatePosition(pos, target, 'motorcycle'),
                isAnimating,
              ),
              buildVehicleImage(
                'bicycle',
                bicyclePosition,
                Alignment.bottomRight,
                (pos, target) => animatePosition(pos, target, 'bicycle'),
                isAnimating,
              ),
              buildVehicleImage(
                'patrolcar',
                patrolcarPosition,
                Alignment.bottomLeft,
                (pos, target) => animatePosition(pos, target, 'patrolcar'),
                isAnimating,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildVehicleImage(
    String fileName,
    ValueNotifier<Alignment> position,
    Alignment target,
    Function(ValueNotifier<Alignment>, Alignment) animatePosition,
    ValueNotifier<Set<String>> isAnimating,
  ) {
    return AnimatedAlign(
      alignment: position.value,
      curve: Curves.easeInOutSine,
      duration: const Duration(milliseconds: 800),
      child: GestureDetector(
        onTap: isAnimating.value.contains(fileName)
            ? null
            : () => animatePosition(position, target),
        child: Image.asset(
          'assets/images/vehicle/$fileName.png',
          width: 150.r,
          height: 150.r,
        ),
      ),
    );
  }
}
