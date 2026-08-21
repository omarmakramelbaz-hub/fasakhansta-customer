import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';

import '../../../../helpers/hive/hive_methods.dart';
import '../../../../helpers/images/app_images.dart';
import '../../../../helpers/pusher_service/pusher_controller.dart';
import '../../../../helpers/routes/app_routers_import.dart';
import '../../../../helpers/theme/app_colors.dart';
import '../../../custom_widgets/api_response_widget/api_response_widget.dart';
import '../../../custom_widgets/custom_image/custom_image.dart';
import '../../auth/controller/auth_controller.dart';
import '../../auth/screen/login_screen.dart';
import '../../bottom_navigation/bottom_navigation_bar_screen.dart';
import '../../bottom_navigation/controller/advertising_controller.dart';
import 'on_boarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  static const String routeName = 'SplashScreen';

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _isBiometricCheckComplete = false;
  bool _isNavigationPending = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initial());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: AppColors.splachScreenColor,
      body: const Center(
        child: CustomImage(
          path: AppImages.userSplashGif,
          type: ImageType.asset,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
        ),
      ),
      bottomNavigationBar: _buildApiStatusBar(),
    );
  }

  Widget _buildApiStatusBar() {
    return SizedBox(
      height: 80,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Consumer<AuthController>(
          builder: (context, authController, _) {
            return ApiResponseWidget(
              apiResponse: authController.profileResponse,
              onReload: _getData,
              isEmpty: false,
              unauthorizedWidget: const SizedBox(),
              axis: Axis.horizontal,
              child: const SizedBox(),
            );
          },
        ),
      ),
    );
  }

  void _initial() {
    // Web is used only as a UI review preview. Do not block navigation on
    // profile/network requests that are required by the native app flow.
    if (kIsWeb) {
      _delayedNavigation(BottomNavigationBarScreen.routeName, seconds: 2);
      return;
    }

    if (HiveMethods.isFirstTime()) {
      _delayedNavigation(OnBoardingScreen.routeName, seconds: 2);
    } else if (HiveMethods.getToken() != null) {
      _getData();
    } else {
      _delayedNavigation(LoginScreen.routeName, seconds: 2);
    }
  }

  Future<bool> _checkBiometrics() async {
    // local_auth is for native platforms. Never call it on Flutter Web.
    if (kIsWeb || kDebugMode) return true;

    try {
      final canAuthenticate = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();

      if (!canAuthenticate || !isDeviceSupported) return true;

      return await _localAuth.authenticate(
        localizedReason: 'Authenticate to access your account',
        biometricOnly: false,
        persistAcrossBackgrounding: true,
      );
    } catch (e) {
      debugPrint('Biometric error: $e');
      return false;
    }
  }

  void _getData() {
    context.read<AuthController>().initialProfile();
    context.read<AdvertisingController>()
      ..initialAdvertising()
      ..getAdvertising();

    context.read<AuthController>().getProfile(
      onHaveIdANDToken: (id, token) {
        context.read<PusherController>().initPusher(channelName: 'private-user.$id', userId: id, token: token);
      },
      onSuccess: () async {
        if (!mounted || _isNavigationPending) return;

        await Future.delayed(const Duration(milliseconds: 5500));
        if (!mounted) return;

        final authController = context.read<AuthController>();
        if (authController.profile?.email == null) {
          _navigateToLogin();
          return;
        }

        final bioSuccess = await _checkBiometrics();
        _isBiometricCheckComplete = true;

        if (bioSuccess) {
          _navigateToHome();
        } else {
          _handleBiometricFailure();
        }
      },
      onUnauthenticated: () {
        if (!mounted || _isNavigationPending || _isBiometricCheckComplete) {
          return;
        }
        _delayedNavigation(LoginScreen.routeName, seconds: 4);
      },
    );
  }

  void _delayedNavigation(String routeName, {int seconds = 0}) {
    Future.delayed(Duration(seconds: seconds), () {
      if (!mounted || _isNavigationPending) return;
      _isNavigationPending = true;
      NamedNavigatorImpl.push(clean: true, routeName);
    });
  }

  void _navigateToHome() {
    if (!mounted || _isNavigationPending) return;
    _isNavigationPending = true;
    NamedNavigatorImpl.push(clean: true, BottomNavigationBarScreen.routeName);
  }

  void _navigateToLogin() {
    if (!mounted || _isNavigationPending) return;
    _isNavigationPending = true;
    NamedNavigatorImpl.push(clean: true, LoginScreen.routeName);
  }

  void _handleBiometricFailure() {
    if (!mounted || _isNavigationPending) return;
    _isNavigationPending = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Authentication Required'),
        content: const Text('Biometric authentication failed. Please login again.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _navigateToLogin();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
