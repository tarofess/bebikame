import 'package:bebikame/app_lifecycle_observer.dart';
import 'package:bebikame/get_it.dart';
import 'package:bebikame/service/audio_service.dart';
import 'package:bebikame/view/game_selection_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]).then((_) {
    setupGetIt();
    runApp(ProviderScope(child: MyApp()));
  });
  FlutterNativeSplash.remove();
}

class MyApp extends HookConsumerWidget {
  final audioService = getIt<AudioService>();

  MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    useEffect(() {
      final observer = AppLifecycleObserver(audioService);
      WidgetsBinding.instance.addObserver(observer);
      audioService.play('bgm', loop: true, volume: 0.3);

      return () {
        WidgetsBinding.instance.removeObserver(observer);
        audioService.stop('bgm');
      };
    }, []);

    return ScreenUtilInit(
      designSize: const Size(690, 360),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.pinkAccent),
            useMaterial3: true,
          ),
          home: GameSelectionView(),
        );
      },
    );
  }
}
