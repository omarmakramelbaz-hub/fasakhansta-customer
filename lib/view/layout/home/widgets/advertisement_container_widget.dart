import 'package:flutter/material.dart';

import '../../../../helpers/extensions/extensions.dart';
import '../../../../helpers/routes/app_routers_import.dart';
import '../../../../helpers/theme/app_colors.dart';
import '../../../../helpers/theme/app_text_style.dart';
import '../../../../helpers/translation/all_translation.dart';
import '../../../custom_widgets/custom_image/custom_network_image.dart';
import '../../restaurants/screen/restaurant_details_screen.dart';

class AdvertisementContainerWidget extends StatelessWidget {
  final String images;
  final String title;
  final int restaurantId;
  final Color color;

  const AdvertisementContainerWidget({
    super.key,
    required this.images,
    required this.title,
    required this.restaurantId,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isArabic = context.languageCode == 'ar';

    void openRestaurant() {
      if (restaurantId == 0) return;
      NamedNavigatorImpl.push(
        RestaurantDetailsScreen.routeName,
        arguments: RestaurantDetailsArgs(id: restaurantId),
      );
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [color, color.withOpacity(.92)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(.22), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x26000000),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          Expanded(
            flex: 54,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: isArabic ? CrossAxisAlignment.start : CrossAxisAlignment.end,
                children: [
                  if (restaurantId != 0)
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: openRestaurant,
                        borderRadius: BorderRadius.circular(18),
                        child: Container(
                          height: 30,
                          padding: const EdgeInsets.symmetric(horizontal: 11),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(.96),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: AppColors.mainAppColor.withOpacity(.35),
                              width: 1,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x24000000),
                                blurRadius: 7,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.storefront_rounded,
                                size: 15,
                                color: AppColors.mainAppColor,
                              ),
                              6.sbW,
                              Text(
                                'عرض المطعم',
                                style: AppTextStyle.text12BS().copyWith(
                                  color: AppColors.blackColor,
                                  fontSize: 10.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(.15),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Colors.white.withOpacity(.16)),
                      ),
                      child: Text(
                        'FASAKHANSTA',
                        style: AppTextStyle.text12BW().copyWith(
                          color: AppColors.whiteColor,
                          fontSize: 10,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ),
                  8.sbH,
                  Text(
                    title,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyle.text16BS().copyWith(
                      fontSize: 16,
                      height: 1.3,
                      color: AppColors.whiteColor,
                    ),
                    textAlign: isArabic ? TextAlign.start : TextAlign.end,
                  ),
                  9.sbH,
                  if (restaurantId != 0)
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: openRestaurant,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          height: 36,
                          padding: const EdgeInsets.symmetric(horizontal: 13),
                          decoration: BoxDecoration(
                            color: AppColors.whiteColor,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x26000000),
                                blurRadius: 7,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'buyNow'.tr,
                                style: AppTextStyle.text12BS().copyWith(
                                  color: AppColors.blackColor,
                                  fontSize: 11,
                                ),
                              ),
                              6.sbW,
                              Icon(
                                isArabic ? Icons.arrow_back_rounded : Icons.arrow_forward_rounded,
                                size: 16,
                                color: AppColors.mainAppColor,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 46,
            child: images.trim().isEmpty
                ? const SizedBox.expand()
                : ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(isArabic ? 0 : 20),
                      bottomLeft: Radius.circular(isArabic ? 0 : 20),
                      topRight: Radius.circular(isArabic ? 20 : 0),
                      bottomRight: Radius.circular(isArabic ? 20 : 0),
                    ),
                    child: CustomNetworkImage(
                      imageUrl: images,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
