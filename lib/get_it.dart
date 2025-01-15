import 'package:get_it/get_it.dart';

import 'package:bebikame/service/audio_service.dart';
import 'package:bebikame/service/in_app_purchase_service.dart';
import 'package:bebikame/service/permission_handler_service.dart';
import 'package:bebikame/service/timer_service.dart';
import 'package:bebikame/service/video_service.dart';
import 'package:bebikame/service/dialog_service.dart';
import 'package:bebikame/service/shared_preferences_service.dart';

final getIt = GetIt.instance;

void setupGetIt() {
  getIt.registerLazySingleton(() => DialogService());
  getIt.registerLazySingleton(() => AudioService());
  getIt.registerLazySingleton(() => SharedPreferencesService());
  getIt.registerLazySingleton(() => VideoService());
  getIt.registerLazySingleton(() => PermissionHandlerService());
  getIt.registerLazySingleton(() => TimerService());
  getIt.registerLazySingleton(() => InAppPurchaseService());
}
