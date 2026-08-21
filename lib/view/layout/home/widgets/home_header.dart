import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../helpers/hive/hive_methods.dart';
import '../../../../helpers/theme/app_colors.dart';
import '../../../../helpers/theme/app_text_style.dart';
import '../../auth/controller/auth_controller.dart';
import '../controller/home_controller.dart';

class HomeHeader extends StatelessWidget implements PreferredSizeWidget {
  final HomeController controller;
  final VoidCallback? onAddressTap;

  const HomeHeader({
    super.key,
    required this.controller,
    this.onAddressTap,
  });

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<AuthController>().profile;
    final firstAddress =
        profile?.userAddresses?.isNotEmpty == true ? profile!.userAddresses!.first : null;
    final savedCity = HiveMethods.getCity()?.trim() ?? '';
    final fallbackLocation = [firstAddress?.streetName, firstAddress?.cityName]
        .where((value) => value != null && value.trim().isNotEmpty)
        .join(' - ');
    final location = savedCity.isNotEmpty ? savedCity : fallbackLocation;

    return ClipPath(
      clipper: const _FiveAngleHeaderClipper(),
      child: Container(
        height: 160,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFF6800),
              Color(0xFFFD7201),
              Color(0xFFFF8B21),
            ],
            stops: [0, .55, 1],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 15, 12, 22),
            child: Align(
              alignment: Alignment.topRight,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onAddressTap,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                    child: Directionality(
                      textDirection: TextDirection.ltr,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 230),
                            child: Padding(
                              padding: const EdgeInsets.only(top: 1),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.keyboard_arrow_down_rounded,
                                        color: Colors.white,
                                        size: 15,
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                        'التوصيل إلى',
                                        textDirection: TextDirection.rtl,
                                        style: AppTextStyle.text12BS().copyWith(
                                          color: Colors.white,
                                          fontSize: 10.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    location.isEmpty ? 'اختر العنوان' : location,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.right,
                                    textDirection: TextDirection.rtl,
                                    style: AppTextStyle.text12BS().copyWith(
                                      color: Colors.white,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          const _LocationButton(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(160);
}

class _LocationButton extends StatelessWidget {
  const _LocationButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Icon(
        Icons.location_on_outlined,
        color: AppColors.mainAppColor,
        size: 20,
      ),
    );
  }
}

class _FiveAngleHeaderClipper extends CustomClipper<Path> {
  const _FiveAngleHeaderClipper();

  @override
  Path getClip(Size size) {
    final h = size.height;
    final w = size.width;

    // Five light, sharp broken angles across the lower orange edge.
    return Path()
      ..moveTo(0, 0)
      ..lineTo(w, 0)
      ..lineTo(w, h - 15)
      ..lineTo(w * .82, h - 3)
      ..lineTo(w * .64, h - 15)
      ..lineTo(w * .50, h - 3)
      ..lineTo(w * .36, h - 15)
      ..lineTo(w * .18, h - 3)
      ..lineTo(0, h - 15)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
