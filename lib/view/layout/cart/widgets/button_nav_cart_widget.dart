import 'package:flutter/material.dart';

import '../../../../helpers/theme/app_colors.dart';
import '../../../../helpers/theme/app_text_style.dart';
import '../../../../helpers/translation/all_translation.dart';

class ButtonNavCartWidget extends StatelessWidget {
  final Function()? onPressedExecuteTheOrder;
  final Function()? onTapAddItems;
  final String totalInCart;
  const ButtonNavCartWidget({super.key, this.onPressedExecuteTheOrder, this.onTapAddItems, required this.totalInCart});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressedExecuteTheOrder,
      child: Container(
        height: 74,
        decoration: BoxDecoration(
          color: AppColors.whiteColor,
          boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.5), blurRadius: 10, offset: const Offset(0, 0))],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Container(
          decoration: BoxDecoration(color: AppColors.mainAppColor, borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('continueToPayment'.tr, style: AppTextStyle.text16BW()),
                Text('pound'.tr.replaceAll('{}', totalInCart), style: AppTextStyle.text16BW()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
