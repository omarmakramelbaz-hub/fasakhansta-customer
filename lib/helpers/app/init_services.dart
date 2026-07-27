import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../notification_helper/firebase_options.dart';
import '../notification_helper/notification_helper.dart';
import '../translation/all_translation.dart';
import '../utils/date_methods.dart';
import '../utils/http_overrides.dart';

Future<void> initServices() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseNotifications.setUpFirebase();
  await Hive.initFlutter();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  await Hive.openBox('app');
  await GlobalTranslations.init();
  initTimeago();
  HttpOverrides.global = MyHttpOverrides();
}
