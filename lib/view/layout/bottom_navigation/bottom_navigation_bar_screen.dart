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
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 10),
        decoration: BoxDecoration(
          color: AppColors.whiteColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.borderColor.withValues(alpha: 0.45)),
          boxShadow: [
            BoxShadow(
              color: AppColors.blackColor.withValues(alpha: 0.10),
              blurRadius: 22,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: SizedBox(
          height: 74,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
            child: Row(
              children: [
                Expanded(
                  child: _navItem(
                    index: 0,
                    controller: controller,
                    iconSelected: AppImages.homeIcon,
                    iconUnselected: AppImages.homeUnselectedIcon,
                    title: 'home'.tr,
                    onTap: () => controller.updateIndex(0),
                  ),
                ),
                Expanded(child: _navOrders(controller)),
                Expanded(child: _navNotifications(controller)),
                Expanded(
                  child: _navItem(
                    index: 3,
                    controller: controller,
                    iconSelected: AppImages.accountFillIcon,
                    iconUnselected: AppImages.myAccountIcon,
                    title: 'account'.tr,
                    onTap: () => controller.updateIndex(3),
                  ),
                ),
              ],
            ),
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

    return _navButton(
      selected: selected,
      title: title,
      onTap: onTap,
      icon: selected ? iconSelected : iconUnselected,
    );
  }

  Widget _navOrders(BottomNavigationController controller) {
    final selected = controller.screenIndex == 1;

    return _navButton(
      selected: selected,
      title: 'orders'.tr,
      onTap: () {
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
      icon: selected ? AppImages.orderFillIcon : AppImages.ordersIcon,
    );
  }

  Widget _navNotifications(BottomNavigationController controller) {
    final selected = controller.screenIndex == 2;
    final hasNewNotifications = HiveMethods.getNotificationsCount() != null &&
        HiveMethods.getNotificationsCount() != context.read<AuthController>().profile?.notificaionsCount;

    return _navButton(
      selected: selected,
      title: 'notifications'.tr,
      onTap: () {
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
      icon: selected ? AppImages.billFillIcon : AppImages.notificationsIcon,
      showBadge: hasNewNotifications,
    );
  }

  Widget _navButton({
    required bool selected,
    required String title,
    required VoidCallback onTap,
    required String icon,
    bool showBadge = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        margin: const EdgeInsets.symmetric(horizontal: 3),
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.mainAppColor.withValues(alpha: 0.11)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                SizedBox(
                  width: 25,
                  height: 25,
                  child: SvgPicture.asset(
                    icon,
                    colorFilter: ColorFilter.mode(
                      selected ? AppColors.mainAppColor : AppColors.greyColor,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                if (showBadge)
                  Positioned(
                    right: -5,
                    top: -4,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppColors.mainAppColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.whiteColor, width: 1.5),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: selected ? AppTextStyle.text12RM() : AppTextStyle.text12RG(),
            ),
          ],
        ),
      ),
    );
  }
}
