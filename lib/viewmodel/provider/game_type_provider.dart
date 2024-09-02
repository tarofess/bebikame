import 'package:flutter_riverpod/flutter_riverpod.dart';

final gameTypeProvider = Provider((ref) {
  return [
    '動物ゲーム',
    '乗り物ゲーム',
    '音楽ゲーム',
    '夜空ゲーム',
    'あわあわゲーム',
    '花火ゲーム',
  ];
});
