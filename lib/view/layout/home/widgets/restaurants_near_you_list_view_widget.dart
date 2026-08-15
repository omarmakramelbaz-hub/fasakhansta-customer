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
    final baseCardWidth = ((screenWidth - 42) / 2).clamp(150.0, 170.0);
    final cardWidth = baseCardWidth * .75;

    return ApiResponseWidget(
      apiResponse: context.read<HomeController>().restaurantsNearYouApiResponse,
      onReload: () => context.read<HomeController>().getRestaurantsNearYou(
            lat: HiveMethods.getLat(),
            lng: HiveMethods.getLan(),
          ),
      isEmpty: restaurantsNearYou.isEmpty,
      loadingWidget: CustomShimmer(
        height: 188,
        width: double.infinity,
        fillColor: AppColors.greyColor.withValues(alpha: .05),
        shimmerColor: AppColors.mainAppColor,
      ),
      child: SizedBox(
        height: 188,
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
    final radius = BorderRadius.circular(14);

    return SizedBox(
      width: width,
      height: 183,
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
            child: Column(
              children: [
                SizedBox(
                  height: 81,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CustomNetworkImage(
                        imageUrl: model.bgImage ?? model.logo ?? '',
                        height: 81,
                        width: width,
                        radius: 0,
                        fit: BoxFit.cover,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              AppColors.blackColor.withOpacity(.16),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        top: 6,
                        left: 6,
                        child: _DeliveryBadge(text: model.deliveryTime ?? 'سريع'),
                      ),
                      Positioned(
                        right: 6,
                        bottom: 6,
                        child: _CityBadge(text: model.cityName ?? model.cityname ?? ''),
                      ),
                      const Positioned(
                        right: 6,
                        top: 6,
                        child: Icon(Icons.location_on_rounded, color: Colors.white, size: 14),
                      ),
                      BranchLogoWidget(model: model),
                      IsRestaurantBusyWidget(model: model),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(7, 6, 7, 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          textDirection: TextDirection.rtl,
                          children: [
                            Expanded(
                              child: Text(
                                model.name ?? '',
                                style: AppTextStyle.text15BS().copyWith(fontSize: 12),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.right,
                              ),
                            ),
                            const SizedBox(width: 3),
                            const Icon(Icons.storefront_rounded, color: Color(0xFFFF7A00), size: 12),
                          ],
                        ),
                        const SizedBox(height: 1),
                        Text(
                          model.address ?? model.cityName ?? '',
                          style: AppTextStyle.text10RG(color: AppColors.lightTextColor),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF5EC),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFFFE0C7)),
                          ),
                          child: Row(
                            textDirection: TextDirection.rtl,
                            children: [
                              Expanded(
                                child: _InfoItem(
                                  icon: Icons.star_rounded,
                                  iconColor: const Color(0xFFFF7A00),
                                  title: model.avgRate?.toStringAsFixed(1) ?? '0.0',
                                  subtitle: 'التقييم',
                                ),
                              ),
                              Container(width: 1, height: 18, color: const Color(0xFFFFE0C7)),
                              Expanded(
                                child: _InfoItem(
                                  icon: Icons.delivery_dining_rounded,
                                  iconColor: const Color(0xFF1D766B),
                                  title: model.kmPrice != null ? '${model.kmPrice!.toStringAsFixed(0)} جنيه' : 'حسب المنطقة',
                                  subtitle: 'التوصيل',
                                ),
                              ),
                              Container(width: 1, height: 18, color: const Color(0xFFFFE0C7)),
                              Expanded(
                                child: _InfoItem(
                                  icon: Icons.account_balance_wallet_rounded,
                                  iconColor: const Color(0xFFFF7A00),
                                  title: _formatMoney(model.minOrderPrice),
                                  subtitle: 'الحد الأدنى',
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        SizedBox(
                          width: double.infinity,
                          height: 27,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: canOpen ? AppColors.mainAppColor : AppColors.greyColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                'اطلب الآن',
                                style: AppTextStyle.text12BS().copyWith(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ),
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
    if (text.trim().isEmpty) return const SizedBox.shrink();
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

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;

  const _InfoItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 13, color: iconColor),
        const SizedBox(height: 1),
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: AppTextStyle.text10BW(color: AppColors.blackColor),
        ),
        Text(
          subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: AppTextStyle.text10RG(color: AppColors.greyColor),
        ),
      ],
    );
  }
}

String _formatMoney(dynamic value) {
  if (value == null) return 'غير محدد';
  if (value is num) return '${value.toStringAsFixed(0)} جنيه';
  final parsed = num.tryParse(value.toString());
  return parsed == null ? 'غير محدد' : '${parsed.toStringAsFixed(0)} جنيه';
}

class BranchLogoWidget extends StatelessWidget {
  const BranchLogoWidget({super.key, required this.model});

  final RestaurantsNearYouHomeModel model;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 6,
      bottom: -12,
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
        ),
        child: CustomNetworkImage(
          imageUrl: model.logo ?? '',
          height: 33,
          width: 33,
          radius: 18,
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
