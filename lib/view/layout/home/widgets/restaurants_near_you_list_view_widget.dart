import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
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

class RestaurantsNearYouListViewWidget extends StatelessWidget {
  final List<RestaurantsNearYouHomeModel> restaurantsNearYou;

  const RestaurantsNearYouListViewWidget({super.key, required this.restaurantsNearYou});

  @override
  Widget build(BuildContext context) {
    return ApiResponseWidget(
      apiResponse: context.read<HomeController>().restaurantsNearYouApiResponse,
      onReload: () =>
          context.read<HomeController>().getRestaurantsNearYou(lat: HiveMethods.getLat(), lng: HiveMethods.getLan()),
      isEmpty: context.read<HomeController>().restaurantsNearYou.isEmpty,
      loadingWidget: CustomShimmer(
        height: 120,
        width: double.infinity,
        fillColor: AppColors.greyColor.withValues(alpha: 0.05),
        shimmerColor: AppColors.mainAppColor,
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        height: 180,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ...List.generate(
                restaurantsNearYou.length,
                (index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Container(
                      width: context.width * 0.45,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.borderColor),
                      ),
                      child: InkWell(
                        onTap: () {
                          restaurantsNearYou[index].underContract == 'yes' || restaurantsNearYou[index].status == 'busy'
                              ? null
                              : NamedNavigatorImpl.push(
                                  RestaurantDetailsScreen.routeName,
                                  arguments: RestaurantDetailsArgs(id: restaurantsNearYou[index].id ?? 0),
                                );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Stack(
                              children: [
                                CustomNetworkImage(
                                  imageUrl: restaurantsNearYou[index].bgImage ?? '',
                                  height: 100,
                                  width: context.width * 0.45,
                                  radius: 12,
                                  fit: BoxFit.fill,
                                ),
                                BranchLogoWidget(model: restaurantsNearYou[index]),
                                IsRestaurantBusyWidget(model: restaurantsNearYou[index]),
                              ],
                            ),
                            8.sbH,
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    restaurantsNearYou[index].name ?? '',
                                    style: AppTextStyle.text16RS().copyWith(fontSize: 14),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                  ),
                                  if (restaurantsNearYou[index].deliveryTime != null)
                                    Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(bottom: 5),
                                          child: SvgPicture.asset(AppImages.clockIcon),
                                        ),
                                        8.sbW,
                                        Text(
                                          restaurantsNearYou[index].deliveryTime ?? '',
                                          style: AppTextStyle.text16RS()
                                              .copyWith(fontSize: 14, color: AppColors.lightTextColor),
                                          textAlign: TextAlign.center,
                                          maxLines: 1,
                                        ),
                                        const Spacer(),
                                        IsFreeDeliveryWidget(model: restaurantsNearYou[index]),
                                      ],
                                    ),
                                  Container(
                                    padding: const EdgeInsets.only(left: 5, right: 5, top: 5),
                                    decoration: BoxDecoration(
                                      color: AppColors.lightGreyColor,
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SvgPicture.asset(AppImages.starIcon),
                                        const SizedBox(width: 5),
                                        Text(
                                          restaurantsNearYou[index].avgRate?.toStringAsFixed(1).toString() ?? '',
                                          style: AppTextStyle.text14RS().copyWith(height: 1.4),
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
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BranchLogoWidget extends StatelessWidget {
  const BranchLogoWidget({super.key, required this.model});

  final RestaurantsNearYouHomeModel model;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 6,
      right: 2,
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderColor),
          color: AppColors.whiteColor,
        ),
        child: CustomNetworkImage(
          imageUrl: model.logo ?? '',
          height: 30,
          width: 30,
          radius: 12,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

class IsFreeDeliveryWidget extends StatelessWidget {
  final RestaurantsNearYouHomeModel model;
  const IsFreeDeliveryWidget({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    if (model.kmPrice == 0) {
      return Text(
        'freeDelivery'.tr,
        style: AppTextStyle.text16RS().copyWith(fontSize: 14, color: AppColors.lightTextColor),
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CustomImage(path: AppImages.fastDeliveryImage, width: 16, type: ImageType.asset),
          3.sbW,
          Text(
            'egyp'.tr.replaceAll('{}', model.kmPrice.toString()),
            style: AppTextStyle.text14MS(),
          ),
        ],
      );
    }
  }
}

class IsRestaurantBusyWidget extends StatelessWidget {
  const IsRestaurantBusyWidget({super.key, required this.model});

  final RestaurantsNearYouHomeModel model;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: model.status == 'closed' || model.underContract == 'yes' || model.status == 'busy'
          ? Container(
              height: 70,
              width: 82,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.blackColor.withValues(alpha: 0.6),
                    blurRadius: 1,
                    offset: const Offset(0, 0),
                  ),
                ],
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Text(
                    model.underContract == 'yes'
                        ? 'underContract'.tr
                        : model.status == 'closed'
                            ? 'closed'.tr
                            : 'busy'.tr,
                    style: AppTextStyle.text14MW(),
                  ),
                ),
              ),
            )
          : const SizedBox(),
    );
  }
}
