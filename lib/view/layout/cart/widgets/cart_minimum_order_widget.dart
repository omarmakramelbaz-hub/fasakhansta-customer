import 'package:flutter/material.dart';

import '../../../../helpers/theme/app_colors.dart';
import '../../../../helpers/theme/app_text_style.dart';
import '../../../../helpers/translation/all_translation.dart';

class CartMinimumOrderWidget extends StatelessWidget {
  final double current;
  final double minimum;

  const CartMinimumOrderWidget({super.key, required this.current, required this.minimum});

  @override
  Widget build(BuildContext context) {
    if (minimum <= 0) return const SizedBox.shrink();
    final progress = (current / minimum).clamp(0.0, 1.0);
    final remaining = (minimum - current).clamp(0.0, minimum);
    final reached = remaining <= 0;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.greyColor.withValues(alpha: .12)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: .04), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.mainAppColor.withValues(alpha: .10),
              shape: BoxShape.circle,
            ),
            child: Icon(
              reached ? Icons.check_rounded : Icons.local_shipping_outlined,
              color: AppColors.mainAppColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  reached
                      ? 'minimumOrderReached'.tr
                      : 'remainingForFreeDelivery'.tr.replaceAll('{}', remaining.toStringAsFixed(0)),
                  textAlign: TextAlign.right,
                  style: AppTextStyle.text14BS(),
                ),
                const SizedBox(height: 9),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: AppColors.mainAppColor.withValues(alpha: .10),
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.mainAppColor),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.mainAppColor.withValues(alpha: .07),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text('minimum'.tr, style: AppTextStyle.text12RG()),
                const SizedBox(height: 2),
                Text(
                  'pound'.tr.replaceAll('{}', minimum.toStringAsFixed(0)),
                  style: AppTextStyle.text14BS().copyWith(color: AppColors.mainAppColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
