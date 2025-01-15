import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:bebikame/service/get_it.dart';
import 'package:bebikame/service/shared_preferences_service.dart';
import 'package:bebikame/service/video_service.dart';

final _videoService = getIt<VideoService>();
final _sharedPrefService = getIt<SharedPreferencesService>();

final startRecordingProvider = FutureProvider.autoDispose<int>((ref) async {
  final shootingTime = await _sharedPrefService.getShootingTime() ?? 15;
  await _videoService.startRecording();
  return shootingTime;
});
