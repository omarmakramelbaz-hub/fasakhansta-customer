import 'package:flutter/material.dart';

import '../../../../helpers/extensions/extensions.dart';
import '../../../../helpers/translation/all_translation.dart';
import '../../../custom_widgets/buttons/custom_button.dart';
import '../../../custom_widgets/global_widgets/dark_app_bottom_sheet.dart';
import '../controller/request_delegate_controller.dart';
import '../widget/payment_methoud_widget.dart';

class PaymentRDBottomSheet extends StatelessWidget {
  const PaymentRDBottomSheet({super.key, required this.requestDelegateController});

  final RequestDelegateController requestDelegateController;

  @override
  Widget build(BuildContext context) {
    return DarkAppBottomSheet(
      title: 'paymentMethod'.tr,
      isDark: true,
      children: [
        15.sbH,
        const ChoosePaymentMethodWidget(),
        15.sbH,
        CustomButton(
          text: 'save'.tr,
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}
