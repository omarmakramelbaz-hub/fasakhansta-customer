import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../helpers/extensions/extensions.dart';
import '../../../../helpers/images/app_images.dart';
import '../../../../helpers/routes/app_routers_import.dart';
import '../../../../helpers/theme/app_colors.dart';
import '../../../../helpers/theme/app_text_style.dart';
import '../../../../helpers/translation/all_translation.dart';
import '../../../../helpers/utils/url_launcher_methods.dart';
import '../../../custom_widgets/custom_image/custom_network_image.dart';
import '../../chat/screen/chat_screen.dart';
import '../model/orders_model.dart';

class DeliveryAgentWidget extends StatelessWidget {
  final OrdersModel? orders;
  const DeliveryAgentWidget({super.key, required this.orders});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 35,
            backgroundColor: AppColors.mainAppColor,
            child: CustomNetworkImage(
              imageUrl: orders?.delegateLogo ?? '',
              radius: 35,
              fit: BoxFit.fitHeight,
              height: 70,
              width: 70,
            ),
          ),
          const SizedBox(width: 10),
          Column(
            children: [
              Text('deliveryAgent'.tr, style: AppTextStyle.text14RS()),
              5.sbH,
              Text(orders?.delegateName ?? '', style: AppTextStyle.text16BS()),
            ],
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {
              UrlLauncherMethods.makePhoneCall(orders?.delegateMobile ?? '');
            },
            child: Card(
              elevation: 10,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.mainAppColor,
                child: SvgPicture.asset(AppImages.callIcon),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              NamedNavigatorImpl.push(
                ChatScreen.routeName,
                arguments: ChatScreenArgs(
                  orderId: 'DC${orders?.id ?? 0}',
                  accountType: 'user',
                  isVendor: false,
                  receiverDeviceToken: orders?.delegateFcmId ?? '',
                  receiverName: orders?.delegateName ?? '',
                  senderDeviceToken: orders?.userFcmId ?? '',
                  senderName: orders?.userName ?? '',
                  vendorDeviceToken: orders?.resturantVendorDeviceToken ?? '',
                ),
              );
            },
            child: Card(
              elevation: 10,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.mainAppColor,
                child: SvgPicture.asset(AppImages.chatIcon),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
