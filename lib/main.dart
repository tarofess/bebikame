import 'package:bebikame/service/navigation_service.dart';
import 'package:bebikame/view/game_selection_view.dart';
import 'package:bebikame/viewmodel/provider/bgm_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]).then((_) {
    setupGetIt();
    runApp(const ProviderScope(child: MyApp()));
  });
  FlutterNativeSplash.remove();
}

final getIt = GetIt.instance;
void setupGetIt() {
  getIt.registerLazySingleton(() => NavigationService());
}

class MyApp extends HookConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bgmManager = ref.watch(bgmManagerProvider);

    useEffect(() {
      final observer = _AppLifecycleObserver(bgmManager);
      WidgetsBinding.instance.addObserver(observer);
      bgmManager.play();

      return () {
        WidgetsBinding.instance.removeObserver(observer);
        bgmManager.stop();
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

class _AppLifecycleObserver extends WidgetsBindingObserver {
  final BgmManager _bgmManager;

  _AppLifecycleObserver(this._bgmManager);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _bgmManager.pauseIfPlaying();
    } else if (state == AppLifecycleState.resumed) {
      _bgmManager.resumeIfPaused();
    }
  }
}
