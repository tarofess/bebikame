import 'dart:ui';

import 'package:bebikame/config/get_it.dart';
import 'package:bebikame/firebase_options.dart';
import 'package:bebikame/service/audio_service.dart';
import 'package:bebikame/service/in_app_purchase_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final _audioService = getIt<AudioService>();
final _inAppPurchaseService = getIt<InAppPurchaseService>();

final initializeAppProvider = FutureProvider.autoDispose((ref) async {
  await setupFirebase();
  await _inAppPurchaseService.initialize();
  await _audioService.play('bgm', loop: true, volume: 0.3);
});

Future<void> setupFirebase() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
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
