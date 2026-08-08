import 'package:flutter/material.dart';

import '../../../../helpers/extensions/extensions.dart';
import '../../../../helpers/routes/app_routers_import.dart';
import '../../../../helpers/theme/app_colors.dart';
import '../../../../helpers/theme/app_text_style.dart';
import '../../../../helpers/utils/date_methods.dart';
import '../../../custom_widgets/custom_image/custom_network_image.dart';
import '../../orders/screen/tracking_your_order_screen.dart';
import '../../request_delegate/screen/request_delegate_screen.dart';
import '../../wallet/screen/wallet_screen.dart';
import '../model/notifications_model.dart';

class NotificationWidget extends StatelessWidget {
  final NotificationsModel notification;
  final int? orderId;

  const NotificationWidget({super.key, required this.notification, required this.orderId});

  @override
  Widget build(BuildContext context) {
    final type = notification.data?.data?.notificationType;
    final isOrder = type == 1;
    final isWallet = type == 3;
    final accent = isWallet ? const Color(0xff7B4FD6) : isOrder ? AppColors.mainAppColor : const Color(0xffE3A21A);
    final icon = isWallet ? Icons.account_balance_wallet_outlined : isOrder ? Icons.inventory_2_outlined : Icons.card_giftcard_outlined;

    return Material(
      color: AppColors.whiteColor,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () {
          if (isWallet) {
            NamedNavigatorImpl.push(WalletScreen.routeName);
          } else if (isOrder) {
            if (notification.data?.data?.orderType == 'shipping') {
              NamedNavigatorImpl.push(RequestDelegateScreen.routeName);
            } else if (orderId != null) {
              NamedNavigatorImpl.push(
                TrackingYourOrderScreen.routeName,
                arguments: TrackingYourOrderArgs(id: orderId!),
              );
            }
          }
        },
        child: Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: AppColors.whiteColor,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xffEEEEEE)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .045),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            textDirection: TextDirection.rtl,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: CustomNetworkImage(
                  imageUrl: notification.data?.logo ?? '',
                  width: 70,
                  height: 70,
                  radius: 15,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      textDirection: TextDirection.rtl,
                      children: [
                        Expanded(
                          child: Text(
                            notification.data?.title ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.right,
                            style: AppTextStyle.text16BS(),
                          ),
                        ),
                        const SizedBox(width: 7),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
                        ),
                      ],
                    ),
                    const SizedBox(height: 7),
                    Text(
                      notification.data?.text ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                      style: AppTextStyle.text13RM().copyWith(color: const Color(0xff666666), height: 1.45),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      textDirection: TextDirection.rtl,
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(color: accent.withValues(alpha: .10), shape: BoxShape.circle),
                          child: Icon(icon, size: 16, color: accent),
                        ),
                        const Spacer(),
                        Icon(Icons.access_time_rounded, size: 15, color: const Color(0xffA0A0A0)),
                        const SizedBox(width: 4),
                        Text(
                          DateMethods.timeAgo(notification.createdAt ?? '', context),
                          style: AppTextStyle.text12RM().copyWith(color: const Color(0xff999999)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
