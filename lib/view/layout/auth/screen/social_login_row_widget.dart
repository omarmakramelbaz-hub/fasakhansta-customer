import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../helpers/extensions/extensions.dart';
import '../../../../helpers/hive/hive_methods.dart';
import '../../../../helpers/images/app_images.dart';
import '../../../../helpers/pusher_service/pusher_controller.dart';
import '../../../../helpers/routes/app_routers_import.dart';
import '../../bottom_navigation/bottom_navigation_bar_screen.dart';
import '../controller/auth_controller.dart';
import 'create_new_account_screen.dart';

class SocialBtn extends StatelessWidget {
  final String image;
  final VoidCallback onTap;

  const SocialBtn({super.key, required this.image, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        width: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              offset: const Offset(0, 0),
              blurRadius: 6,
            )
          ],
        ),
        child: Image.asset(image),
      ),
    );
  }
}

class SocialLoginRowWidget extends StatelessWidget {
  const SocialLoginRowWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (Platform.isIOS) ...[
          SocialBtn(
            image: AppImages.appleLoginIcon,
            onTap: () {
              context.read<AuthController>().signInWithApple(
                onSuccess: (register, mobileVerifiedAt) {
                  if (register == 0 && mobileVerifiedAt != null) {
                    HiveMethods.updateIsVisitor(false);
                    NamedNavigatorImpl.push(BottomNavigationBarScreen.routeName, replace: true);
                  } else {
                    HiveMethods.updateIsVisitor(false);
                    NamedNavigatorImpl.push(BottomNavigationBarScreen.routeName, clean: true);
                  }
                },
                onFirstTime: () {
                  NamedNavigatorImpl.push(CreateNewAccountScreen.routeName);
                },
                onHaveIdANDToken: (id, token) {
                  context.read<PusherController>().initPusher(
                        channelName: 'private-user.$id',
                        userId: id,
                        token: token,
                      );
                },
              );
            },
          ),
          40.sbW,
        ],
        SocialBtn(
          image: AppImages.googleIcon,
          onTap: () {
            context.read<AuthController>().signInWithGoogle(
              onSuccess: (register, mobileVerifiedAt) {
                if (register == 0 && mobileVerifiedAt != null) {
                  HiveMethods.updateIsVisitor(false);
                  NamedNavigatorImpl.push(BottomNavigationBarScreen.routeName, replace: true);
                } else {
                  HiveMethods.updateIsVisitor(false);
                  NamedNavigatorImpl.push(BottomNavigationBarScreen.routeName, clean: true);
                }
              },
              onFirstTime: () {
                NamedNavigatorImpl.push(CreateNewAccountScreen.routeName);
              },
              onHaveIdANDToken: (id, token) {
                context.read<PusherController>().initPusher(
                      channelName: 'private-user.$id',
                      userId: id,
                      token: token,
                    );
              },
            );
          },
        ),
        40.sbW,
        SocialBtn(
          image: AppImages.facebookIcon,
          onTap: () {
            context.read<AuthController>().signInWithFacebook(
              onSuccess: (register, mobileVerifiedAt) {
                if (register == 0 && mobileVerifiedAt != null) {
                  HiveMethods.updateIsVisitor(false);
                  NamedNavigatorImpl.push(BottomNavigationBarScreen.routeName, replace: true);
                } else {
                  HiveMethods.updateIsVisitor(false);
                  NamedNavigatorImpl.push(BottomNavigationBarScreen.routeName, clean: true);
                }
              },
              onFirstTime: () {
                NamedNavigatorImpl.push(CreateNewAccountScreen.routeName);
              },
              onHaveIdANDToken: (id, token) {
                context.read<PusherController>().initPusher(
                      channelName: 'private-user.$id',
                      userId: id,
                      token: token,
                    );
              },
            );
          },
        ),
      ],
    );
  }
}
