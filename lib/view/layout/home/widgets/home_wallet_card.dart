import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../helpers/routes/app_routers_import.dart';
import '../../../../helpers/theme/app_colors.dart';
import '../../../../helpers/theme/app_text_style.dart';
import '../../../custom_widgets/api_response_widget/api_response_widget.dart';
import '../../wallet/controller/wallet_controller.dart';
import '../../wallet/screen/wallet_screen.dart';

class HomeWalletCard extends StatefulWidget {
  const HomeWalletCard({super.key});

  @override
  State<HomeWalletCard> createState() => _HomeWalletCardState();
}

class _HomeWalletCardState extends State<HomeWalletCard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = context.read<WalletController>();
      if (controller.wallet == null) controller.getWallet();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WalletController>(
      builder: (context, controller, _) {
        return ApiResponseWidget(
          apiResponse: controller.walletResponse,
          onReload: controller.getWallet,
          isEmpty: controller.wallet == null,
          loadingWidget: const _WalletSkeleton(),
          errorWidget: const SizedBox.shrink(),
          emptyWidget: const SizedBox.shrink(),
          child: _WalletContent(balance: controller.wallet?.balance ?? 0),
        );
      },
    );
  }
}

class _WalletContent extends StatelessWidget {
  final double balance;

  const _WalletContent({required this.balance});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderColorContainer),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.06),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('المحفظة', style: AppTextStyle.text14BS()),
                const SizedBox(height: 2),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      balance.toStringAsFixed(2),
                      style: AppTextStyle.text20BS().copyWith(fontSize: 28, color: AppColors.blackColor),
                    ),
                    const SizedBox(width: 6),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: Text('جنيه', style: AppTextStyle.text14MS()),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _WalletButton(
                        title: 'شحن المحفظة',
                        filled: true,
                        icon: Icons.add,
                        onTap: () => NamedNavigatorImpl.push(WalletScreen.routeName),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _WalletButton(
                        title: 'تفاصيل المحفظة',
                        filled: false,
                        icon: Icons.account_balance_wallet_outlined,
                        onTap: () => NamedNavigatorImpl.push(WalletScreen.routeName),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Container(
            width: 82,
            height: 82,
            decoration: BoxDecoration(
              color: AppColors.offWhiteColor,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(Icons.account_balance_wallet_outlined, size: 48, color: AppColors.mainAppColor),
          ),
        ],
      ),
    );
  }
}

class _WalletButton extends StatelessWidget {
  final String title;
  final bool filled;
  final IconData icon;
  final VoidCallback onTap;

  const _WalletButton({required this.title, required this.filled, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18),
        label: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
        style: OutlinedButton.styleFrom(
          backgroundColor: filled ? AppColors.mainAppColor : AppColors.whiteColor,
          foregroundColor: filled ? AppColors.whiteColor : AppColors.blackColor,
          side: BorderSide(color: AppColors.mainAppColor, width: 1.2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          textStyle: AppTextStyle.text14BS(),
        ),
      ),
    );
  }
}

class _WalletSkeleton extends StatelessWidget {
  const _WalletSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 156,
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 6),
      decoration: BoxDecoration(
        color: AppColors.lightGreyColor,
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}
