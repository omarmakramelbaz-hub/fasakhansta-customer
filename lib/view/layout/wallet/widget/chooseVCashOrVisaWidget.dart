import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../../helpers/images/app_images.dart';
import '../../../../helpers/theme/app_colors.dart';
import '../../../../helpers/theme/app_text_style.dart';
import '../../my_account/controller/my_account_controller.dart';
import '../controller/wallet_controller.dart';

class ChooseVCashOrVisaWidget extends StatefulWidget {
  const ChooseVCashOrVisaWidget({
    super.key,
    required this.myAccountController,
  });

  final MyAccountController myAccountController;

  @override
  State<ChooseVCashOrVisaWidget> createState() => _ChooseVCashOrVisaWidgetState();
}

class _ChooseVCashOrVisaWidgetState extends State<ChooseVCashOrVisaWidget> {
  String? _selectedOptionKey;

  @override
  Widget build(BuildContext context) {
    final walletController = context.watch<WalletController>();
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final walletEnabled =
        widget.myAccountController.setting?.walletCardActivate == 'true';
    final cardEnabled =
        widget.myAccountController.setting?.paymentCardActivate == 'true';

    final methods = <_PaymentOptionData>[
      if (walletEnabled)
        _PaymentOptionData(
          keyName: 'orange_cash',
          label: isArabic ? 'أورنج كاش' : 'Orange Cash',
          backendMethod: 'v_cash',
          brand: const _BrandMark(
            text: 'orange',
            fontSize: 10,
            fontWeight: FontWeight.w800,
          ),
        ),
      if (walletEnabled)
        _PaymentOptionData(
          keyName: 'etisalat_cash',
          label: isArabic ? 'اتصالات كاش' : 'Etisalat Cash',
          backendMethod: 'v_cash',
          brand: const _BrandMark(
            text: 'e&',
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
      if (walletEnabled)
        _PaymentOptionData(
          keyName: 'vodafone_cash',
          label: isArabic ? 'فودافون كاش' : 'Vodafone Cash',
          backendMethod: 'v_cash',
          brand: Image.asset(
            AppImages.vfCash,
            height: 22,
            fit: BoxFit.contain,
          ),
        ),
      if (cardEnabled)
        _PaymentOptionData(
          keyName: 'bank_card',
          label: isArabic ? 'فيزا / ماستركارد' : 'Visa / Mastercard',
          backendMethod: 'online',
          brand: SvgPicture.asset(
            AppImages.visaIcon,
            height: 22,
            fit: BoxFit.contain,
          ),
        ),
    ];

    if (methods.isEmpty) {
      return Container(
        height: 66,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.lightGreyColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          isArabic
              ? 'لا توجد وسائل دفع متاحة حالياً'
              : 'No payment methods are currently available',
          textAlign: TextAlign.center,
          style: AppTextStyle.text12RG(),
        ),
      );
    }

    return SizedBox(
      height: 76,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: methods.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final method = methods[index];
          final selected = _selectedOptionKey == method.keyName &&
              walletController.selectedPayment == method.backendMethod;

          return PaymentMethodWidget(
            label: method.label,
            brand: method.brand,
            isSelected: selected,
            onTap: () {
              setState(() => _selectedOptionKey = method.keyName);
              walletController.setSelectedPayment(method.backendMethod);
            },
          );
        },
      ),
    );
  }
}

class _PaymentOptionData {
  final String keyName;
  final String label;
  final String backendMethod;
  final Widget brand;

  const _PaymentOptionData({
    required this.keyName,
    required this.label,
    required this.backendMethod,
    required this.brand,
  });
}

class PaymentMethodWidget extends StatelessWidget {
  final String label;
  final Widget brand;
  final bool isSelected;
  final VoidCallback onTap;

  const PaymentMethodWidget({
    super.key,
    required this.label,
    required this.brand,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: 104,
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 7),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFF7F0) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.mainAppColor : const Color(0xFFE6E6E6),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? const [
                  BoxShadow(
                    color: Color(0x18FD7201),
                    blurRadius: 10,
                    offset: Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 24, child: Center(child: brand)),
                const SizedBox(height: 5),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: AppTextStyle.text11RG().copyWith(
                    color: AppColors.darkTextColor,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ],
            ),
            Positioned(
              top: 0,
              left: 0,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? AppColors.mainAppColor : Colors.white,
                  border: Border.all(
                    color: isSelected
                        ? AppColors.mainAppColor
                        : const Color(0xFFBDBDBD),
                    width: 1.3,
                  ),
                ),
                child: isSelected
                    ? const Icon(Icons.check_rounded, size: 11, color: Colors.white)
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  final String text;
  final double fontSize;
  final FontWeight fontWeight;

  const _BrandMark({
    required this.text,
    required this.fontSize,
    required this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: 1,
      style: TextStyle(
        fontSize: fontSize,
        height: 1,
        fontWeight: fontWeight,
        color: AppColors.mainAppColor,
      ),
    );
  }
}
