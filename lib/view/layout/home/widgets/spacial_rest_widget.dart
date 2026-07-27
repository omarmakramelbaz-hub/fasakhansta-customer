import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../helpers/extensions/extensions.dart';
import '../../../../helpers/hive/hive_methods.dart';
import '../../../../helpers/images/app_images.dart';
import '../../../../helpers/routes/app_routers_import.dart';
import '../../../../helpers/theme/app_colors.dart';
import '../../../../helpers/theme/app_text_style.dart';
import '../../../../helpers/translation/all_translation.dart';
import '../../../custom_widgets/api_response_widget/api_response_widget.dart';
import '../../../custom_widgets/custom_image/custom_image.dart';
import '../../../custom_widgets/custom_image/custom_network_image.dart';
import '../../../custom_widgets/custom_loading/custom_shimmer.dart';
import '../../restaurants/screen/restaurant_details_screen.dart';
import '../controller/home_controller.dart';
import '../model/restaurants_near_you_home_model.dart';

class SpacialRestaurantsListViewWidget extends StatelessWidget {
  final List<RestaurantsNearYouHomeModel> spacialRest;
  const SpacialRestaurantsListViewWidget({super.key, required this.spacialRest});

  @override
  Widget build(BuildContext context) {
    return ApiResponseWidget(
      apiResponse: context.read<HomeController>().spacialRestaurantApiResponse,
      onReload: () =>
          context.read<HomeController>().getSpacialRestaurants(lat: HiveMethods.getLat(), lng: HiveMethods.getLan()),
      isEmpty: context.read<HomeController>().spacialRestaurants.isEmpty,
      loadingWidget: CustomShimmer(
        height: 120,
        width: double.infinity,
        fillColor: AppColors.greyColor.withValues(alpha: 0.05),
        shimmerColor: AppColors.mainAppColor,
      ),
      child: SizedBox(
        height: 120,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          itemCount: spacialRest.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: SizedBox(
                width: 86,
                child: InkWell(
                  onTap: () {
                    spacialRest[index].status == 'busy' || spacialRest[index].underContract == 'yes'
                        ? null
                        : NamedNavigatorImpl.push(
                            RestaurantDetailsScreen.routeName,
                            arguments: RestaurantDetailsArgs(id: spacialRest[index].id ?? 0),
                          );
                  },
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.borderColor),
                            ),
                            child: CustomNetworkImage(
                              imageUrl: spacialRest[index].logo ?? '',
                              height: 70,
                              width: 82,
                              radius: 12,
                              fit: BoxFit.contain,
                            ),
                          ),
                          Positioned.fill(
                            child: spacialRest[index].status == 'closed' ||
                                    spacialRest[index].status == 'busy' ||
                                    spacialRest[index].underContract == 'yes'
                                ? Container(
                                    height: 70,
                                    width: 82,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.blackColor.withValues(alpha: 0.6),
                                          blurRadius: 1,
                                          offset: const Offset(0, 0),
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Text(
                                        spacialRest[index].underContract == 'yes'
                                            ? 'underContract'.tr
                                            : spacialRest[index].status == 'closed'
                                                ? 'closed'.tr
                                                : 'busy'.tr,
                                        style: AppTextStyle.text14MW(),
                                      ),
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ),
                          Positioned(
                            top: 5,
                            left: 5,
                            child: spacialRest[index].kmPrice == 0
                                ? const CustomImage(
                                    path: AppImages.freeDeliveryImage,
                                    type: ImageType.asset,
                                    height: 25,
                                  )
                                : const SizedBox.shrink(),
                          ),
                        ],
                      ),
                      12.sbH,
                      Expanded(
                        child: Text(
                          spacialRest[index].name ?? '',
                          style: AppTextStyle.text14RS(),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
