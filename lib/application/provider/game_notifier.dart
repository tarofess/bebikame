import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:bebikame/env/env.dart';
import 'package:bebikame/service/get_it.dart';
import 'package:bebikame/model/game.dart';
import 'package:bebikame/service/in_app_purchase_service.dart';

class GameNotifier extends Notifier<List<Game>> {
  final _inAppPurchaseService = getIt<InAppPurchaseService>();

  @override
  List<Game> build() {
    return [
      const Game(
        name: '動物ゲーム',
        image: 'assets/images/animal/bg_animal.jpg',
        isLocked: false,
      ),
      const Game(
        name: '乗り物ゲーム',
        image: 'assets/images/vehicle/bg_vehicle.jpg',
        isLocked: false,
      ),
      const Game(
        name: 'あわあわゲーム',
        image: 'assets/images/bubble/bg_bubble.jpg',
        isLocked: false,
      ),
      const Game(
        name: '夜空ゲーム',
        image: 'assets/images/night/bg_night.jpg',
        isLocked: false,
      ),
      Game(
        name: '花火ゲーム',
        image: 'assets/images/fireworks/bg_fireworks.jpg',
        isLocked: _inAppPurchaseService.isProductPurchased(Env.fireworksGame)
            ? false
            : true,
      ),
      Game(
        name: '音楽ゲーム',
        image: 'assets/images/music/bg_music.jpg',
        isLocked: _inAppPurchaseService.isProductPurchased(Env.musicGame)
            ? false
            : true,
      ),
    ];
  }

  String getSelectedGameName() {
    return state.firstWhere((game) => game.selected == true).name;
  }

  void updateGameSelected(String gameName) {
    state = state.map((game) {
      if (game.name == gameName) {
        return game.copyWith(selected: true);
      }
      return game.copyWith(selected: false);
    }).toList();
  }

  void unlockedFireWorksGame() {
    state = state.map((game) {
      if (game.name == '花火ゲーム') {
        return game.copyWith(isLocked: false);
      }
      return game;
    }).toList();
  }

  void unlockedMusicGame() {
    state = state.map((game) {
      if (game.name == '音楽ゲーム') {
        return game.copyWith(isLocked: false);
      }
      return game;
    }).toList();
  }

  void updateGameLockStatus() {
    state = state.map((game) {
      if (game.name == '花火ゲーム') {
        return game.copyWith(
          isLocked: _inAppPurchaseService.isProductPurchased(Env.fireworksGame)
              ? false
              : true,
        );
      } else if (game.name == '音楽ゲーム') {
        return game.copyWith(
          isLocked: _inAppPurchaseService.isProductPurchased(Env.musicGame)
              ? false
              : true,
        );
      }
      return game;
    }).toList();
  }
}

final gameProvider = NotifierProvider<GameNotifier, List<Game>>(
  () => GameNotifier(),
);
