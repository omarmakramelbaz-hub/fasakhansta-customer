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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 26),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFF0F0F0)),
        ),
        child: Column(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: AppColors.mainAppColor.withValues(alpha: .10),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.storefront_rounded, color: AppColors.mainAppColor, size: 28),
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
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final restaurant = restaurants[index];
        return RestaurantCard(
          restaurant: restaurant,
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
    final image = (restaurant.bgImage ?? '').trim().isNotEmpty
        ? restaurant.bgImage!.trim()
        : (restaurant.logo ?? '').trim();
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
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFF0F0F0)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x12000000),
                blurRadius: 16,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(17),
                      child: image.isEmpty
                          ? Container(
                              width: 92,
                              height: 92,
                              color: const Color(0xFFFFF4EA),
                              alignment: Alignment.center,
                              child: Icon(
                                Icons.storefront_rounded,
                                color: AppColors.mainAppColor,
                                size: 34,
                              ),
                            )
                          : CustomImage(
                              path: image,
                              type: ImageType.network,
                              fit: BoxFit.cover,
                              radius: 0,
                              height: 92,
                              width: 92,
                            ),
                    ),
                    const SizedBox(width: 12),
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
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE9F7F3),
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
                              ),
                            ],
                          ),
                          if (address.isNotEmpty) ...[
                            const SizedBox(height: 7),
                            Row(
                              children: [
                                const Icon(Icons.location_on_outlined, size: 15, color: Color(0xFF7B8589)),
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
                          ],
                          const SizedBox(height: 10),
                          Row(
                            children: [
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
                              const Spacer(),
                              Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: AppColors.mainAppColor),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1, color: Color(0xFFF0F0F0)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _MetricItem(
                        icon: Icons.shopping_bag_outlined,
                        label: 'الحد الأدنى',
                        value: _formatMoney(restaurant.minOrderPrice),
                      ),
                    ),
                    _divider(),
                    Expanded(
                      child: _MetricItem(
                        icon: Icons.delivery_dining_rounded,
                        label: 'رسوم التوصيل',
                        value: _formatMoney(restaurant.serviceFees),
                      ),
                    ),
                    _divider(),
                    Expanded(
                      child: _MetricItem(
                        icon: Icons.schedule_rounded,
                        label: 'وقت التوصيل',
                        value: _formatDeliveryTime(restaurant.deliveryTime),
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

  Widget _divider() => Container(
        width: 1,
        height: 42,
        color: const Color(0xFFEDEDED),
      );
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
