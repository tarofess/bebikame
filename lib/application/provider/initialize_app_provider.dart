import 'dart:io';
import 'dart:ui';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:bebikame/service/get_it.dart';
import 'package:bebikame/firebase_options.dart';
import 'package:bebikame/application/provider/is_enable_in_app_purchase_provider.dart';
import 'package:bebikame/service/audio_service.dart';
import 'package:bebikame/service/in_app_purchase_service.dart';

final _audioService = getIt<AudioService>();
final _inAppPurchaseService = getIt<InAppPurchaseService>();

final initializeAppProvider = FutureProvider.autoDispose((ref) async {
  final isAppInPurchaseAvailable = await _inAppPurchaseService.initialize();
  ref.read(isEnableInAppPurchaseProvider.notifier).state =
      isAppInPurchaseAvailable;

  await setupFirebase();
  await _audioService.play('bgm', loop: true, volume: 0.3);
});

Future<void> setupFirebase() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    FlutterError.onError = (errorDetails) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    };
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  } catch (e) {
    throw Exception('Firebaseの初期化に失敗しました');
  }
}

Future<void> setupOrientations() async {
  await SystemChrome.setPreferredOrientations([
    Platform.isAndroid
        ? DeviceOrientation.landscapeLeft
        : DeviceOrientation.landscapeRight,
  ]);
}
