import 'package:flutter/material.dart';

import '../../../../helpers/routes/app_routers_import.dart';
import '../../../../helpers/theme/app_colors.dart';
import '../../../../helpers/theme/app_text_style.dart';
import '../controller/home_controller.dart';
import '../screen/draw_resturant_screen.dart';

class HomeFeatureCards extends StatelessWidget {
  final HomeController controller;

  const HomeFeatureCards({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: InkWell(
        onTap: () => NamedNavigatorImpl.push(DrawRestaurantScreen.routeName),
        borderRadius: BorderRadius.circular(22),
        child: Container(
          height: 140,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF102F4A), Color(0xFF0A2135)],
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: AppColors.mainAppColor.withOpacity(.28),
              width: 1.2,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x26000000),
                blurRadius: 14,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                flex: 42,
                child: Center(
                  child: Container(
                    width: 92,
                    height: 92,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(.07),
                      border: Border.all(
                        color: AppColors.mainAppColor.withOpacity(.45),
                        width: 1.4,
                      ),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const Icon(
                          Icons.card_giftcard_rounded,
                          size: 58,
                          color: Color(0xFFFF8A00),
                        ),
                        Positioned(
                          top: 12,
                          right: 10,
                          child: Icon(
                            Icons.auto_awesome_rounded,
                            size: 18,
                            color: Colors.white.withOpacity(.92),
                          ),
                        ),
                        Positioned(
                          bottom: 12,
                          left: 12,
                          child: Icon(
                            Icons.auto_awesome_rounded,
                            size: 14,
                            color: AppColors.mainAppColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                flex: 58,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'المسابقة اليومية',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                      style: AppTextStyle.text18BS().copyWith(
                        color: Colors.white,
                        fontSize: 19,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'اربح جوائز قيمة كل يوم',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                      style: AppTextStyle.text13BS().copyWith(
                        color: AppColors.mainAppColor,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'شارك الآن وكن من الفائزين المحظوظين',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                      style: AppTextStyle.text10RG().copyWith(
                        color: Colors.white.withOpacity(.82),
                        fontSize: 11,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 9),
                    SizedBox(
                      height: 32,
                      child: ElevatedButton.icon(
                        onPressed: () => NamedNavigatorImpl.push(DrawRestaurantScreen.routeName),
                        icon: const Icon(Icons.card_giftcard_rounded, size: 15),
                        label: const Text('شارك الآن'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.mainAppColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(11),
                          ),
                          textStyle: AppTextStyle.text11BW(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
