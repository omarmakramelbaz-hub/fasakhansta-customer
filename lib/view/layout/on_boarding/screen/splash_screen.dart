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
      backgroundColor: const Color(0xFFF7F8FA),
      body: _buildOpeningView(),
      bottomNavigationBar: _buildApiStatusBar(),
    );
  }

  Widget _buildOpeningView() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 390;
        final logoCardSize = isCompact ? 178.0 : 205.0;
        final logoSize = isCompact ? 122.0 : 142.0;

        return Stack(
          fit: StackFit.expand,
          children: [
            const _SplashDecoration(),
            SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 850),
                      tween: Tween(begin: 0, end: 1),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: Transform.translate(
                            offset: Offset(0, 18 * (1 - value)),
                            child: Transform.scale(
                              scale: 0.94 + (0.06 * value),
                              child: child,
                            ),
                          ),
                        );
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: logoCardSize,
                            height: logoCardSize,
                            padding: const EdgeInsets.all(22),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF8F1),
                              borderRadius: BorderRadius.circular(38),
                              border: Border.all(
                                color: const Color(0xFFFFD6B4),
                                width: 1.15,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x17000000),
                                  blurRadius: 34,
                                  offset: Offset(0, 14),
                                ),
                                BoxShadow(
                                  color: Color(0x16FD7201),
                                  blurRadius: 42,
                                  spreadRadius: 2,
                                  offset: Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(28),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x0D000000),
                                    blurRadius: 16,
                                    offset: Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: CustomImage(
                                  path: AppImages.appLogo,
                                  type: ImageType.asset,
                                  width: logoSize,
                                  height: logoSize,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          Container(
                            width: 104,
                            height: 5,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFE6D1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            alignment: Alignment.centerLeft,
                            child: TweenAnimationBuilder<double>(
                              duration: const Duration(milliseconds: 1500),
                              tween: Tween(begin: 0.18, end: 0.72),
                              curve: Curves.easeInOutCubic,
                              builder: (context, value, _) {
                                return FractionallySizedBox(
                                  widthFactor: value,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          AppColors.mainAppColor,
                                          AppColors.gridTwoButtonColor,
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            'FASAKHANSTA',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF9A704F),
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 2.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildApiStatusBar() {
    return Container(
      height: 68,
      color: const Color(0xFFF7F8FA),
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
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
        context.read<PusherController>().initPusher(
              channelName: 'private-user.$id',
              userId: id,
              token: token,
            );
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
        content: const Text(
          'Biometric authentication failed. Please login again.',
        ),
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

class _SplashDecoration extends StatelessWidget {
  const _SplashDecoration();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: -115,
            right: -95,
            child: Container(
              width: 285,
              height: 285,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFFFE8D3),
              ),
            ),
          ),
          Positioned(
            top: 58,
            right: 48,
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(color: const Color(0xFFFFD6B4)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0E000000),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: -130,
            left: -105,
            child: Container(
              width: 310,
              height: 310,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFFFF0E3),
              ),
            ),
          ),
          Positioned(
            bottom: 102,
            left: 34,
            child: Container(
              width: 18,
              height: 18,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFFD7201),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
