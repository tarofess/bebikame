import 'package:hooks_riverpod/hooks_riverpod.dart';

final gameProvider = Provider((ref) {
  return [
    {'name': '動物ゲーム', 'image': 'assets/images/animal/bg_animal.jpg'},
    {'name': '乗り物ゲーム', 'image': 'assets/images/vehicle/bg_vehicle.jpg'},
    {'name': 'あわあわゲーム', 'image': 'assets/images/bubble/bg_bubble.jpg'},
    {'name': '夜空ゲーム', 'image': 'assets/images/night/bg_night.jpg'},
    {'name': '花火ゲーム', 'image': 'assets/images/fireworks/bg_fireworks.jpg'},
    {'name': '音楽ゲーム', 'image': 'assets/images/music/bg_music.jpg'},
  ];
});
