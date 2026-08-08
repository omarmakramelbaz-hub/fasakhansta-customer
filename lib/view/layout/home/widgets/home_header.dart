import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../../helpers/extensions/extensions.dart';
import '../../../../helpers/hive/hive_methods.dart';
import '../../../../helpers/images/app_images.dart';
import '../../../../helpers/routes/app_routers_import.dart';
import '../../../../helpers/theme/app_colors.dart';
import '../../../../helpers/theme/app_text_style.dart';
import '../../auth/controller/auth_controller.dart';
import '../../cart/controller/cart_controller.dart';
import '../../cart/screen/cart_screen.dart';
import '../controller/home_controller.dart';

class HomeHeader extends StatelessWidget implements PreferredSizeWidget {
  final HomeController controller;

  const HomeHeader({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = HiveMethods.getToken() != null;
    final profile = context.watch<AuthController>().profile;
    final address = profile?.userAddresses?.isNotEmpty == true
        ? profile!.userAddresses!.first
        : null;
    final location = [address?.streetName, address?.cityName]
        .where((value) => value != null && value.trim().isNotEmpty)
        .join(' - ');

    return Container(
      height: 108,
      color: AppColors.mainAppColor,
      padding: const EdgeInsets.fromLTRB(16, 7, 16, 9),
      child: Column(
        children: [
          SizedBox(
            height: 52,
            child: Row(
              children: [
                _HeaderIcon(icon: AppImages.menuIcon, onTap: () {}),
                const Spacer(),
                Image.asset(
                  AppImages.appLogo,
                  height: 43,
                  fit: BoxFit.contain,
                ),
                const Spacer(),
                Row(
                  children: [
                    _NotificationIcon(count: profile?.notificaionsCount ?? 0),
                    9.sbW,
                    _buildCartIcon(context),
                  ],
                ),
              ],
            ),
          ),
          const Spacer(),
          if (isLoggedIn)
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 21),
                  4.sbW,
                  Flexible(
                    child: Text(
                      location.isEmpty ? 'اختر عنوان التوصيل' : location,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                      style: AppTextStyle.text13BS().copyWith(color: Colors.white),
                    ),
                  ),
                  5.sbW,
                  Text(
                    'التوصيل إلى',
                    style: AppTextStyle.text12RG().copyWith(color: Colors.white.withOpacity(.85)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCartIcon(BuildContext context) {
    final count = context.watch<CartController>().cart?.carts?.length ?? 0;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        _HeaderIcon(
          icon: AppImages.nCartIcon,
          onTap: () => NamedNavigatorImpl.push(CartScreen.routeName),
        ),
        if (count > 0)
          Positioned(
            right: -2,
            top: -3,
            child: _Badge(count: count),
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(108);
}

class _HeaderIcon extends StatelessWidget {
  final String icon;
  final VoidCallback onTap;

  const _HeaderIcon({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(26),
      child: Container(
        width: 44,
        height: 44,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.whiteColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.08),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: SvgPicture.asset(icon, color: AppColors.blackColor),
      ),
    );
  }
}

class _NotificationIcon extends StatelessWidget {
  final int count;

  const _NotificationIcon({required this.count});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        _HeaderIcon(icon: AppImages.notificationsIcon, onTap: () {}),
        if (count > 0)
          Positioned(
            right: -2,
            top: -3,
            child: _Badge(count: count),
          ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  final int count;

  const _Badge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: AppColors.redColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.whiteColor, width: 2),
      ),
      alignment: Alignment.center,
      child: Text(
        count > 99 ? '99+' : '$count',
        style: AppTextStyle.text12BW().copyWith(color: AppColors.whiteColor, height: 1),
      ),
    );
  }
}
