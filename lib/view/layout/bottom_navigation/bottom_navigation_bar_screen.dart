import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:upgrader/upgrader.dart';

import '../../../helpers/hive/hive_methods.dart';
import '../../../helpers/images/app_images.dart';
import '../../../helpers/routes/app_routers_import.dart';
import '../../../helpers/theme/app_colors.dart';
import '../../../helpers/theme/app_text_style.dart';
import '../../../helpers/translation/all_translation.dart';
import '../../../helpers/utils/common_methods.dart';
import '../auth/controller/auth_controller.dart';
import '../auth/screen/register_screen.dart';
import 'controller/bottom_nav_controller.dart';

class BottomNavigationBarScreen extends StatefulWidget {
  static const String routeName = 'BottomNavigationBarScreen';
  const BottomNavigationBarScreen({super.key});

  @override
  State<BottomNavigationBarScreen> createState() => _BottomNavigationBarScreenState();
}

class _BottomNavigationBarScreenState extends State<BottomNavigationBarScreen> {
  late BottomNavLogicController logic;

  @override
  void initState() {
    super.initState();
    logic = BottomNavLogicController();
    logic.init();
  }

  @override
  void dispose() {
    logic.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BottomNavigationController(),
      child: Consumer<BottomNavigationController>(
        builder: (context, controller, _) {
          return PopScope(
            canPop: controller.screenIndex == 0,
            onPopInvoked: controller.onWillPop,
            child: UpgradeAlert(
              dialogStyle: UpgradeDialogStyle.cupertino,
              showLater: true,
              upgrader: Upgrader(
                debugLogging: false,
                debugDisplayAlways: false,
                debugDisplayOnce: false,
                languageCode: context.languageCode,
                messages: UpgraderMessages(code: context.languageCode),
                countryCode: 'EG',
              ),
              child: Scaffold(
                resizeToAvoidBottomInset: false,
                body: logic.getCurrentScreen(controller.screenIndex),
                bottomNavigationBar: _buildBottomNavBar(controller),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBottomNavBar(BottomNavigationController controller) {
    return BottomAppBar(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      color: AppColors.whiteColor,
      shape: const CircularNotchedRectangle(),
      notchMargin: 10,
      child: SizedBox(
        height: 80,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _navItem(
                index: 0,
                controller: controller,
                iconSelected: AppImages.homeIcon,
                iconUnselected: AppImages.homeUnselectedIcon,
                title: 'home'.tr,
                onTap: () => controller.updateIndex(0),
              ),
              _navOrders(controller),
              _navNotifications(controller),
              _navItem(
                index: 3,
                controller: controller,
                iconSelected: AppImages.accountFillIcon,
                iconUnselected: AppImages.myAccountIcon,
                title: 'account'.tr,
                onTap: () => controller.updateIndex(3),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem({
    required int index,
    required BottomNavigationController controller,
    required String iconSelected,
    required String iconUnselected,
    required String title,
    required VoidCallback onTap,
  }) {
    final selected = controller.screenIndex == index;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: onTap,
          icon: SvgPicture.asset(
            selected ? iconSelected : iconUnselected,
            colorFilter: ColorFilter.mode(
              selected ? AppColors.mainAppColor : AppColors.greyColor,
              BlendMode.srcIn,
            ),
          ),
        ),
        Text(
          title,
          style: selected ? AppTextStyle.text14RM() : AppTextStyle.text14RG(),
        ),
      ],
    );
  }

  Widget _navOrders(BottomNavigationController controller) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: () {
            if (HiveMethods.getToken() == null) {
              CommonMethods.showChooseDialog(
                context,
                onPressed: () {
                  Navigator.pop(context);
                  NamedNavigatorImpl.push(RegisterScreen.routeName);
                },
                message: 'youMustLoginFirst'.tr,
              );
            } else {
              controller.updateIndex(1);
            }
          },
          icon: SvgPicture.asset(
            controller.screenIndex == 1 ? AppImages.orderFillIcon : AppImages.ordersIcon,
          ),
        ),
        Text(
          'orders'.tr,
          style: controller.screenIndex == 1 ? AppTextStyle.text14RM() : AppTextStyle.text14RG(),
        ),
      ],
    );
  }

  Widget _navNotifications(BottomNavigationController controller) {
    final hasNewNotifications = HiveMethods.getNotificationsCount() != null &&
        HiveMethods.getNotificationsCount() != context.read<AuthController>().profile?.notificaionsCount;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: () {
            if (HiveMethods.getToken() == null) {
              CommonMethods.showChooseDialog(
                context,
                onPressed: () {
                  Navigator.pop(context);
                  NamedNavigatorImpl.push(RegisterScreen.routeName);
                },
                message: 'youMustLoginFirst'.tr,
              );
            } else {
              HiveMethods.updateNotificationCount(
                context.read<AuthController>().profile?.notificaionsCount,
              );
              controller.updateIndex(2);
            }
          },
          icon: Stack(
            children: [
              SvgPicture.asset(
                controller.screenIndex == 2 ? AppImages.billFillIcon : AppImages.notificationsIcon,
                colorFilter: ColorFilter.mode(
                  controller.screenIndex == 2 ? AppColors.mainAppColor : AppColors.greyColor,
                  BlendMode.srcIn,
                ),
              ),
              hasNewNotifications ? CircleAvatar(radius: 5, backgroundColor: AppColors.mainAppColor) : const SizedBox(),
            ],
          ),
        ),
        Text(
          'notifications'.tr,
          style: controller.screenIndex == 2 ? AppTextStyle.text14RM() : AppTextStyle.text14RG(),
        ),
      ],
    );
  }
}
