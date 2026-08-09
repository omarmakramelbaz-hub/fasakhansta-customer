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
      clipper: _SharpHeaderClipper(),
      child: Container(
        height: 168,
        color: AppColors.mainAppColor,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 6,
              child: InkWell(
                onTap: () => NamedNavigatorImpl.push(SearchScreen.routeName),
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: AppColors.whiteColor,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search_rounded, size: 27, color: Colors.black),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'ابحث عن منتج أو فرع...',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
                          style: AppTextStyle.text14RS(color: AppColors.hintColor),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 4,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Icon(Icons.location_on_outlined, color: Colors.white, size: 28),
                  const SizedBox(width: 5),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'التوصيل إلى',
                          style: AppTextStyle.text11RG().copyWith(color: Colors.white.withOpacity(.9)),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 18),
                            Flexible(
                              child: Text(
                                location.isEmpty ? 'اختر العنوان' : location,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.end,
                                style: AppTextStyle.text12BS().copyWith(color: Colors.white),
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
  Size get preferredSize => const Size.fromHeight(168);
}

class _SharpHeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path()..moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height - 22);
    path.lineTo(size.width * .76, size.height - 14);
    path.lineTo(size.width * .50, size.height - 22);
    path.lineTo(size.width * .24, size.height - 14);
    path.lineTo(0, size.height - 22);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
