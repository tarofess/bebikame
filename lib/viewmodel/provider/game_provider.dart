import 'package:flutter_riverpod/flutter_riverpod.dart';

final gameProvider = Provider.family((ref, int index) {
  switch (index) {
    case 0:
      return '動物ゲーム';
    case 1:
      return '乗り物ゲーム';
    case 2:
      return '音楽ゲーム';
    case 3:
      return '夜空ゲーム';
    case 4:
      return 'あわあわゲーム';
    case 5:
      return '花火ゲーム';
    default:
      return 'なし';
  }
});
