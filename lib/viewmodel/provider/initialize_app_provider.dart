import 'package:bebikame/config/get_it.dart';
import 'package:bebikame/service/audio_service.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final initializeAppProvider = FutureProvider.autoDispose((ref) async {
  final audioService = getIt<AudioService>();
  await audioService.play('bgm', loop: true, volume: 0.3);
});
