import 'package:flutter/material.dart';

import '../../../../helpers/extensions/extensions.dart';
import '../../../../helpers/images/app_images.dart';
import '../../../../helpers/theme/app_text_style.dart';
import '../../../custom_widgets/api_response_widget/api_response_widget.dart';
import '../../../custom_widgets/custom_image/custom_image.dart';
import '../controller/home_controller.dart';

class RestaurantsDrawWidget extends StatelessWidget {
  // final List<String> restaurantNames = List.filled(8, "فسخانستا");

  const RestaurantsDrawWidget({super.key, required this.homeController});
  final HomeController homeController;
  @override
  Widget build(BuildContext context) {
    return ApiResponseWidget(
      apiResponse: homeController.couponResponse,
      onReload: () => homeController.getCoupon(),
      isEmpty: homeController.coupon == null,
      child: Expanded(
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: ListView.builder(
            padding: const EdgeInsets.all(0),
            itemCount: homeController.coupon?.data?.resturants?.length,
            itemBuilder: (context, index) {
              return RestaurantCard(
                deliveryTime: homeController.coupon?.data?.resturants?[index].deliveryTime ?? '',
                avgRate: homeController.coupon?.data?.resturants?[index].avgRate ?? 0,
                resturantId: homeController.coupon?.data?.resturants?[index].id ?? 0,
                homeController: homeController,
                couponId: homeController.coupon!.data!.id!,
                image: homeController.coupon?.data?.resturants?[index].logo ?? '',
                name: homeController.coupon?.data?.resturants?[index].name ?? '',
              );
            },
          ),
        ),
      ),
    );
  }
}

class RestaurantCard extends StatelessWidget {
  final String name;
  final String image;
  final String deliveryTime;
  final int couponId;
  final double avgRate;
  final int resturantId;
  final HomeController homeController;

  const RestaurantCard({
    super.key,
    required this.name,
    required this.image,
    required this.couponId,
    required this.homeController,
    required this.resturantId,
    required this.deliveryTime,
    required this.avgRate,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: InkWell(
          onTap: () => homeController.couponSubscribe(couponWheelId: couponId, resturantId: resturantId),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              CustomImage(
                path: image,
                type: ImageType.network,
                fit: BoxFit.contain,
                radius: 20,
                height: 120,
                width: 120,
              ),
              const SizedBox(width: 5),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  20.sbH,
                  Flexible(
                    child: Text(name, style: AppTextStyle.text14BS(), textAlign: TextAlign.center),
                  ),
                  10.sbH,
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CustomImage(path: AppImages.starIcon, type: ImageType.svg),
                      const SizedBox(width: 5),
                      Text(avgRate.toString(), style: AppTextStyle.text14BS()),
                    ],
                  ),
                ],
              ),
              Flexible(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const CustomImage(path: AppImages.clockIcon, type: ImageType.svg),
                    const SizedBox(width: 5),
                    Text(deliveryTime, style: AppTextStyle.text14BS()),
                    const SizedBox(width: 5),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
