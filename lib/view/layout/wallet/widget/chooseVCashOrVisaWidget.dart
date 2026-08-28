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
          label: isArabic ? 'أورنج' : 'Orange',
          backendMethod: 'v_cash',
          brand: const _BrandMark(
            text: 'orange',
            fontSize: 8.5,
            fontWeight: FontWeight.w800,
          ),
        ),
      if (walletEnabled)
        _PaymentOptionData(
          keyName: 'etisalat_cash',
          label: isArabic ? 'اتصالات' : 'Etisalat',
          backendMethod: 'v_cash',
          brand: const _BrandMark(
            text: 'e&',
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
      if (walletEnabled)
        _PaymentOptionData(
          keyName: 'vodafone_cash',
          label: isArabic ? 'فودافون' : 'Vodafone',
          backendMethod: 'v_cash',
          brand: Image.asset(
            AppImages.vfCash,
            height: 18,
            fit: BoxFit.contain,
          ),
        ),
      if (cardEnabled)
        _PaymentOptionData(
          keyName: 'bank_card',
          label: isArabic ? 'فيزا / ماستر' : 'Visa / MC',
          backendMethod: 'online',
          brand: SvgPicture.asset(
            AppImages.visaIcon,
            height: 18,
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

    // Keep the compact one-row layout while only the 3 wallet methods are
    // available. As soon as card payment becomes available, switch to a 2x2
    // grid so Visa/Mastercard is always visible without horizontal scrolling.
    if (methods.length <= 3) {
      return SizedBox(
        height: 76,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var index = 0; index < methods.length; index++) ...[
              if (index > 0) const SizedBox(width: 7),
              Expanded(
                child: _buildMethod(
                  method: methods[index],
                  walletController: walletController,
                ),
              ),
            ],
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = (constraints.maxWidth - 8) / 2;
        return Wrap(
          spacing: 8,
          runSpacing: 7,
          children: methods
              .map(
                (method) => SizedBox(
                  width: itemWidth,
                  height: 50,
                  child: _buildMethod(
                    method: method,
                    walletController: walletController,
                    compactHorizontal: true,
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }

  Widget _buildMethod({
    required _PaymentOptionData method,
    required WalletController walletController,
    bool compactHorizontal = false,
  }) {
    final selected = _selectedOptionKey == method.keyName &&
        walletController.selectedPayment == method.backendMethod;

    return PaymentMethodWidget(
      label: method.label,
      brand: method.brand,
      isSelected: selected,
      compactHorizontal: compactHorizontal,
      onTap: () {
        setState(() => _selectedOptionKey = method.keyName);
        walletController.setSelectedPayment(method.backendMethod);
      },
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
  final bool compactHorizontal;
  final VoidCallback onTap;

  const PaymentMethodWidget({
    super.key,
    required this.label,
    required this.brand,
    required this.isSelected,
    required this.onTap,
    this.compactHorizontal = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: double.infinity,
        padding: compactHorizontal
            ? const EdgeInsets.symmetric(horizontal: 8, vertical: 6)
            : const EdgeInsets.fromLTRB(4, 7, 4, 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFF7F0) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.mainAppColor : const Color(0xFFE6E6E6),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? const [
                  BoxShadow(
                    color: Color(0x18FD7201),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: compactHorizontal
            ? Row(
                children: [
                  _selectionDot(),
                  const SizedBox(width: 7),
                  SizedBox(width: 28, child: Center(child: brand)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyle.text10RG().copyWith(
                        color: AppColors.darkTextColor,
                        fontSize: 9.5,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              )
            : Stack(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 21,
                        width: double.infinity,
                        child: Center(child: brand),
                      ),
                      const SizedBox(height: 5),
                      SizedBox(
                        width: double.infinity,
                        child: Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: AppTextStyle.text10RG().copyWith(
                            color: AppColors.darkTextColor,
                            fontSize: 9,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Positioned(top: 0, left: 0, child: _selectionDot()),
                ],
              ),
      ),
    );
  }

  Widget _selectionDot() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? AppColors.mainAppColor : Colors.white,
        border: Border.all(
          color: isSelected ? AppColors.mainAppColor : const Color(0xFFBDBDBD),
          width: 1.2,
        ),
      ),
      child: isSelected
          ? const Icon(Icons.check_rounded, size: 9, color: Colors.white)
          : null,
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
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: fontSize,
        height: 1,
        fontWeight: fontWeight,
        color: AppColors.mainAppColor,
      ),
    );
  }
}
