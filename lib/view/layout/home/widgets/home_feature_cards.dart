import 'package:flutter/material.dart';

import '../../../../helpers/routes/app_routers_import.dart';
import '../../../../helpers/theme/app_colors.dart';
import '../../../../helpers/theme/app_text_style.dart';
import '../controller/home_controller.dart';
import '../screen/draw_resturant_screen.dart';
import '../../restaurants/screen/restaurant_details_screen.dart';

class HomeFeatureCards extends StatelessWidget {
  final HomeController controller;

  const HomeFeatureCards({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(48, 8, 48, 0),
      child: Row(
        children: [
          Expanded(
            child: _FeatureCard(
              background: const Color(0xFF0D2E47),
              title: 'المسابقة اليومية',
              subtitle: 'اربح جوائز قيمة\nكل يوم',
              button: 'شارك الآن',
              icon: Icons.card_giftcard_rounded,
              iconColor: AppColors.mainAppColor,
              titleColor: Colors.white,
              subtitleColor: Colors.white,
              onTap: () => NamedNavigatorImpl.push(DrawRestaurantScreen.routeName),
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: _FeatureCard(
              background: const Color(0xFFFFF3E5),
              title: 'المطاعم المميزة',
              subtitle: 'أفضل المطاعم\nوأعلى التقييمات',
              button: 'اكتشف الآن',
              icon: Icons.emoji_events_rounded,
              iconColor: AppColors.mainAppColor,
              titleColor: AppColors.blackColor,
              subtitleColor: AppColors.greyColor,
              onTap: () {
                if (controller.spacialRestaurants.isNotEmpty) {
                  NamedNavigatorImpl.push(
                    RestaurantDetailsScreen.routeName,
                    arguments: RestaurantDetailsArgs(
                      id: controller.spacialRestaurants.first.id ?? 0,
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final Color background;
  final String title;
  final String subtitle;
  final String button;
  final IconData icon;
  final Color iconColor;
  final Color titleColor;
  final Color subtitleColor;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.background,
    required this.title,
    required this.subtitle,
    required this.button,
    required this.icon,
    required this.iconColor,
    required this.titleColor,
    required this.subtitleColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        height: 172,
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.borderColorContainer.withOpacity(.5)),
        ),
        child: Row(
          textDirection: TextDirection.rtl,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.10),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 52, color: iconColor),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.right,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyle.text15BS().copyWith(color: titleColor),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    textAlign: TextAlign.right,
                    maxLines: 2,
                    style: AppTextStyle.text12RS().copyWith(
                      color: subtitleColor,
                      height: 1.45,
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    height: 42,
                    child: ElevatedButton(
                      onPressed: onTap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.mainAppColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13),
                        ),
                      ),
                      child: Text(button, style: AppTextStyle.text12BS(color: Colors.white)),
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
}
