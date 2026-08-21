import 'package:flutter/material.dart';

import '../../../../helpers/theme/app_colors.dart';
import '../../../../helpers/theme/app_text_style.dart';
import '../../../custom_widgets/custom_image/custom_image.dart';
import '../controller/home_controller.dart';
import '../model/coupon_model.dart';

class RestaurantsDrawWidget extends StatelessWidget {
  const RestaurantsDrawWidget({super.key, required this.homeController});

  final HomeController homeController;

  @override
  Widget build(BuildContext context) {
    final restaurants = homeController.coupon?.data?.resturants ?? <Resturants>[];
    final couponId = homeController.coupon?.data?.id ?? 0;

    if (restaurants.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFF0F0F0)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0D000000),
              blurRadius: 16,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: AppColors.mainAppColor.withValues(alpha: .10),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.storefront_rounded, color: AppColors.mainAppColor, size: 30),
            ),
            const SizedBox(height: 12),
            Text('لا توجد مطاعم مشاركة حالياً', style: AppTextStyle.text14BS()),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: restaurants.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        return RestaurantCard(
          restaurant: restaurants[index],
          couponId: couponId,
          homeController: homeController,
        );
      },
    );
  }
}

class RestaurantCard extends StatelessWidget {
  const RestaurantCard({
    super.key,
    required this.restaurant,
    required this.couponId,
    required this.homeController,
  });

  final Resturants restaurant;
  final int couponId;
  final HomeController homeController;

  @override
  Widget build(BuildContext context) {
    final logo = (restaurant.logo ?? '').trim();
    final fallbackImage = (restaurant.bgImage ?? '').trim();
    final image = logo.isNotEmpty ? logo : fallbackImage;
    final address = (restaurant.address ?? '').trim().isNotEmpty
        ? restaurant.address!.trim()
        : (restaurant.cityName ?? restaurant.cityname ?? '').trim();
    final canSubscribe = couponId > 0 && (restaurant.id ?? 0) > 0;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: canSubscribe
            ? () => homeController.couponSubscribe(
                  couponWheelId: couponId,
                  resturantId: restaurant.id!,
                )
            : null,
        child: Container(
          padding: const EdgeInsets.fromLTRB(13, 13, 13, 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFF0F0F0)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x12000000),
                blurRadius: 18,
                offset: Offset(0, 7),
              ),
            ],
          ),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _RestaurantImage(image: image),
                    const SizedBox(width: 13),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  restaurant.name ?? '',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyle.text17BS(),
                                ),
                              ),
                              const SizedBox(width: 7),
                              const _ParticipatingBadge(),
                            ],
                          ),
                          const SizedBox(height: 6),
                          if (address.isNotEmpty)
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on_outlined,
                                  size: 15,
                                  color: Color(0xFF7B8589),
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    address,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyle.text12RG(color: const Color(0xFF7B8589)),
                                  ),
                                ),
                              ],
                            ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF5EC),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.star_rounded, size: 17, color: Color(0xFFFF7A00)),
                                const SizedBox(width: 4),
                                Text(
                                  restaurant.avgRate?.toStringAsFixed(1) ?? '0.0',
                                  style: AppTextStyle.text13BS(),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 17,
                      color: AppColors.mainAppColor,
                    ),
                  ],
                ),
                const SizedBox(height: 13),
                const Divider(height: 1, color: Color(0xFFF0F0F0)),
                const SizedBox(height: 11),
                Row(
                  children: [
                    Expanded(
                      child: _MetricItem(
                        icon: Icons.schedule_rounded,
                        label: 'وقت التوصيل',
                        value: _formatDeliveryTime(restaurant.deliveryTime),
                      ),
                    ),
                    _metricDivider(),
                    Expanded(
                      child: _MetricItem(
                        icon: Icons.star_rounded,
                        label: 'التقييم',
                        value: restaurant.avgRate?.toStringAsFixed(1) ?? '0.0',
                      ),
                    ),
                    _metricDivider(),
                    Expanded(
                      child: _MetricItem(
                        icon: Icons.delivery_dining_rounded,
                        label: 'رسوم التوصيل',
                        value: _formatMoney(restaurant.serviceFees),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _metricDivider() => Container(
        width: 1,
        height: 46,
        color: const Color(0xFFEDEDED),
      );
}

class _RestaurantImage extends StatelessWidget {
  const _RestaurantImage({required this.image});

  final String image;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: image.isEmpty
          ? Container(
              width: 94,
              height: 94,
              color: const Color(0xFFFFF4EA),
              alignment: Alignment.center,
              child: Icon(Icons.storefront_rounded, color: AppColors.mainAppColor, size: 36),
            )
          : CustomImage(
              path: image,
              type: ImageType.network,
              fit: BoxFit.cover,
              radius: 0,
              height: 94,
              width: 94,
            ),
    );
  }
}

class _ParticipatingBadge extends StatelessWidget {
  const _ParticipatingBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F7F3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_rounded, size: 14, color: Color(0xFF0A857A)),
          SizedBox(width: 4),
          Text(
            'مشارك',
            style: TextStyle(
              color: Color(0xFF0A857A),
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricItem extends StatelessWidget {
  const _MetricItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 19, color: AppColors.mainAppColor),
        const SizedBox(height: 4),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyle.text10RG(color: const Color(0xFF7A7A7A)),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyle.text12BS(),
        ),
      ],
    );
  }
}

String _formatMoney(dynamic value) {
  if (value == null) return '-';
  final number = value is num ? value : num.tryParse(value.toString());
  if (number == null) return value.toString();
  if (number == 0) return 'مجاني';
  return '${number.toStringAsFixed(number % 1 == 0 ? 0 : 2)} ج';
}

String _formatDeliveryTime(String? value) {
  final text = value?.trim() ?? '';
  return text.isEmpty ? '-' : text;
}
