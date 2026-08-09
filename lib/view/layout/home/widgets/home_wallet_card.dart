import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../helpers/routes/app_routers_import.dart';
import '../../../../helpers/theme/app_colors.dart';
import '../../../../helpers/theme/app_text_style.dart';
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
        // Keep the card visible even while the wallet request is loading or fails.
        // The real balance replaces the fallback as soon as the request succeeds.
        return _WalletContent(balance: controller.wallet?.balance ?? 0);
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
      margin: const EdgeInsets.fromLTRB(30, 0, 30, 14),
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.offWhiteColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.account_balance_wallet_outlined,
              size: 42,
              color: AppColors.mainAppColor,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('المحفظة', style: AppTextStyle.text15BS()),
                const SizedBox(height: 1),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      balance.toStringAsFixed(2),
                      style: AppTextStyle.text20BS().copyWith(
                        fontSize: 28,
                        color: AppColors.blackColor,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text('جنيه', style: AppTextStyle.text13MS()),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
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

  const _WalletButton({
    required this.title,
    required this.filled,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 17),
        label: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
        style: OutlinedButton.styleFrom(
          backgroundColor: filled ? AppColors.mainAppColor : AppColors.whiteColor,
          foregroundColor: filled ? AppColors.whiteColor : AppColors.blackColor,
          side: BorderSide(color: AppColors.mainAppColor, width: 1.4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
          padding: const EdgeInsets.symmetric(horizontal: 5),
          textStyle: AppTextStyle.text11BS(),
        ),
      ),
    );
  }
}
