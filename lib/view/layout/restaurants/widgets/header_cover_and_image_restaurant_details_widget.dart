import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../../helpers/extensions/extensions.dart';
import '../../../../helpers/hive/hive_methods.dart';
import '../../../../helpers/images/app_images.dart';
import '../../../../helpers/routes/app_routers_import.dart';
import '../../../../helpers/theme/app_colors.dart';
import '../../../../helpers/theme/app_text_style.dart';
import '../../../custom_widgets/custom_image/custom_network_image.dart';
import '../../search/screen/search_screen.dart';
import '../controller/restaurants_controller.dart';
import '../model/details_restaurants_model.dart';

class HeaderCoverAndImageRestaurantDetailsWidget extends StatelessWidget {
  final DetailsRestaurantModel? detailsRestaurant;

  const HeaderCoverAndImageRestaurantDetailsWidget({
    super.key,
    required this.detailsRestaurant,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final imageHeight = width * .46;

        return Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                SizedBox(
                  width: width,
                  height: imageHeight,
                  child: CustomNetworkImage(
                    imageUrl: detailsRestaurant?.bgImage ?? '',
                    width: width,
                    height: imageHeight,
                    fit: BoxFit.cover,
                    radius: 0,
                  ),
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: .12),
                          Colors.black.withValues(alpha: .42),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 42,
                  right: 18,
                  child: _circleButton(
                    icon: Icons.arrow_back_ios_new_rounded,
                    onTap: () => Navigator.pop(context),
                  ),
                ),
                Positioned(
                  top: 42,
                  left: 18,
                  child: Row(
                    children: [
                      _circleButton(
                        icon: Icons.share_outlined,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('تم تجهيز مشاركة الفرع')),
                          );
                        },
                      ),
                      const SizedBox(width: 8),
                      if (HiveMethods.getToken() != null)
                        _circleButton(
                          icon: detailsRestaurant?.isFav == 1
                              ? Icons.favorite_rounded
                              : Icons.favorite_outline_rounded,
                          iconColor: detailsRestaurant?.isFav == 1
                              ? AppColors.mainAppColor
                              : AppColors.secondAppColor,
                          onTap: () {
                            context.read<RestaurantsController>().addOrRemoveToWishlist(
                                  id: detailsRestaurant?.id ?? 0,
                                  onSuccess: () {
                                    detailsRestaurant?.isFav = detailsRestaurant?.isFav == 1 ? 0 : 1;
                                  },
                                );
                          },
                        ),
                    ],
                  ),
                ),
                Positioned(
                  left: 18,
                  bottom: -22,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.whiteColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x22000000),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          detailsRestaurant?.status == 'closed'
                              ? Icons.circle
                              : Icons.circle,
                          color: detailsRestaurant?.status == 'closed'
                              ? Colors.red
                              : Colors.green,
                          size: 10,
                        ),
                        const SizedBox(width: 7),
                        Text(
                          detailsRestaurant?.status == 'closed' ? 'مغلق الآن' : 'مفتوح الآن',
                          style: AppTextStyle.text12BS(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 32, 20, 12),
              color: AppColors.whiteColor,
              child: Column(
                children: [
                  Text(
                    detailsRestaurant?.name ?? '',
                    textAlign: TextAlign.center,
                    style: AppTextStyle.text20BS(),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        detailsRestaurant?.avgRate?.toStringAsFixed(1) ?? '-',
                        style: AppTextStyle.text14BS(),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.star_rounded, color: Color(0xFFFFB400), size: 20),
                      const SizedBox(width: 4),
                      Text('(تقييم)', style: AppTextStyle.text14RS()),
                    ],
                  ),
                  if ((detailsRestaurant?.address ?? '').isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      detailsRestaurant?.address ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: AppTextStyle.text12RS(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _circleButton({
    required IconData icon,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        width: 44,
        height: 44,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: iconColor ?? AppColors.secondAppColor,
          size: 22,
        ),
      ),
    );
  }
}
