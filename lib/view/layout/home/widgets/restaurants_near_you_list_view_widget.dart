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
      onReload: () => context.read<HomeController>().getRestaurantsNearYou(
            lat: HiveMethods.getLat(),
            lng: HiveMethods.getLan(),
          ),
      isEmpty: restaurantsNearYou.isEmpty,
      loadingWidget: CustomShimmer(
        height: 205,
        width: double.infinity,
        fillColor: AppColors.greyColor.withValues(alpha: 0.05),
        shimmerColor: AppColors.mainAppColor,
      ),
      child: SizedBox(
        height: 210,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          scrollDirection: Axis.horizontal,
          itemCount: restaurantsNearYou.length,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (context, index) {
            final model = restaurantsNearYou[index];
            final canOpen = model.underContract != 'yes' && model.status != 'busy' && model.status != 'closed';

            return SizedBox(
              width: 180,
              child: Material(
                color: AppColors.whiteColor,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: canOpen
                      ? () => NamedNavigatorImpl.push(
                            RestaurantDetailsScreen.routeName,
                            arguments: RestaurantDetailsArgs(id: model.id ?? 0),
                          )
                      : null,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borderColorContainer),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.blackColor.withOpacity(.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            CustomNetworkImage(
                              imageUrl: model.bgImage ?? '',
                              height: 105,
                              width: 180,
                              radius: 16,
                              fit: BoxFit.cover,
                            ),
                            Positioned(
                              top: 8,
                              left: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.mainAppColor,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  model.deliveryTime ?? 'توصيل سريع',
                                  style: AppTextStyle.text12BS(color: AppColors.whiteColor),
                                ),
                              ),
                            ),
                            BranchLogoWidget(model: model),
                            IsRestaurantBusyWidget(model: model),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                model.name ?? '',
                                style: AppTextStyle.text16BS(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  SvgPicture.asset(AppImages.clockIcon, width: 14, height: 14),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      model.address ?? model.cityName ?? '',
                                      style: AppTextStyle.text14RS(color: AppColors.greyColor),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  SvgPicture.asset(AppImages.starIcon, width: 14, height: 14),
                                  const SizedBox(width: 3),
                                  Text(
                                    model.avgRate?.toStringAsFixed(1) ?? '0.0',
                                    style: AppTextStyle.text14BS(),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Text(
                                canOpen ? 'مفتوح الآن' : (model.status == 'closed' ? 'مغلق' : 'غير متاح'),
                                style: AppTextStyle.text14BS(
                                  color: canOpen ? AppColors.greenColor : AppColors.greyColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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

class BranchLogoWidget extends StatelessWidget {
  const BranchLogoWidget({super.key, required this.model});

  final RestaurantsNearYouHomeModel model;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 6,
      right: 6,
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.whiteColor, width: 2),
          color: AppColors.whiteColor,
        ),
        child: CustomNetworkImage(
          imageUrl: model.logo ?? '',
          height: 32,
          width: 32,
          radius: 10,
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
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CustomImage(path: AppImages.fastDeliveryImage, width: 16, type: ImageType.asset),
        3.sbW,
        Text('egyp'.tr.replaceAll('{}', model.kmPrice.toString()), style: AppTextStyle.text14MS()),
      ],
    );
  }
}

class IsRestaurantBusyWidget extends StatelessWidget {
  const IsRestaurantBusyWidget({super.key, required this.model});

  final RestaurantsNearYouHomeModel model;

  @override
  Widget build(BuildContext context) {
    final unavailable = model.status == 'closed' || model.underContract == 'yes' || model.status == 'busy';
    if (!unavailable) return const SizedBox.shrink();

    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.blackColor.withOpacity(.48),
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.center,
        child: Text(
          model.underContract == 'yes'
              ? 'underContract'.tr
              : model.status == 'closed'
                  ? 'closed'.tr
                  : 'busy'.tr,
          style: AppTextStyle.text14MW(),
        ),
      ),
    );
  }
}
