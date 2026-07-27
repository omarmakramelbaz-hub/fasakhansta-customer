import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';

import '../../../../helpers/extensions/extensions.dart';
import '../../../../helpers/images/app_images.dart';
import '../../../../helpers/pusher_service/pusher_controller.dart';
import '../../../../helpers/routes/app_routers_import.dart';
import '../../../../helpers/theme/app_colors.dart';
import '../../../../helpers/theme/app_text_style.dart';
import '../../../../helpers/translation/all_translation.dart';
import '../../../../helpers/utils/utils.dart';
import '../../../custom_widgets/api_response_widget/api_response_widget.dart';
import '../../../custom_widgets/buttons/custom_button.dart';
import '../../../custom_widgets/page_container/page_container.dart';
import '../../auth/controller/auth_controller.dart';
import '../../my_account/account_app_bar/account_app_bar.dart';
import '../../my_account/controller/my_account_controller.dart';
import '../../my_account/screen/personal_information_screen.dart';
import '../bottom_sheet/charge_wallet_bottom_sheet.dart';
import '../bottom_sheet/mony_transfer_bottom_sheet.dart';
import '../controller/wallet_controller.dart';
import '../model/wallet_model.dart';
import '../widget/my_current_balance_widget.dart';
import '../widget/recent_transactions_widget.dart';

class WalletScreen extends StatefulWidget {
  static const String routeName = 'WalletScreen';
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  late PusherController _pusherController;

  String? pusherWalletAmount;

  @override
  void initState() {
    super.initState();

    _pusherController = context.read<PusherController>();
    _pusherController.addEventListener('balance.updated', _handleWalletUpdate);
  }

  void _handleWalletUpdate(PusherEvent event) {
    try {
      var jsonData = jsonDecode(event.data) as Map<String, dynamic>;
      log('Wallet updated: $jsonData');

      String amount = jsonData['user_balance']?.toString() ?? '0';
      pusherWalletAmount = num.parse(amount).toStringAsFixed(2);

      log('Notification updated: $jsonData');
      if (mounted) {
        var transaction = WalletModel.fromJson(jsonData);
        // context.read<WalletController>().getWallet();
        context.read<WalletController>().updateWallet(transaction: transaction);
      }
    } catch (e, stackTrace) {
      log('Error handling Pusher event: $e');
      log('Stack trace: $stackTrace');
    }
  }

  @override
  dispose() {
    _pusherController.removeEventListener('balance.updated', _handleWalletUpdate);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<WalletController, MyAccountController>(
      builder: (context, walletController, myAccountController, _) {
        final authController = context.read<AuthController>();

        return Scaffold(
          extendBody: true,
          body: PageContainer(
            bottom: false,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  24.sbH,
                  CustomAccountAppBar(title: 'theWallet'.tr),
                  22.sbH,
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.whiteColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(34),
                        topRight: Radius.circular(34),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.greyColor.withValues(alpha: 0.2),
                          offset: const Offset(0, -3),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            24.sbH,
                            Row(
                              children: [
                                if (authController.profile?.gender == 'male')
                                  SvgPicture.asset(AppImages.avatarMale)
                                else if (authController.profile?.gender == 'female')
                                  SvgPicture.asset(AppImages.avatarFemale)
                                else
                                  CircleAvatar(
                                    backgroundColor: AppColors.mainAppColor,
                                    child: Text(
                                      authController.profile?.name?.substring(0, 1) ?? '',
                                      style: AppTextStyle.text20MW(),
                                    ),
                                  ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      authController.profile?.name ?? '',
                                      style: AppTextStyle.text18MS(),
                                    ),
                                    5.sbH,
                                    Row(
                                      children: [
                                        // SvgPicture.asset(AppImages.egyptIcon),
                                        const SizedBox(width: 10),
                                        Text(
                                          authController.profile?.areaTitle ?? '',
                                          style: AppTextStyle.text16RG(),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                        const Divider(),
                        15.sbH,
                        MyCurrentBalanceWidget(wallet: walletController.wallet, pusherWalletAmount: pusherWalletAmount),
                        20.sbH,
                        CustomButton(
                          text: 'moneyTransfer'.tr,
                          onPressed: () {
                            Utils.showAppBottomSheet(
                              enableDrag: true,
                              isScrollControlled: true,
                              ChangeNotifierProvider.value(
                                value: walletController,
                                child: MoneyTransferBottomSheet(walletController: walletController),
                              ),
                            );
                          },
                        ),
                        32.sbH,
                        Text('recentTransactions'.tr, style: AppTextStyle.text18BS()),
                        15.sbH,
                        ApiResponseWidget(
                          apiResponse: walletController.walletResponse,
                          onReload: walletController.getWallet,
                          isEmpty: walletController.wallet?.wallet?.isEmpty ?? true,
                          child: RecentTransactionsWidget(wallet: walletController.wallet?.wallet),
                        ),
                        100.sbH,
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: (myAccountController.setting?.walletCardActivate == 'false' &&
                    myAccountController.setting?.paymentCardActivate == 'false')
                ? const SizedBox()
                : CustomButton(
                    text: 'walletCharging'.tr,
                    onPressed: () {
                      if (authController.profile?.email == null) {
                        NamedNavigatorImpl.push(PersonalInformationScreen.routeName);
                      } else {
                        Utils.showAppBottomSheet(
                          enableDrag: true,
                          isScrollControlled: true,
                          ChangeNotifierProvider.value(
                            value: walletController,
                            child: ChargeWalletBottomSheet(
                              walletController: walletController,
                              myAccountController: myAccountController,
                            ),
                          ),
                        );
                      }
                    },
                  ),
          ),
        );
      },
    );
  }
}
