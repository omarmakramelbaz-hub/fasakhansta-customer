import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../../helpers/extensions/extensions.dart';
import '../../../../helpers/images/app_images.dart';
import '../../../../helpers/theme/app_colors.dart';
import '../../../../helpers/theme/app_text_style.dart';
import '../../../../helpers/translation/all_translation.dart';
import '../../my_account/controller/my_account_controller.dart';
import '../controller/cart_controller.dart';

class ChooseCashOrVisaOrVCashWidget extends StatelessWidget {
  const ChooseCashOrVisaOrVCashWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MyAccountController()
        ..initialSetting()
        ..getSetting(),
      child: Consumer<MyAccountController>(
        builder: (context, controller, _) {
          return Column(
            children: [
              PaymentMethodWidget(icon: AppImages.cashIcon, label: 'cash'.tr, selectedPayment: 'cash'),
              16.sbH,
              // if (Platform.isIOS) ...[
              //   const PaymentMethodWidget(
              //     icon: AppImages.appleLoginIcon,
              //     label: 'Apple Pay',
              //     selectedPayment: 'apple_pay',
              //     isSvg: false,
              //   ),
              //   16.sbH,
              // ],
              PaymentMethodWidget(
                icon: AppImages.walletImage,
                label: 'appWalletBalance'.tr,
                selectedPayment: 'wallet',
                isSvg: false,
              ),
              16.sbH,
              if (controller.setting?.paymentCardActivate == 'true') ...[
                PaymentMethodWidget(
                  icon: AppImages.visaIcon,
                  label: 'creditCard'.tr,
                  selectedPayment: 'online',
                ),
                16.sbH,
              ],
              if (controller.setting?.walletCardActivate == 'true')
                PaymentMethodWidget(
                  icon: AppImages.digitalWallet,
                  label: 'digitalWalletAndInstaPay'.tr,
                  selectedPayment: 'v_cash',
                  isSvg: false,
                ),
            ],
          );
        },
      ),
    );
  }
}

class PaymentMethodWidget extends StatelessWidget {
  final String icon;
  final String label;
  final bool isSvg;
  final String selectedPayment;

  const PaymentMethodWidget({
    super.key,
    required this.icon,
    required this.label,
    this.isSvg = true,
    required this.selectedPayment,
  });

  @override
  Widget build(BuildContext context) {
    final cartController = context.watch<CartController>();
    final isSelected = cartController.selectedPayment == selectedPayment;
    return InkWell(
      onTap: () => cartController.setSelectedPayment(selectedPayment),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: AppColors.whiteColor,
          border: Border.all(color: isSelected ? AppColors.mainAppColor : AppColors.borderColor, width: 1),
        ),
        child: Center(
          child: Row(
            children: [
              isSvg ? SvgPicture.asset(icon) : Image.asset(icon, height: 25),
              const SizedBox(width: 10),
              Text(label, style: AppTextStyle.text16MS()),
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
