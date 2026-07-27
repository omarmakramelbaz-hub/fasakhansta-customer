import 'package:flutter/material.dart';

import '../../../../helpers/theme/app_colors.dart';
import '../../../../helpers/theme/app_text_style.dart';
import '../../../../helpers/translation/all_translation.dart';
import '../controller/cart_controller.dart';

class ExecuteOrderPricesWidget extends StatelessWidget {
  const ExecuteOrderPricesWidget({
    super.key,
    required this.totalPrice,
    required this.kmPrice,
    required this.serviceFees,
    required this.cartController,
    required this.addedPrice,
    required this.resturantMinOrderPrice,
  });

  final double totalPrice;
  final num kmPrice;
  final num serviceFees;
  final num addedPrice;
  final num resturantMinOrderPrice;
  final CartController cartController;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('paymentSummary'.tr, style: AppTextStyle.text16BS()),
          const SizedBox(height: 24),
          Row(
            children: [
              Text('subtotal'.tr, style: AppTextStyle.text16RG()),
              const Spacer(),
              Text('pound'.tr.replaceAll('{}', totalPrice.toString()), style: AppTextStyle.text16RG()),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Text('deliveryCharges'.tr, style: AppTextStyle.text16RG()),
              const Spacer(),
              //======== ======= todo: add km price acceding to location
              //علي حسب المسافة بالكيلو متر ولنفرصض مثلا انها كيلو متر واحد
              Text(
                kmPrice == 0 ? 'free'.tr : 'pound'.tr.replaceAll('{}', kmPrice.toStringAsFixed(2)),
                style: AppTextStyle.text16RG(),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Text('serviceFees'.tr, style: AppTextStyle.text16RG()),
              const Spacer(),
              Text(
                'pound'.tr.replaceAll('{}', serviceFees.toStringAsFixed(2)),
                style: AppTextStyle.text16RG(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text('addedValuePrice'.tr, style: AppTextStyle.text16RG()),
              const Spacer(),
              Text(
                'pound'.tr.replaceAll('{}', addedPrice.toStringAsFixed(2)),
                style: AppTextStyle.text16RG(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: AppColors.greyColor.withValues(alpha: 0.5), height: 2),
          const SizedBox(height: 16),
          Row(
            children: [
              Text('total'.tr, style: AppTextStyle.text16MS()),
              const Spacer(),
              Text(
                'pound'.tr.replaceAll(
                      '{}',
                      (totalPrice + serviceFees + kmPrice + addedPrice).toStringAsFixed(2),
                    ),
                style: AppTextStyle.text16MS(),
              ),
            ],
          ),
          // const SizedBox(
          //   height: 24,
          // ),
          // Text(
          //   'minOrderPrice'
          //       .tr
          //       .replaceAll("{}", "$resturantMinOrderPrice"),
          //   style: AppTextStyle.text16MS(),
          // ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
