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

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            color,
            color.withOpacity(.88),
          ],
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 47,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 10, 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: isArabic ? CrossAxisAlignment.start : CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.16),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'FASAKHANSTA',
                      style: AppTextStyle.text12BW().copyWith(
                        color: AppColors.whiteColor,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  10.sbH,
                  Text(
                    title,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyle.text16BS().copyWith(
                      fontSize: 18,
                      height: 1.35,
                      color: AppColors.whiteColor,
                    ),
                    textAlign: isArabic ? TextAlign.start : TextAlign.end,
                  ),
                  14.sbH,
                  if (restaurantId != 0)
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => NamedNavigatorImpl.push(
                          RestaurantDetailsScreen.routeName,
                          arguments: RestaurantDetailsArgs(id: restaurantId),
                        ),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          height: 42,
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          decoration: BoxDecoration(
                            color: AppColors.whiteColor,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(.12),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'buyNow'.tr,
                                style: AppTextStyle.text14BS().copyWith(
                                  color: AppColors.blackColor,
                                ),
                              ),
                              7.sbW,
                              Icon(
                                isArabic ? Icons.arrow_back_rounded : Icons.arrow_forward_rounded,
                                size: 18,
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
            flex: 53,
            child: images.trim().isEmpty
                ? const SizedBox.expand()
                : ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(isArabic ? 0 : 18),
                      bottomLeft: Radius.circular(isArabic ? 0 : 18),
                      topRight: Radius.circular(isArabic ? 18 : 0),
                      bottomRight: Radius.circular(isArabic ? 18 : 0),
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
