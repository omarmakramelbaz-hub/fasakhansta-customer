import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../helpers/extensions/extensions.dart';
import '../../../../helpers/images/app_images.dart';
import '../../../../helpers/routes/app_routers_import.dart';
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
    return InkWell(
      onTap: () {
        if (notification.data?.data?.notificationType == 3) {
          NamedNavigatorImpl.push(WalletScreen.routeName);
        } else if (notification.data?.data?.notificationType == 1) {
          if (notification.data?.data?.orderType == 'shipping') {
            NamedNavigatorImpl.push(RequestDelegateScreen.routeName);
          } else {
            NamedNavigatorImpl.push(
              TrackingYourOrderScreen.routeName,
              arguments: TrackingYourOrderArgs(id: orderId!),
            );
          }
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomNetworkImage(
                imageUrl: notification.data?.logo ?? '',
                width: context.width * 0.1,
                height: context.width * 0.1,
                radius: 25,
                fit: BoxFit.cover,
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(notification.data?.title ?? '', style: AppTextStyle.text16MS())),
              SvgPicture.asset(AppImages.timeIcon),
              const SizedBox(width: 10),
              Text(DateMethods.timeAgo(notification.createdAt ?? '', context), style: AppTextStyle.text16RM()),
            ],
          ),
          15.sbH,
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Padding(
              //   padding: const EdgeInsets.symmetric(
              //     horizontal: 5,
              //   ),
              //   child: CircleAvatar(
              //     backgroundColor: AppColor.mainAppColor,
              //     radius: 6,
              //   ),
              // ),
              const SizedBox(width: 10),
              Expanded(child: Text(notification.data?.text ?? '', style: AppTextStyle.text16MS())),
            ],
          ),
        ],
      ),
    );
  }
}
