import 'dart:async';

import 'package:flutter/material.dart';

import 'helpers/app/app.dart';
import 'helpers/app/init_services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initServices();
  runApp(const MyApp());
}
