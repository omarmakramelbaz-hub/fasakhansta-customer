import 'dart:async';

import 'package:flutter/material.dart';

import 'helpers/app/app.dart';
import 'helpers/app/init_services.dart';
import 'helpers/routes/app_routers_import.dart';
import 'helpers/translation/all_translation.dart';

/// Screenshot-only entry point used by GitHub Actions.
///
/// It is not referenced by the production Android/iOS builds. The requested
/// app route is supplied through `?route=...`, allowing App Store screenshots
/// to be rendered from the real application widgets at a fixed phone size.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive/assets first, then persist Arabic for the fresh browser
  // profile used by the screenshot runner.
  await initServices();
  await GlobalTranslations.setNewLanguage('ar');

  runApp(const MyApp());

  final requestedRoute = Uri.base.queryParameters['route'];
  if (requestedRoute == null || requestedRoute.isEmpty) return;

  WidgetsBinding.instance.addPostFrameCallback((_) {
    // Give MyApp enough time to create its navigator/provider tree, then bypass
    // guest navigation guards only for this screenshot-only entry point.
    Future<void>.delayed(const Duration(milliseconds: 900), () {
      final navigator = NamedNavigatorImpl.navigatorState.currentState;
      if (navigator == null) return;
      navigator.pushNamedAndRemoveUntil(requestedRoute, (_) => false);
    });
  });
}
