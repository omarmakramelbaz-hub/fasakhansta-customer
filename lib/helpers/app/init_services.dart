import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../notification_helper/firebase_options.dart';
import '../notification_helper/notification_helper.dart';
import '../translation/all_translation.dart';
import '../utils/date_methods.dart';
import '../utils/http_overrides.dart';

Future<void> initServices() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // The current notification implementation uses dart:io/mobile-only APIs.
  // Skip its initialization on Flutter Web so app startup does not crash there.
  if (!kIsWeb) {
    await FirebaseNotifications.setUpFirebase();
  }

  await Hive.initFlutter();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await Hive.openBox('app');
  await GlobalTranslations.init();
  initTimeago();
  HttpOverrides.global = MyHttpOverrides();
}
