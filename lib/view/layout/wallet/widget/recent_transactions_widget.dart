import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../../helpers/images/app_images.dart';
import '../../../../helpers/theme/app_colors.dart';
import '../../../../helpers/theme/app_text_style.dart';
import '../../../../helpers/translation/all_translation.dart';
import '../../../../helpers/utils/date_methods.dart';
import '../../../custom_widgets/custom_image/custom_image.dart';
import '../../auth/controller/auth_controller.dart';
import '../model/wallet_model.dart';

class RecentTransactionsWidget extends StatelessWidget {
  final List<WalletModel>? wallet;

  const RecentTransactionsWidget({super.key, required this.wallet});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ...List.generate(wallet?.length ?? 0, (int index) {
          bool isFromMe = (context.read<AuthController>().profile?.id == wallet?[index].fromUser);
          bool isToMe = (context.read<AuthController>().profile?.id == wallet?[index].toUser);
          log(context.read<AuthController>().profile?.id.toString() ?? 'unknown');
          return Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 10),
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: AppColors.greyColor.withValues(alpha: .10)),
              ),
              child: Row(
                children: [
                  Container(
                    margin: const EdgeInsets.all(10),
                    padding: const EdgeInsets.all(5),
                    width: 47,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.whiteColor,
                      boxShadow: [BoxShadow(color: AppColors.greyColor, blurRadius: 4, offset: const Offset(0, 2))],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: wallet?[index].payment == 'visa'
                        ? SvgPicture.asset(AppImages.visaIcon)
                        : wallet?[index].payment == 'wallet'
                            ? const CustomImage(path: AppImages.payWalletIcon, type: ImageType.svg, height: 20)
                            : wallet?[index].payment == 'online'
                                ? const CustomImage(path: AppImages.visaIcon, type: ImageType.svg)
                                : Image.asset(AppImages.digitalWallet, height: 25),
                  ),
                  Expanded(
                    child: Text(
                      "${'theAmountIs'.tr.replaceAll("{}", buildTransaction(transaction: wallet?[index].type ?? ""))} ${'pound'.tr.replaceAll("{}", wallet?[index].amount.toString() ?? "")} ${'paymentTypeIs'.tr.replaceAll("{}", buildPaymentType(paymentType: wallet?[index].payment ?? ""))} ${wallet?[index].fromUserName != null && wallet?[index].toUserName != null ? 'fromUser'.tr.replaceAll("{}", isFromMe ? 'yourWallet'.tr : wallet?[index].fromUserName ?? "") : ""}  ${wallet?[index].toUserName != null ? 'toUser'.tr.replaceAll("{}", isToMe ? 'yourWallet'.tr : wallet?[index].toUserName ?? "") : ""}  ${wallet?[index].orderNo != null ? 'orderNumber'.tr.replaceAll("{}", wallet?[index].orderNo ?? "") : ""} ",
                      style: AppTextStyle.text16MS().copyWith(height: 2),
                      maxLines: 4,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    DateMethods.formatToDate(wallet?[index].createdAt ?? ''),
                    style: AppTextStyle.text16MS(),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  String buildTransaction({required String transaction}) {
    switch (transaction) {
      case 'transfer':
        return 'transfer'.tr;
      case 'charging':
        return 'charging'.tr;
      case 'withdraw':
        return 'withdraw'.tr;
      case 'shipping':
        return 'shipping'.tr;
      default:
        return '';
    }
  }

  String buildPaymentType({required String paymentType}) {
    switch (paymentType) {
      case 'wallet':
        return 'theWallet'.tr;
      case 'online':
        return 'visa'.tr;
      case 'visa':
        return 'visa'.tr;
      case 'v_cash':
        return 'digitalWalletAndInstaPay'.tr;
      default:
        return '';
    }
  }
}
