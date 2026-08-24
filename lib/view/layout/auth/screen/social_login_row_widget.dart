import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../helpers/hive/hive_methods.dart';
import '../../../../helpers/images/app_images.dart';
import '../../../../helpers/pusher_service/pusher_controller.dart';
import '../../../../helpers/routes/app_routers_import.dart';
import '../../../../helpers/theme/app_colors.dart';
import '../../../../helpers/theme/app_text_style.dart';
import '../../bottom_navigation/bottom_navigation_bar_screen.dart';
import '../controller/auth_controller.dart';
import 'create_new_account_screen.dart';

class SocialBtn extends StatelessWidget {
  final String image;
  final String label;
  final VoidCallback onTap;

  const SocialBtn({
    super.key,
    required this.image,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: Ink(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: const Color(0xFFE4E7EB)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0D000000),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 30,
                  height: 30,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAFAFA),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Image.asset(
                    image,
                    width: 22,
                    height: 22,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(width: 7),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyle.text12BS().copyWith(
                      color: const Color(0xFF30343A),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SocialLoginRowWidget extends StatelessWidget {
  const SocialLoginRowWidget({super.key});

  void _onAuthSuccess(
    BuildContext context,
    int register,
    String? mobileVerifiedAt,
  ) {
    HiveMethods.updateIsVisitor(false);
    if (register == 0 && mobileVerifiedAt != null) {
      NamedNavigatorImpl.push(
        BottomNavigationBarScreen.routeName,
        replace: true,
      );
    } else {
      NamedNavigatorImpl.push(
        BottomNavigationBarScreen.routeName,
        clean: true,
      );
    }
  }

  void _initPusher(BuildContext context, int id, String token) {
    context.read<PusherController>().initPusher(
          channelName: 'private-user.$id',
          userId: id,
          token: token,
        );
  }

  @override
  Widget build(BuildContext context) {
    final showAppleLogin =
        !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEEF0F3)),
      ),
      child: Row(
        children: [
          if (showAppleLogin) ...[
            SocialBtn(
              image: AppImages.appleLoginIcon,
              label: 'Apple',
              onTap: () {
                context.read<AuthController>().signInWithApple(
                      onSuccess: (register, mobileVerifiedAt) =>
                          _onAuthSuccess(
                        context,
                        register,
                        mobileVerifiedAt,
                      ),
                      onFirstTime: () => NamedNavigatorImpl.push(
                        CreateNewAccountScreen.routeName,
                      ),
                      onHaveIdANDToken: (id, token) =>
                          _initPusher(context, id, token),
                    );
              },
            ),
            const SizedBox(width: 8),
          ],
          SocialBtn(
            image: AppImages.googleIcon,
            label: 'Google',
            onTap: () {
              context.read<AuthController>().signInWithGoogle(
                    onSuccess: (register, mobileVerifiedAt) =>
                        _onAuthSuccess(
                      context,
                      register,
                      mobileVerifiedAt,
                    ),
                    onFirstTime: () => NamedNavigatorImpl.push(
                      CreateNewAccountScreen.routeName,
                    ),
                    onHaveIdANDToken: (id, token) =>
                        _initPusher(context, id, token),
                  );
            },
          ),
          const SizedBox(width: 8),
          SocialBtn(
            image: AppImages.facebookIcon,
            label: 'Facebook',
            onTap: () {
              context.read<AuthController>().signInWithFacebook(
                    onSuccess: (register, mobileVerifiedAt) =>
                        _onAuthSuccess(
                      context,
                      register,
                      mobileVerifiedAt,
                    ),
                    onFirstTime: () => NamedNavigatorImpl.push(
                      CreateNewAccountScreen.routeName,
                    ),
                    onHaveIdANDToken: (id, token) =>
                        _initPusher(context, id, token),
                  );
            },
          ),
        ],
      ),
    );
  }
}
