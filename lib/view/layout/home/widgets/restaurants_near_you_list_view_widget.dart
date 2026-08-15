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
    final screenWidth = MediaQuery.sizeOf(context).width;
    final cardWidth = ((screenWidth - 38) / 2).clamp(154.0, 172.0);
    const cardHeight = 112.0;

    return ApiResponseWidget(
      apiResponse: context.read<HomeController>().restaurantsNearYouApiResponse,
      onReload: () => context.read<HomeController>().getRestaurantsNearYou(
            lat: HiveMethods.getLat(),
            lng: HiveMethods.getLan(),
          ),
      isEmpty: restaurantsNearYou.isEmpty,
      loadingWidget: CustomShimmer(
        height: cardHeight,
        width: double.infinity,
        fillColor: AppColors.greyColor.withValues(alpha: .05),
        shimmerColor: AppColors.mainAppColor,
      ),
      child: SizedBox(
        height: cardHeight,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          scrollDirection: Axis.horizontal,
          itemCount: restaurantsNearYou.length,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (context, index) {
            final model = restaurantsNearYou[index];
            final canOpen = model.underContract != 'yes' && model.status != 'busy' && model.status != 'closed';

            return _NearbyRestaurantCard(
              model: model,
              width: cardWidth,
              canOpen: canOpen,
            );
          },
        ),
      ),
    );
  }
}

class _NearbyRestaurantCard extends StatelessWidget {
  final RestaurantsNearYouHomeModel model;
  final double width;
  final bool canOpen;

  const _NearbyRestaurantCard({
    required this.model,
    required this.width,
    required this.canOpen,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(16);

    return SizedBox(
      width: width,
      height: 112,
      child: Material(
        color: AppColors.whiteColor,
        borderRadius: radius,
        child: InkWell(
          borderRadius: radius,
          onTap: canOpen
              ? () => NamedNavigatorImpl.push(
                    RestaurantDetailsScreen.routeName,
                    arguments: RestaurantDetailsArgs(id: model.id ?? 0),
                  )
              : null,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.whiteColor,
              borderRadius: radius,
              border: Border.all(color: AppColors.borderColorContainer.withOpacity(.62)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.blackColor.withOpacity(.055),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    flex: 6,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(7, 7, 7, 7),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  model.name ?? '',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.right,
                                  style: AppTextStyle.text15BS().copyWith(fontSize: 12),
                                ),
                              ),
                              const SizedBox(width: 3),
                              const Icon(Icons.storefront_rounded, color: Color(0xFFFF7A00), size: 12),
                            ],
                          ),
                          const SizedBox(height: 1),
                          Text(
                            model.address ?? model.cityName ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.right,
                            style: AppTextStyle.text10RG(color: AppColors.lightTextColor),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Expanded(
                                child: _MiniValue(
                                  icon: Icons.star_rounded,
                                  iconColor: const Color(0xFFFF7A00),
                                  value: model.avgRate?.toStringAsFixed(1) ?? '0.0',
                                ),
                              ),
                              const SizedBox(width: 3),
                              Expanded(
                                child: _MiniValue(
                                  icon: Icons.delivery_dining_rounded,
                                  iconColor: const Color(0xFF1D766B),
                                  value: model.kmPrice != null ? '${model.kmPrice!.toStringAsFixed(0)}ج' : 'حسب المنطقة',
                                ),
                              ),
                              const SizedBox(width: 3),
                              Expanded(
                                child: _MiniValue(
                                  icon: Icons.account_balance_wallet_rounded,
                                  iconColor: const Color(0xFFFF7A00),
                                  value: _formatMoney(model.minOrderPrice),
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          SizedBox(
                            width: double.infinity,
                            height: 24,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: canOpen ? AppColors.mainAppColor : AppColors.greyColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  'اطلب الآن',
                                  style: AppTextStyle.text12BS().copyWith(color: Colors.white, fontSize: 10),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: width * .42,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CustomNetworkImage(
                          imageUrl: model.bgImage ?? model.logo ?? '',
                          height: 112,
                          width: width * .42,
                          radius: 0,
                          fit: BoxFit.cover,
                        ),
                        Positioned(
                          top: 6,
                          right: 6,
                          child: _DeliveryBadge(text: model.deliveryTime ?? 'سريع'),
                        ),
                        if ((model.cityName ?? model.cityname ?? '').trim().isNotEmpty)
                          Positioned(
                            bottom: 6,
                            right: 6,
                            child: _CityBadge(text: model.cityName ?? model.cityname ?? ''),
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
      ),
    );
  }
}

class _MiniValue extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;

  const _MiniValue({required this.icon, required this.iconColor, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5EC),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 12, color: iconColor),
          const SizedBox(width: 2),
          Flexible(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: AppTextStyle.text10BW(color: AppColors.blackColor),
            ),
          ),
        ],
      ),
    );
  }
}

class _DeliveryBadge extends StatelessWidget {
  final String text;
  const _DeliveryBadge({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: AppColors.blackColor.withOpacity(.08),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.schedule_rounded, size: 11, color: Color(0xFFFF7A00)),
          const SizedBox(width: 2),
          Text(text, style: AppTextStyle.text10BW(color: AppColors.blackColor)),
        ],
      ),
    );
  }
}

class _CityBadge extends StatelessWidget {
  final String text;
  const _CityBadge({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF145D55).withOpacity(.95),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.location_on_rounded, size: 10, color: Colors.white),
          const SizedBox(width: 2),
          Text(text, style: AppTextStyle.text10BW(color: Colors.white)),
        ],
      ),
    );
  }
}

String _formatMoney(dynamic value) {
  if (value == null) return 'غير محدد';
  if (value is num) return '${value.toStringAsFixed(0)}ج';
  final parsed = num.tryParse(value.toString());
  return parsed == null ? 'غير محدد' : '${parsed.toStringAsFixed(0)}ج';
}

class BranchLogoWidget extends StatelessWidget {
  const BranchLogoWidget({super.key, required this.model});

  final RestaurantsNearYouHomeModel model;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 6,
      bottom: -8,
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
        ),
        child: CustomNetworkImage(
          imageUrl: model.logo ?? '',
          height: 30,
          width: 30,
          radius: 16,
          fit: BoxFit.cover,
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
        color: AppColors.blackColor.withOpacity(.48),
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
