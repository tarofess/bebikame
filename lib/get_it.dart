import 'package:bebikame/service/audio_service.dart';
import 'package:bebikame/service/navigation_service.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

void setupGetIt() {
  getIt.registerLazySingleton(() => NavigationService());
  getIt.registerLazySingleton(() => AudioService());
}
