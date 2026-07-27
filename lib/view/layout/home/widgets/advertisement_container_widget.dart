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
    return Container(
      color: color,
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SizedBox(
                    width: context.width * 0.4,
                    child: Text(title,
                        style: AppTextStyle.text16MS().copyWith(height: 1.5, color: AppColors.whiteColor),
                        textAlign: context.languageCode == 'ar' ? TextAlign.start : TextAlign.end),
                  ),
                ),
                20.sbH,
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: InkWell(
                    onTap: () {
                      if (restaurantId != 0) {
                        NamedNavigatorImpl.push(
                          RestaurantDetailsScreen.routeName,
                          arguments: RestaurantDetailsArgs(id: restaurantId),
                        );
                      }
                    },
                    child: restaurantId != 0
                        ? Container(
                            decoration: BoxDecoration(
                              color: AppColors.whiteColor,
                              borderRadius: const BorderRadius.all(Radius.circular(10)),
                            ),
                            width: context.width * 0.28,
                            child: Center(
                              child: Text(
                                'buyNow'.tr,
                                style: AppTextStyle.text16MS().copyWith(height: context.languageCode == 'ar' ? 1.8 : 1),
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ),
                40.sbH,
              ],
            ),
          ),
          if (images.isNotEmpty || images != '')
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [Expanded(child: CustomNetworkImage(imageUrl: images))],
              ),
            ),
        ],
      ),
    );
  }
}
