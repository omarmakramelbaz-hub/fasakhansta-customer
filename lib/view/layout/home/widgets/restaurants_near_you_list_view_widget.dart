import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../helpers/hive/hive_methods.dart';
import '../../../../helpers/routes/app_routers_import.dart';
import '../../../../helpers/theme/app_colors.dart';
import '../../../../helpers/theme/app_text_style.dart';
import '../../../../helpers/translation/all_translation.dart';
import '../../../custom_widgets/api_response_widget/api_response_widget.dart';
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
        height: 176,
        width: double.infinity,
        fillColor: AppColors.greyColor.withValues(alpha: 0.05),
        shimmerColor: AppColors.mainAppColor,
      ),
      child: SizedBox(
        height: 176,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          scrollDirection: Axis.horizontal,
          itemCount: restaurantsNearYou.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (context, index) {
            final model = restaurantsNearYou[index];
            final canOpen = model.underContract != 'yes' && model.status != 'busy' && model.status != 'closed';

            return SizedBox(
              width: 132,
              height: 174,
              child: Material(
                color: AppColors.whiteColor,
                borderRadius: BorderRadius.circular(18),
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: canOpen
                      ? () => NamedNavigatorImpl.push(
                            RestaurantDetailsScreen.routeName,
                            arguments: RestaurantDetailsArgs(id: model.id ?? 0),
                          )
                      : null,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.whiteColor,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.borderColorContainer.withOpacity(.8)),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.blackColor.withOpacity(.055),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(
                          height: 92,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              CustomNetworkImage(
                                imageUrl: model.bgImage ?? model.logo ?? '',
                                height: 92,
                                width: 132,
                                radius: 0,
                                fit: BoxFit.cover,
                              ),
                              Positioned(
                                top: 7,
                                right: 7,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.mainAppColor,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.blackColor.withOpacity(.12),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    model.deliveryTime ?? 'سريع',
                                    style: AppTextStyle.text10BW(color: AppColors.whiteColor),
                                  ),
                                ),
                              ),
                              BranchLogoWidget(model: model),
                              IsRestaurantBusyWidget(model: model),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(8, 6, 8, 7),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  model.name ?? '',
                                  style: AppTextStyle.text13BS(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.right,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  model.address ?? model.cityName ?? '',
                                  style: AppTextStyle.text10RG(color: AppColors.lightTextColor),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.right,
                                ),
                                const Spacer(),
                                Row(
                                  textDirection: TextDirection.ltr,
                                  children: [
                                    Expanded(
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.delivery_dining_rounded, size: 13),
                                          const SizedBox(width: 2),
                                          Flexible(
                                            child: Text(
                                              model.kmPrice != null ? '${model.kmPrice!.toStringAsFixed(0)} جنيه' : '',
                                              style: AppTextStyle.text10RG(color: AppColors.greyColor),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.star_rounded, size: 14, color: Colors.deepOrange),
                                        const SizedBox(width: 2),
                                        Text(
                                          model.avgRate?.toStringAsFixed(1) ?? '0.0',
                                          style: AppTextStyle.text10BW(color: AppColors.blackColor),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
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
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.whiteColor, width: 2),
          color: AppColors.whiteColor,
          boxShadow: [
            BoxShadow(
              color: AppColors.blackColor.withOpacity(.12),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: CustomNetworkImage(
          imageUrl: model.logo ?? '',
          height: 30,
          width: 30,
          radius: 8,
          fit: BoxFit.contain,
        ),
      ),
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
