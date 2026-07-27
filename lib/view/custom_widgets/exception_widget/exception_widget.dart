import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../helpers/extensions/extensions.dart';
import '../../../helpers/images/app_images.dart';
import '../../../helpers/theme/app_colors.dart';
import '../../../helpers/translation/all_translation.dart';
import '../buttons/custom_button.dart';

class ExceptionWidget extends StatelessWidget {
  final Axis axis;
  final String? message;
  final void Function()? onReload;
  const ExceptionWidget({super.key, this.axis = Axis.vertical, this.message, this.onReload});

  @override
  Widget build(BuildContext context) {
    switch (axis) {
      case Axis.horizontal:
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          decoration: BoxDecoration(
            color: AppColors.mainAppColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(7),
          ),
          child: IntrinsicHeight(
            child: Row(
              children: [
                SvgPicture.asset(
                  AppImages.errorIcon,
                  colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
                  width: 40,
                  height: 40,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    message ?? 'An error occurred'.tr,
                    style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w500),
                    textAlign: TextAlign.justify,
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  onPressed: onReload,
                  icon: SvgPicture.asset(
                    AppImages.refreshIcon,
                    colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
                    width: 25,
                    height: 25,
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),
          ),
        );

      case Axis.vertical:
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
          decoration: BoxDecoration(
            color: AppColors.mainAppColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(7),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                AppImages.errorIcon,
                colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                width: 80,
                height: 80,
                fit: BoxFit.contain,
              ),
              10.sbH,
              Text(
                message ?? 'An error occurred'.tr,
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
              10.sbH,
              CustomButton(
                text: 'Reload'.tr,
                width: context.width * 0.5,
                prefixIcon: SvgPicture.asset(
                  AppImages.refreshIcon,
                  colorFilter: ColorFilter.mode(AppColors.buttonTextColor, BlendMode.srcIn),
                  width: 20,
                  height: 20,
                  fit: BoxFit.contain,
                ),
                height: 40,
                onPressed: onReload,
              ),
            ],
          ),
        );
    }
  }
}
