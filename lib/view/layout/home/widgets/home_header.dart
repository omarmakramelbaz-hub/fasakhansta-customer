import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../../helpers/extensions/extensions.dart';
import '../../../../helpers/hive/hive_methods.dart';
import '../../../../helpers/images/app_images.dart';
import '../../../../helpers/routes/app_routers_import.dart';
import '../../../../helpers/theme/app_colors.dart';
import '../../../../helpers/theme/app_text_style.dart';
import '../../../../helpers/translation/all_translation.dart';
import '../../auth/controller/auth_controller.dart';
import '../../cart/controller/cart_controller.dart';
import '../../cart/screen/cart_screen.dart';
import '../../search/screen/search_screen.dart';
import '../controller/home_controller.dart';
import 'current_city_widget.dart';

class HomeHeader extends StatelessWidget implements PreferredSizeWidget {
  final HomeController controller;

  const HomeHeader({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = HiveMethods.getToken() != null;

    return Container(
      height: 120,
      color: AppColors.mainAppColor,
      child: !isLoggedIn
          ? 0.sbH
          : Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text('deliveryTo'.tr, style: AppTextStyle.text18BW()),
                      CurrentCityWidget(
                        onCityChanged: () {
                          controller.getRestaurantsNearYou(lat: HiveMethods.getLat(), lng: HiveMethods.getLan());
                          controller.getCoupon();
                          controller.getPreviousOrder();
                          controller.getSpacialRestaurants(lat: HiveMethods.getLat(), lng: HiveMethods.getLan());
                          controller.getSlider();
                        },
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      if (context.read<AuthController>().profile?.appMultiVendor == null &&
                          HiveMethods.getToken() != null)
                        InkWell(
                          onTap: () {
                            NamedNavigatorImpl.push(SearchScreen.routeName);
                          },
                          child: CircleAvatar(
                              radius: 20,
                              backgroundColor: AppColors.whiteColor,
                              child: SvgPicture.asset(AppImages.searchIcon, color: AppColors.blackColor)),
                        ),
                      15.sbW,
                      _buildCartIcon(context),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildCartIcon(BuildContext context) {
    return InkWell(
      onTap: () => NamedNavigatorImpl.push(CartScreen.routeName),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          SvgPicture.asset(AppImages.nCartIcon),
          Positioned(
            bottom: 0,
            right: -2,
            child: CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.mainAppColor,
              child: InkWell(
                onTap: () => NamedNavigatorImpl.push(CartScreen.routeName),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    SvgPicture.asset(AppImages.nCartIcon),
                    Positioned(
                      bottom: 0,
                      right: -2,
                      child: CircleAvatar(
                        radius: 8,
                        backgroundColor: AppColors.darkMainAppColor,
                        child: Text(
                          context.read<CartController>().cart?.carts?.length.toString() ?? '0',
                          // context.read<HomeController>().countCart.toString(),
                          style: AppTextStyle.text16BW().copyWith(
                            height: 1.4,
                            fontSize: 14,
                            color: AppColors.whiteColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(120);
}
