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
        height: 132,
        width: double.infinity,
        fillColor: AppColors.greyColor.withValues(alpha: 0.05),
        shimmerColor: AppColors.mainAppColor,
      ),
      child: SizedBox(
        height: 136,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          scrollDirection: Axis.horizontal,
          itemCount: restaurantsNearYou.length,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (context, index) {
            final model = restaurantsNearYou[index];
            final canOpen = model.underContract != 'yes' && model.status != 'busy' && model.status != 'closed';

            return SizedBox(
              width: 250,
              height: 126,
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
                    clipBehavior: Clip.antiAlias,
                    child: Row(
                      textDirection: TextDirection.rtl,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(10, 10, 8, 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  model.name ?? '',
                                  style: AppTextStyle.text15BS(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    SvgPicture.asset(AppImages.starIcon, width: 14, height: 14),
                                    const SizedBox(width: 3),
                                    Text(model.avgRate?.toStringAsFixed(1) ?? '0.0', style: AppTextStyle.text12BS()),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  model.address ?? model.cityName ?? '',
                                  style: AppTextStyle.text11RS(color: AppColors.greyColor),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.right,
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    SvgPicture.asset(AppImages.clockIcon, width: 13, height: 13),
                                    const SizedBox(width: 3),
                                    Flexible(
                                      child: Text(
                                        model.deliveryTime ?? 'توصيل سريع',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTextStyle.text11BS(color: AppColors.mainAppColor),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  canOpen ? 'مفتوح الآن' : (model.status == 'closed' ? 'مغلق' : 'غير متاح'),
                                  style: AppTextStyle.text11BS(
                                    color: canOpen ? AppColors.greenColor : AppColors.greyColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 105,
                          height: double.infinity,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              CustomNetworkImage(
                                imageUrl: model.bgImage ?? '',
                                height: 126,
                                width: 105,
                                radius: 0,
                                fit: BoxFit.cover,
                              ),
                              Positioned(
                                top: 7,
                                left: 7,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppColors.mainAppColor,
                                    borderRadius: BorderRadius.circular(9),
                                  ),
                                  child: Text(
                                    model.deliveryTime ?? 'توصيل سريع',
                                    style: AppTextStyle.text10BS(color: AppColors.whiteColor),
                                  ),
                                ),
                              ),
                              BranchLogoWidget(model: model),
                              IsRestaurantBusyWidget(model: model),
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
          height: 30,
          width: 30,
          radius: 9,
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
