import 'package:hooks_riverpod/hooks_riverpod.dart';

final gameTypeProvider = Provider((ref) {
  return [
    '動物ゲーム',
    '乗り物ゲーム',
    '夜空ゲーム',
    'あわあわゲーム',
    '花火ゲーム',
    '音楽ゲーム',
  ];
});
