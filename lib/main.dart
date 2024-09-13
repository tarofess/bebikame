import 'package:bebikame/config/get_it.dart';
import 'package:bebikame/config/theme.dart';
import 'package:bebikame/service/dialog_service.dart';
import 'package:bebikame/view/game_selection_view.dart';
import 'package:bebikame/view/widget/loading_indicator.dart';
import 'package:bebikame/viewmodel/provider/initialize_app_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  setupGetIt();
  runApp(const ProviderScope(child: MyApp()));

  FlutterNativeSplash.remove();
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      theme: createTheme(),
      home: ScreenUtilInit(
        designSize: const Size(690, 360),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          final initializeApp = ref.watch(initializeAppProvider);

          return initializeApp.when(
            data: (_) => GameSelectionView(),
            loading: () {
              return const Scaffold(body: LoadingIndicator());
            },
            error: (e, _) {
              final dialogService = getIt<DialogService>();
              WidgetsBinding.instance.addPostFrameCallback((_) {
                dialogService.showErrorDialog(context, e.toString());
              });
              return GameSelectionView();
            },
          );
        },
      ),
    );
  }
}
