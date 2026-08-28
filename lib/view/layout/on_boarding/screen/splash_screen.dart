import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../../../../helpers/hive/hive_methods.dart';
import '../../../../helpers/images/app_images.dart';
import '../../../../helpers/pusher_service/pusher_controller.dart';
import '../../../../helpers/routes/app_routers_import.dart';
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
  static const Duration _minimumSplashDuration = Duration(milliseconds: 6300);
  static const List<String> _videoChunks = [
    'assets/splash_video/part_00.b64',
    'assets/splash_video/part_01.b64',
    'assets/splash_video/part_02.b64',
    'assets/splash_video/part_03.b64',
    'assets/splash_video/part_04.b64',
    'assets/splash_video/part_05.b64',
    'assets/splash_video/part_06.b64',
    'assets/splash_video/part_07.b64',
  ];

  final LocalAuthentication _localAuth = LocalAuthentication();
  late final DateTime _minimumSplashEndsAt;
  VideoPlayerController? _videoController;
  bool _videoReady = false;
  bool _videoFailed = false;
  bool _isBiometricCheckComplete = false;
  bool _isNavigationPending = false;
  bool _isBiometricDialogOpen = false;

  @override
  void initState() {
    super.initState();
    _minimumSplashEndsAt = DateTime.now().add(_minimumSplashDuration);
    _prepareOpeningVideo();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initial());
  }

  Future<void> _prepareOpeningVideo() async {
    try {
      final encoded = StringBuffer();
      for (final path in _videoChunks) {
        final chunk = await rootBundle.loadString(path);
        encoded.write(chunk.replaceAll(RegExp(r'\s+'), ''));
      }

      final controller = VideoPlayerController.networkUrl(
        Uri.parse('data:video/mp4;base64,${encoded.toString()}'),
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
      );
      _videoController = controller;

      await controller.initialize();
      await controller.setLooping(false);
      await controller.setVolume(0);

      if (!mounted) {
        await controller.dispose();
        return;
      }

      setState(() => _videoReady = true);
      await controller.play();
    } catch (error, stackTrace) {
      debugPrint('Opening splash video error: $error');
      debugPrintStack(stackTrace: stackTrace);
      if (mounted) {
        setState(() => _videoFailed = true);
      }
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _videoController;

    return Scaffold(
      backgroundColor: const Color(0xFF69B7CF),
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (_videoReady && controller != null)
            _buildVideo(controller)
          else
            _buildLoadingFallback(),
          if (_videoFailed)
            const Positioned(
              left: 0,
              right: 0,
              bottom: 24,
              child: SizedBox.shrink(),
            ),
        ],
      ),
    );
  }

  Widget _buildVideo(VideoPlayerController controller) {
    final size = controller.value.size;
    return ClipRect(
      child: SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.cover,
          alignment: Alignment.center,
          child: SizedBox(
            width: size.width,
            height: size.height,
            child: VideoPlayer(controller),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingFallback() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF72BED3), Color(0xFF2D88AC)],
        ),
      ),
      alignment: Alignment.center,
      child: Container(
        width: 132,
        height: 132,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.94),
          shape: BoxShape.circle,
          boxShadow: const [
            BoxShadow(
              color: Color(0x25000000),
              blurRadius: 26,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: const CustomImage(
          path: AppImages.appLogo,
          type: ImageType.asset,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Duration get _remainingSplashDuration {
    final remaining = _minimumSplashEndsAt.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  void _initial() {
    // Web is used as a UI review preview. Keep the same routing behaviour,
    // but let the complete opening video play before leaving the splash.
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
        if (!mounted || _isNavigationPending) return;

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
    final requestedDelay = Duration(seconds: seconds);
    final remaining = _remainingSplashDuration;
    final delay = requestedDelay > remaining ? requestedDelay : remaining;
    _scheduleNavigation(routeName, delay);
  }

  void _scheduleNavigation(String routeName, Duration delay) {
    if (!mounted || _isNavigationPending) return;
    _isNavigationPending = true;

    Future.delayed(delay, () {
      if (!mounted) return;
      NamedNavigatorImpl.push(clean: true, routeName);
    });
  }

  void _navigateToHome() {
    _scheduleNavigation(
      BottomNavigationBarScreen.routeName,
      _remainingSplashDuration,
    );
  }

  void _navigateToLogin() {
    _scheduleNavigation(
      LoginScreen.routeName,
      _remainingSplashDuration,
    );
  }

  void _handleBiometricFailure() {
    if (!mounted || _isNavigationPending || _isBiometricDialogOpen) return;
    _isBiometricDialogOpen = true;

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
              _isBiometricDialogOpen = false;
              _navigateToLogin();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
