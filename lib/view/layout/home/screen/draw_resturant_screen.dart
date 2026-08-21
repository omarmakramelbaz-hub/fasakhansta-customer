import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';

import '../../../../helpers/hive/hive_methods.dart';
import '../../../../helpers/pusher_service/pusher_controller.dart';
import '../../../../helpers/theme/app_colors.dart';
import '../../../../helpers/theme/app_text_style.dart';
import '../../../../helpers/translation/all_translation.dart';
import '../../../custom_widgets/api_response_widget/api_response_widget.dart';
import '../../../custom_widgets/custom_image/custom_image.dart';
import '../../my_account/account_app_bar/account_app_bar.dart';
import '../controller/home_controller.dart';
import '../widgets/draw_widget.dart';

class DrawRestaurantScreen extends StatefulWidget {
  static const String routeName = 'DrawRestaurantScreen';
  const DrawRestaurantScreen({super.key});

  @override
  State<DrawRestaurantScreen> createState() => _DrawRestaurantScreenState();
}

class _DrawRestaurantScreenState extends State<DrawRestaurantScreen> {
  late PusherController _pusherController;

  @override
  void initState() {
    _pusherController = context.read<PusherController>();
    _pusherController.addEventListener('coupon.wheel.updated', _couponWheelUpdated);
    Future.microtask(() {
      final controller = context.read<HomeController>();
      controller.initialCoupon();
      controller.getCoupon(lat: HiveMethods.getLat(), lng: HiveMethods.getLan());
    });
    super.initState();
  }

  void _couponWheelUpdated(PusherEvent event) {
    final homeProvider = context.read<HomeController>();
    if (!mounted) return;
    homeProvider.getCoupon(lat: HiveMethods.getLat(), lng: HiveMethods.getLan()).then((_) {
      if (mounted && homeProvider.coupon == null) Navigator.pop(context);
    });
  }

  @override
  void dispose() {
    _pusherController.removeEventListener('coupon.wheel.updated', _couponWheelUpdated);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeController>(
      builder: (context, homeController, _) {
        final data = homeController.coupon?.data;
        final restaurantsCount = data?.resturants?.length ?? 0;

        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FB),
          body: SafeArea(
            child: Column(
              children: [
                CustomAccountAppBar(title: 'restaurantRaffle'.tr),
                Expanded(
                  child: ApiResponseWidget(
                    apiResponse: homeController.couponResponse,
                    onReload: () => homeController.getCoupon(
                      lat: HiveMethods.getLat(),
                      lng: HiveMethods.getLan(),
                    ),
                    isEmpty: homeController.coupon == null,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                      child: Directionality(
                        textDirection: TextDirection.rtl,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _RaffleHero(
                              title: data?.name ?? '',
                              image: data?.image ?? '',
                              price: data?.price ?? '',
                              endDate: data?.endDate,
                            ),
                            const SizedBox(height: 14),
                            _SubscriptionInfoCard(price: data?.price ?? ''),
                            const SizedBox(height: 22),
                            Row(
                              children: [
                                Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: AppColors.mainAppColor.withValues(alpha: .10),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.groups_rounded,
                                    color: AppColors.mainAppColor,
                                    size: 23,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('المطاعم المشاركة في السحب', style: AppTextStyle.text18BS()),
                                      const SizedBox(height: 2),
                                      Text(
                                        '$restaurantsCount مطعم مشارك',
                                        style: AppTextStyle.text12RG(color: const Color(0xFF858585)),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            RestaurantsDrawWidget(homeController: homeController),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _RaffleHero extends StatelessWidget {
  const _RaffleHero({
    required this.title,
    required this.image,
    required this.price,
    required this.endDate,
  });

  final String title;
  final String image;
  final String price;
  final String? endDate;

  @override
  Widget build(BuildContext context) {
    final hasImage = image.trim().isNotEmpty;
    final displayTitle = title.trim().isEmpty ? 'سحب على المطاعم' : title.trim();

    return Container(
      height: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (hasImage)
            CustomImage(
              path: image.trim(),
              type: ImageType.network,
              fit: BoxFit.cover,
              radius: 0,
              width: double.infinity,
              height: 220,
            )
          else
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [Color(0xFF0A5460), Color(0xFF062F44)],
                ),
              ),
            ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x33000000), Color(0xCC061D2A)],
              ),
            ),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
              decoration: BoxDecoration(
                color: AppColors.mainAppColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'المسابقة الحالية',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          Positioned(
            right: 18,
            left: 18,
            bottom: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayTitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.text24BS(color: Colors.white).copyWith(height: 1.15),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _HeroChip(
                      icon: Icons.shopping_bag_outlined,
                      label: 'مبلغ الاشتراك',
                      value: _formatPrice(price),
                    ),
                    if ((endDate ?? '').trim().isNotEmpty)
                      _HeroChip(
                        icon: Icons.schedule_rounded,
                        label: 'الوقت المتبقي',
                        value: _remainingText(endDate),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroChip extends StatelessWidget {
  const _HeroChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .94),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 17, color: AppColors.mainAppColor),
          const SizedBox(width: 6),
          Text('$label: ', style: AppTextStyle.text10RG(color: const Color(0xFF6C6C6C))),
          Text(value, style: AppTextStyle.text12BS()),
        ],
      ),
    );
  }
}

class _SubscriptionInfoCard extends StatelessWidget {
  const _SubscriptionInfoCard({required this.price});

  final String price;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8F2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFDFC5)),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFFFE0C7)),
            ),
            child: Icon(Icons.info_outline_rounded, color: AppColors.mainAppColor, size: 25),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'للاشتراك في المسابقة يرجى الطلب بمبلغ ',
                    style: AppTextStyle.text14BS(),
                  ),
                  TextSpan(
                    text: _formatPrice(price),
                    style: AppTextStyle.text15BS(color: AppColors.mainAppColor),
                  ),
                  TextSpan(
                    text: ' أو أكثر',
                    style: AppTextStyle.text14BS(),
                  ),
                ],
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

String _formatPrice(String? value) {
  final text = value?.trim() ?? '';
  if (text.isEmpty) return '-';
  final number = num.tryParse(text);
  if (number == null) return text;
  return '${number.toStringAsFixed(number % 1 == 0 ? 0 : 2)} ج';
}

String _remainingText(String? value) {
  final raw = value?.trim() ?? '';
  if (raw.isEmpty) return '-';

  final parsed = DateTime.tryParse(raw) ?? DateTime.tryParse(raw.replaceFirst(' ', 'T'));
  if (parsed == null) return raw;

  final difference = parsed.difference(DateTime.now());
  if (difference.isNegative) return 'انتهى السحب';

  final days = difference.inDays;
  final hours = difference.inHours.remainder(24);
  final minutes = difference.inMinutes.remainder(60);

  if (days > 0) return '$days يوم $hours ساعة';
  if (hours > 0) return '$hours ساعة $minutes دقيقة';
  return '$minutes دقيقة';
}
