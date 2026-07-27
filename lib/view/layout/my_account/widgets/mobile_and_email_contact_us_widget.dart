import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../../helpers/extensions/extensions.dart';
import '../../../../helpers/hive/hive_methods.dart';
import '../../../../helpers/images/app_images.dart';
import '../../../../helpers/routes/app_routers_import.dart';
import '../../../../helpers/theme/app_colors.dart';
import '../../../../helpers/theme/app_text_style.dart';
import '../../../../helpers/translation/all_translation.dart';
import '../../../../helpers/utils/url_launcher_methods.dart';
import '../../auth/controller/auth_controller.dart';
import '../../chat/screen/admin_chat_screen.dart';
import '../controller/my_account_controller.dart';

class MobileAndEmailContactUsWidget extends StatelessWidget {
  final String mobile;
  final String email;
  final String adminId;
  final MyAccountController myAccountController;
  const MobileAndEmailContactUsWidget({
    super.key,
    required this.mobile,
    required this.email,
    required this.adminId,
    required this.myAccountController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.width,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      //  height: 169,
      decoration: const BoxDecoration(
        image: DecorationImage(fit: BoxFit.cover, image: AssetImage(AppImages.shapeContactUs)),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              UrlLauncherMethods.makePhoneCall(mobile);
            },
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.whiteColor,
                  radius: 25,
                  child: Center(
                    child: SvgPicture.asset(
                      AppImages.callIcon,
                      colorFilter: ColorFilter.mode(AppColors.blackColor, BlendMode.srcIn),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('mobileNumber'.tr, style: AppTextStyle.text18BW()),
                    5.sbH,
                    Text(mobile, style: AppTextStyle.text18BW()),
                  ],
                ),
              ],
            ),
          ),
          30.sbH,
          InkWell(
            onTap: () {
              UrlLauncherMethods.makeMailMessage(email);
            },
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.whiteColor,
                  radius: 25,
                  child: Center(child: SvgPicture.asset(AppImages.emailIcon, height: 15)),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('email'.tr, style: AppTextStyle.text18BW()),
                    5.sbH,
                    Text(email, style: AppTextStyle.text18BW()),
                    5.sbH,
                  ],
                ),
              ],
            ),
          ),
          30.sbH,
          HiveMethods.getToken() == null
              ? Container()
              : InkWell(
                  onTap: () {
                    NamedNavigatorImpl.push(
                      AdminChatScreen.routeName,
                      arguments: AdminChatScreenArgs(
                        receiverId: adminId,
                        senderId: context.read<AuthController>().profile!.id!.toString(),
                        adminId: myAccountController.setting!.adminId!,
                        adminDeviceToken: myAccountController.setting!.adminDeviceToken!,
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppColors.whiteColor,
                        radius: 25,
                        child: Center(
                          child: SvgPicture.asset(
                            AppImages.chatIcon,
                            height: 15,
                            colorFilter: ColorFilter.mode(AppColors.blackColor, BlendMode.srcIn),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Text('contactSupport'.tr, style: AppTextStyle.text18BW()),
                    ],
                  ),
                ),
        ],
      ),
    );
  }
}
