import 'package:bebikame/application/provider/game_notifier.dart';
import 'package:bebikame/model/game.dart';
import 'package:bebikame/model/result.dart';
import 'package:bebikame/service/get_it.dart';
import 'package:bebikame/service/in_app_purchase_service.dart';

class BuyGameUsecase {
  final _inAppPurchaseService = getIt<InAppPurchaseService>();
  final GameNotifier _gameNotifier;

  BuyGameUsecase(this._gameNotifier);

  Future<Result?> execute(Game game) async {
    try {
      final purchaseStarted = await _inAppPurchaseService.buyProduct(
        _inAppPurchaseService.getProductByName(game)!,
      );

      if (!purchaseStarted) {
        return null;
      }

      final purchaseResult =
          await _inAppPurchaseService.purchaseResultStream.first;

      if (purchaseResult && game.name == '花火ゲーム') {
        _gameNotifier.unlockedFireWorksGame();
      } else if (purchaseResult && game.name == '音楽ゲーム') {
        _gameNotifier.unlockedMusicGame();
      }

      return const Success(null);
    } catch (e) {
      return Failure(e.toString(), e as Exception?);
    }
  }
}
