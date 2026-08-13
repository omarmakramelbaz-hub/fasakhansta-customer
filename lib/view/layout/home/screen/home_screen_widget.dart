import 'package:flutter/material.dart';

import '../../../../helpers/extensions/extensions.dart';
import '../../../../helpers/hive/hive_methods.dart';
import '../../../../helpers/theme/app_colors.dart';
import '../../../../helpers/theme/app_text_style.dart';
import '../../../../helpers/translation/all_translation.dart';
import '../../../custom_widgets/custom_slider/custom_slider.dart';
import '../controller/home_controller.dart';
import '../widgets/advertisement_container_widget.dart';
import '../widgets/restaurants_near_you_list_view_widget.dart';
import '../widgets/spacial_rest_widget.dart';

class SliderWidget extends StatelessWidget {
  final HomeController controller;

  const SliderWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final sliderData = controller.slider.isEmpty ? controller.defaultSlider : controller.slider;

    if (sliderData.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 2),
      child: CustomSlider(
        color: AppColors.mainAppColor,
        hasDots: sliderData.length > 1,
        isDotsOnContent: false,
        aspectRatio: 2.7,
        radius: 22,
        sliderArguments: List.generate(
          sliderData.length,
          (index) => SliderArguments(
            child: AdvertisementContainerWidget(
              restaurantId: sliderData[index].resturantId ?? 0,
              images: sliderData[index].imgaes?.isNotEmpty == true
                  ? sliderData[index].imgaes![0].url ?? ''
                  : '',
              title: sliderData[index].title ?? '',
              color: AppColors.mainAppColor,
            ),
          ),
        ),
      ),
    );
  }
}

class RestaurantsNearYouWidget extends StatelessWidget {
  final HomeController controller;

  const RestaurantsNearYouWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    if (controller.restaurantsNearYou.isEmpty || HiveMethods.getLat() == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        22.sbH,
        if (HiveMethods.getToken() != null) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              textDirection: TextDirection.rtl,
              children: [
                Icon(Icons.location_on_rounded, size: 22, color: AppColors.mainAppColor),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    'مطاعم قريبة منك',
                    style: AppTextStyle.text18BS(),
                    textAlign: TextAlign.right,
                  ),
                ),
                Text(
                  'عرض الكل',
                  style: AppTextStyle.text13BS().copyWith(color: AppColors.mainAppColor),
                ),
                const SizedBox(width: 3),
                Icon(Icons.chevron_left_rounded, size: 22, color: AppColors.mainAppColor),
              ],
            ),
          ),
          10.sbH,
          RestaurantsNearYouListViewWidget(restaurantsNearYou: controller.restaurantsNearYou),
        ],
      ],
    );
  }
}

class SpecialRestaurantsSectionWidget extends StatelessWidget {
  final HomeController controller;

  const SpecialRestaurantsSectionWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    if (controller.spacialRestaurants.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        10.sbH,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text('favorableRestaurants'.tr, style: AppTextStyle.text16BS()),
        ),
        16.sbH,
        SpacialRestaurantsListViewWidget(spacialRest: controller.spacialRestaurants),
      ],
    );
  }
}
