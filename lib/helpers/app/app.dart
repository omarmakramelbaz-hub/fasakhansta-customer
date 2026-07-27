import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../view/layout/address/controller/address_controller.dart';
import '../../view/layout/auth/controller/auth_controller.dart';
import '../../view/layout/bottom_navigation/controller/advertising_controller.dart';
import '../../view/layout/cart/controller/cart_controller.dart';
import '../../view/layout/home/controller/home_controller.dart';
import '../../view/layout/on_boarding/screen/splash_screen.dart';
import '../../view/layout/orders/controller/last_order_controller.dart';
import '../../view/layout/request_delegate/controller/request_delegate_controller.dart';
import '../delivery_activity/delivery_provider.dart';
import '../pusher_service/pusher_controller.dart';
import '../routes/app_routers_import.dart';
import '../theme/theme.dart';
import '../translation/all_translation.dart';
import '../translation/main_app_bloc.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    mainAppBloc.getShared();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DeliveryProvider()),
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => HomeController()),
        ChangeNotifierProvider(create: (_) => AddressController()),
        ChangeNotifierProvider(create: (_) => RequestDelegateController()),
        ChangeNotifierProvider(create: (_) => AdvertisingController()..init()),
        ChangeNotifierProvider(create: (_) => CartController()..init()),
        ChangeNotifierProvider(create: (_) => PusherController()),
        ChangeNotifierProvider(create: (_) => LastCorderController()),
      ],
      child: StreamBuilder<String>(
        stream: mainAppBloc.langStream,
        builder: (context, lang) {
          if (lang.hasData) {
            return MaterialApp(
              title: 'FaskhaNinja',
              locale: Locale(lang.data!, ''),
              supportedLocales: GlobalTranslations.supportedLocales(),
              localizationsDelegates: context.localizationsDelegates,
              debugShowCheckedModeBanner: false,
              builder: BotToastInit(),
              navigatorObservers: [BotToastNavigatorObserver()],
              initialRoute: SplashScreen.routeName,
              onGenerateRoute: NamedNavigatorImpl.onGenerateRoute,
              navigatorKey: NamedNavigatorImpl.navigatorState,
              theme: theme(context),
            );
          } else {
            return Container();
          }
        },
      ),
    );
  }
}
