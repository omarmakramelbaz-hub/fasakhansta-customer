import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../helpers/extensions/extensions.dart';
import '../../../../helpers/images/app_images.dart';
import '../../../../helpers/theme/app_text_style.dart';
import '../../../../helpers/translation/all_translation.dart';
import '../../../custom_widgets/custom_image/custom_image.dart';
import '../../auth/controller/auth_controller.dart';
import '../controller/home_controller.dart';

class CelebrateWidget extends StatelessWidget {
  const CelebrateWidget({super.key, required this.homeController});
  final HomeController homeController;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          const CustomImage(path: AppImages.celebrateBG, type: ImageType.svg, height: 175),
          // Positioned(
          //   top: 10,
          //   left: 0,
          //   right: 0,
          //   child: Text(
          //     'rafflevouchers'.tr,
          //     style: AppTextStyle.text16MS(),
          //   ),
          // ),
          Positioned(
            top: 25,
            left: 0,
            right: 0,
            bottom: 47,
            child: Column(
              children: [
                Text('congrats'.tr, style: AppTextStyle.text20MW()),
                6.sbH,
                Text(
                  homeController.coupon?.winnerData?.id == context.read<AuthController>().profile?.id
                      ? 'resturantWinner'.tr
                      : 'theWinnerIs'.tr,
                  style: AppTextStyle.text18BW(),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 17,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text(homeController.coupon?.winnerData?.name ?? '', style: AppTextStyle.text18BW()),
                // SizedBox(
                //   height: 3,
                // ),
                // Text(
                //   'resturantName'.tr,
                //   style: AppTextStyle.text18BW(),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
