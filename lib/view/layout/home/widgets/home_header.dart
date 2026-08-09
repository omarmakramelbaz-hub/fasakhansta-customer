import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../helpers/routes/app_routers_import.dart';
import '../../../../helpers/theme/app_colors.dart';
import '../../../../helpers/theme/app_text_style.dart';
import '../../auth/controller/auth_controller.dart';
import '../../search/screen/search_screen.dart';
import '../controller/home_controller.dart';

class HomeHeader extends StatelessWidget implements PreferredSizeWidget {
  final HomeController controller;

  const HomeHeader({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<AuthController>().profile;
    final address = profile?.userAddresses?.isNotEmpty == true
        ? profile!.userAddresses!.first
        : null;
    final location = [address?.streetName, address?.cityName]
        .where((value) => value != null && value.trim().isNotEmpty)
        .join(' - ');

    return ClipPath(
      clipper: const _ReferenceHeaderClipper(),
      child: Container(
        height: 250,
        color: AppColors.mainAppColor,
        padding: const EdgeInsets.fromLTRB(28, 24, 28, 34),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 6,
              child: InkWell(
                onTap: () => NamedNavigatorImpl.push(SearchScreen.routeName),
                borderRadius: BorderRadius.circular(28),
                child: Container(
                  height: 82,
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  decoration: BoxDecoration(
                    color: AppColors.whiteColor,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search_rounded, size: 38, color: Colors.black),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'ابحث عن منتج أو فرع...',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
                          style: AppTextStyle.text16RS(color: AppColors.hintColor),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 28),
            Expanded(
              flex: 4,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(Icons.location_on_outlined, color: Colors.white, size: 52),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'التوصيل إلى',
                          style: AppTextStyle.text14RS().copyWith(color: Colors.white),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 22),
                            Flexible(
                              child: Text(
                                location.isEmpty ? 'اختر العنوان' : location,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.end,
                                style: AppTextStyle.text14BS().copyWith(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(250);
}

class _ReferenceHeaderClipper extends CustomClipper<Path> {
  const _ReferenceHeaderClipper();

  @override
  Path getClip(Size size) {
    final bottom = size.height - 18;
    final path = Path()..moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, bottom - 2);
    path.lineTo(size.width * .67, bottom + 5);
    path.lineTo(size.width * .34, bottom - 8);
    path.lineTo(0, bottom + 2);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
