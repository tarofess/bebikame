import 'package:bebikame/config/get_it.dart';
import 'package:bebikame/service/audio_service.dart';
import 'package:bebikame/service/in_app_purchase_service.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final _audioService = getIt<AudioService>();
final _inAppPurchaseService = getIt<InAppPurchaseService>();

final initializeAppProvider = FutureProvider.autoDispose((ref) async {
  await _inAppPurchaseService.initialize();
  await _audioService.play('bgm', loop: true, volume: 0.3);
});
