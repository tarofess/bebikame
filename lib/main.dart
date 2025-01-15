import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:bebikame/view/router/router.dart';
import 'package:bebikame/get_it.dart';
import 'package:bebikame/view/theme/theme.dart';
import 'package:bebikame/view/widget/loading_indicator.dart';
import 'package:bebikame/view/error_view.dart';
import 'package:bebikame/provider/initialize_app_provider.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  setupGetIt();
  await setupOrientations();
  runApp(const ProviderScope(child: MyApp()));

  FlutterNativeSplash.remove();
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final initializeApp = ref.watch(initializeAppProvider);

    return ScreenUtilInit(
      designSize: const Size(690, 360),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return initializeApp.when(
          data: (_) {
            return MaterialApp.router(
              debugShowCheckedModeBanner: false,
              theme: createDefaultTheme(),
              routerConfig: ref.watch(routerProvider),
            );
          },
          loading: () {
            return const MaterialApp(
              debugShowCheckedModeBanner: false,
              home: Scaffold(
                body: LoadingIndicator(),
              ),
            );
          },
          error: (e, stackTrace) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              home: ErrorView(
                error: e,
                retry: () => ref.refresh(initializeAppProvider),
              ),
            );
          },
          skipLoadingOnRefresh: false,
        );
      },
    );
  }
}
