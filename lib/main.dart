import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:bebikame/get_it.dart';
import 'package:bebikame/view/theme/theme.dart';
import 'package:bebikame/view/game_selection_view.dart';
import 'package:bebikame/view/widget/loading_indicator.dart';
import 'package:bebikame/provider/initialize_app_provider.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await SystemChrome.setPreferredOrientations([
    Platform.isAndroid
        ? DeviceOrientation.landscapeLeft
        : DeviceOrientation.landscapeRight,
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
      debugShowCheckedModeBanner: false,
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
              return ErrorScreen(
                error: e,
                retry: () => ref.refresh(initializeAppProvider),
              );
            },
            skipLoadingOnRefresh: false,
          );
        },
      ),
    );
  }
}

class ErrorScreen extends StatelessWidget {
  final Object? error;
  final VoidCallback retry;

  const ErrorScreen({super.key, this.error, required this.retry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('アプリの初期化に失敗しました。\n再度お試しください。'),
            SizedBox(height: 16.r),
            Text(
              '$error',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.r),
            ElevatedButton(
              onPressed: retry,
              child: const Text('リトライ'),
            ),
          ],
        ),
      ),
    );
  }
}
