import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../helpers/extensions/extensions.dart';
import '../../../../helpers/routes/app_routers_import.dart';
import '../../../../helpers/translation/all_translation.dart';
import '../../../../helpers/utils/common_methods.dart';
import '../../../custom_widgets/buttons/custom_button.dart';
import '../../../custom_widgets/custom_form_field/custom_form_field.dart';
import '../../../custom_widgets/custom_payment_web_view/custom_payment_web_view.dart';
import '../../../custom_widgets/global_widgets/app_bottom_sheet.dart';
import '../../auth/controller/auth_controller.dart';
import '../../my_account/controller/my_account_controller.dart';
import '../controller/wallet_controller.dart';
import '../widget/chooseVCashOrVisaWidget.dart';

class ChargeWalletBottomSheet extends StatefulWidget {
  const ChargeWalletBottomSheet({super.key, required this.walletController, required this.myAccountController});
  final WalletController walletController;
  final MyAccountController myAccountController;

  @override
  State<ChargeWalletBottomSheet> createState() => _ChargeWalletBottomSheetState();
}

class _ChargeWalletBottomSheetState extends State<ChargeWalletBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        final authController = context.read<AuthController>();
        final walletController = widget.walletController;
        final myAccountController = widget.myAccountController;
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Form(
                  key: walletController.chargeWalletFormKey,
                  child: AppBottomSheet(
                    title: 'walletCharging'.tr,
                    children: [
                      CustomFormField(
                        title: 'chargeAmount'.tr,
                        controller: walletController.chargeAmountEc,
                        keyboardType: TextInputType.number,
                        focusNode: walletController.chargeAmountFocusNode,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        onFieldSubmitted: (p0) {
                          walletController.chargeAmountFocusNode.unfocus();
                        },
                        validator: (p0) {
                          if (p0 == null || p0.isEmpty) {
                            return 'enterAmount'.tr;
                          } else if (double.tryParse(p0)! < 50) {
                            return 'minimumChargeAmount'.tr.replaceAll('{}', '50');
                          }
                          return null;
                        },
                      ),
                      21.sbH,
                      ChooseVCashOrVisaWidget(myAccountController: myAccountController),
                      21.sbH,
                      CustomButton(
                        text: 'payNow'.tr,
                        onPressed: () {
                          if (walletController.chargeWalletFormKey.currentState!.validate() &&
                              walletController.selectedPayment != null) {
                            context.read<WalletController>().chargingWallet(
                                  amount: walletController.chargeAmountEc.text,
                                  onSuccess: (link) {
                                    log(link);
                                    NamedNavigatorImpl.push(
                                      CustomPaymentWebViewScreen.routeName,
                                      arguments: PaymentArgs(
                                        url: link,
                                        onFailed: () {
                                          CommonMethods.showError(message: 'paymentFailed'.tr);
                                        },
                                        onSuccess: () {
                                          Navigator.pop(context);
                                          walletController.getWallet();
                                          authController.getProfile();
                                        },
                                      ),
                                    );
                                  },
                                );
                          }
                          if (walletController.selectedPayment == null) {
                            CommonMethods.showError(message: 'youMustChoosePaymentMethod'.tr);
                          }
                        },
                      ),
                      30.sbH,
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
