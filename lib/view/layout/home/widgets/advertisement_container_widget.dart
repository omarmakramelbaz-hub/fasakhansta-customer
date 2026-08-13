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
              padding: const EdgeInsets.fromLTRB(14, 8, 10, 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: isArabic
                    ? CrossAxisAlignment.start
                    : CrossAxisAlignment.end,
                children: [
                  Flexible(
                    child: Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyle.text16BS().copyWith(
                        fontSize: 13.5,
                        height: 1.15,
                        color: AppColors.whiteColor,
                      ),
                      textAlign:
                          isArabic ? TextAlign.start : TextAlign.end,
                    ),
                  ),
                  if (restaurantId != 0) ...[
                    5.sbH,
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: openRestaurant,
                        borderRadius: BorderRadius.circular(9),
                        child: Container(
                          height: 26,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: AppColors.whiteColor,
                            borderRadius: BorderRadius.circular(9),
                            border: Border.all(
                              color: AppColors.mainAppColor.withOpacity(.25),
                              width: 1,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x22000000),
                                blurRadius: 5,
                                offset: Offset(0, 2),
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
                                  fontSize: 9.5,
                                  height: 1,
                                ),
                              ),
                              4.sbW,
                              Icon(
                                isArabic
                                    ? Icons.arrow_back_rounded
                                    : Icons.arrow_forward_rounded,
                                size: 13,
                                color: AppColors.mainAppColor,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
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
