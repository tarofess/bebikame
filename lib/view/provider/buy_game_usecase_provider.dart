import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:bebikame/application/provider/game_notifier.dart';
import 'package:bebikame/application/usecase/buy_game_usecase.dart';

final buyGameUsecaseProvider = Provider(
  (ref) => BuyGameUsecase(ref.watch(gameProvider.notifier)),
);
