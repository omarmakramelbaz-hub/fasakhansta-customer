import 'package:flutter/material.dart';

import '../../../../helpers/extensions/extensions.dart';
import '../../../../helpers/hive/hive_methods.dart';
import '../../../../helpers/images/app_images.dart';
import '../../../../helpers/routes/app_routers_import.dart';
import '../../../../helpers/theme/app_colors.dart';
import '../../../../helpers/translation/all_translation.dart';
import '../../../../helpers/utils/common_methods.dart';
import '../../../custom_widgets/custom_image/custom_image.dart';
import '../../request_delegate/screen/request_delegate_screen.dart';
import '../controller/home_controller.dart';

class GoDriveCardWidget extends StatelessWidget {
  final HomeController controller;

  const GoDriveCardWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: context.width * 0.44,
      height: 120,
      child: InkWell(
        onTap: () {
          if (HiveMethods.getToken() == null) {
            CommonMethods.showError(message: 'youMustLoginFirst'.tr);
          } else {
            NamedNavigatorImpl.push(RequestDelegateScreen.routeName);
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 5),
          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 21),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderColor),
          ),
          child: const CustomImage(
            path: AppImages.gooDriveImage,
            type: ImageType.asset,
            fit: BoxFit.contain,
            height: 100,
          ),
        ),
      ),
    );
  }
}
