import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../helpers/images/app_images.dart';
import '../../../../helpers/theme/app_colors.dart';
import '../../../../helpers/theme/app_text_style.dart';
import '../../../../helpers/translation/all_translation.dart';
import '../../../custom_widgets/custom_image/custom_image.dart';
import '../../my_account/controller/my_account_controller.dart';
import '../controller/request_delegate_controller.dart';

class ChoosePaymentMethodWidget extends StatelessWidget {
  const ChoosePaymentMethodWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MyAccountController()
        ..initialSetting()
        ..getSetting(),
      child: Consumer<MyAccountController>(
        builder: (context, myAccountController, _) {
          return Column(
            children: [
              PaymentMethodWidget(
                label: 'cash'.tr,
                selectedPayment: 'cash',
                leading: CustomImage(path: AppImages.cashIcon, type: ImageType.svg, color: AppColors.whiteColor),
              ),
              const SizedBox(height: 16),
              PaymentMethodWidget(
                label: 'appWalletBalance'.tr,
                selectedPayment: 'wallet',
                leading: CustomImage(
                  path: AppImages.payWalletIcon,
                  type: ImageType.svg,
                  color: AppColors.whiteColor,
                  height: 20,
                ),
              ),
              const SizedBox(height: 16),
              myAccountController.setting?.paymentCardActivate == 'true'
                  ? PaymentMethodWidget(
                      label: 'creditCard'.tr,
                      selectedPayment: 'online',
                      leading: const CustomImage(path: AppImages.visaIcon, type: ImageType.svg),
                    )
                  : const SizedBox(),
              const SizedBox(height: 16),
              myAccountController.setting?.walletCardActivate == 'true'
                  ? PaymentMethodWidget(
                      label: 'digitalWalletAndInstaPay'.tr,
                      selectedPayment: 'v_cash',
                      leading: const CustomImage(path: AppImages.vfCash, type: ImageType.asset),
                    )
                  : const SizedBox(),
            ],
          );
        },
      ),
    );
  }
}

class PaymentMethodWidget extends StatelessWidget {
  final String label;

  final String selectedPayment;
  final String? iconColor;
  final Widget leading;

  const PaymentMethodWidget({
    super.key,
    required this.label,
    required this.selectedPayment,
    this.iconColor,
    required this.leading,
  });

  @override
  Widget build(BuildContext context) {
    final requestDelegateController = context.watch<RequestDelegateController>();
    final isSelected = requestDelegateController.selectedPayment == selectedPayment;
    return InkWell(
      onTap: () => requestDelegateController.setSelectedPayment(selectedPayment),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: AppColors.blackColor,
          border: Border.all(color: isSelected ? AppColors.mainAppColor : AppColors.borderColor, width: 1),
        ),
        child: Center(
          child: Row(
            children: [
              leading,
              const SizedBox(width: 10),
              Text(label, style: AppTextStyle.text16MS().copyWith(color: AppColors.whiteColor)),
              const Spacer(),
              isSelected
                  ? Container(
                      height: 16,
                      width: 16,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(width: 1.3, color: AppColors.mainAppColor),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: CircleAvatar(backgroundColor: AppColors.mainAppColor),
                      ),
                    )
                  : const SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
}
