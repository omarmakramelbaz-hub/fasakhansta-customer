import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';

import '../../../../helpers/extensions/extensions.dart';
import '../../../../helpers/images/app_images.dart';
import '../../../../helpers/pusher_service/pusher_controller.dart';
import '../../../../helpers/theme/app_colors.dart';
import '../../../../helpers/theme/app_text_style.dart';
import '../../../../helpers/translation/all_translation.dart';
import '../../../custom_widgets/api_response_widget/api_response_widget.dart';
import '../../../custom_widgets/page_container/page_container.dart';
import '../controller/notifications_controller.dart';
import '../model/notifications_model.dart';
import '../widget/notification_widget.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> with SingleTickerProviderStateMixin {
  late PusherController _pusherController;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _pusherController = context.read<PusherController>();
    _pusherController.addEventListener('notification.updated', _handleVendorNotificationUpdated);
  }

  void _handleVendorNotificationUpdated(PusherEvent event) {
    try {
      final jsonData = jsonDecode(event.data) as Map<String, dynamic>;
      log('Notification updated: $jsonData');
      if (mounted) {
        final notification = NotificationsModel.fromJson(jsonData);
        context.read<NotificationsController>().addNotificationToTop(notification);
      }
    } catch (e, stackTrace) {
      log('Error handling Pusher event: $e');
      log('Stack trace: $stackTrace');
    }
  }

  @override
  void dispose() {
    _pusherController.removeEventListener('notification.updated', _handleVendorNotificationUpdated);
    _tabController.dispose();
    super.dispose();
  }

  List<NotificationsModel> _filter(List<NotificationsModel> list, int tab) {
    if (tab == 0) return list;
    if (tab == 1) {
      return list.where((item) => item.data?.data?.notificationType == 1).toList();
    }
    return list.where((item) => item.data?.data?.notificationType != 1).toList();
  }

  Widget _tab({required String title, required IconData icon, required bool selected}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: selected ? AppColors.whiteColor : Colors.transparent,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: selected ? AppColors.mainAppColor.withValues(alpha: .22) : Colors.transparent,
        ),
        boxShadow: selected
            ? [BoxShadow(color: AppColors.mainAppColor.withValues(alpha: .08), blurRadius: 10, offset: const Offset(0, 3))]
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 19, color: selected ? AppColors.mainAppColor : AppColors.greyColor),
          const SizedBox(width: 7),
          Text(
            title,
            style: AppTextStyle.text14MS().copyWith(
              color: selected ? AppColors.mainAppColor : AppColors.greyColor,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _notificationsList(List<NotificationsModel> notifications, NotificationsController controller) {
    if (notifications.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: context.height * .16),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: context.width * .28),
            child: SvgPicture.asset(AppImages.noNotificationIcon),
          ),
          const SizedBox(height: 25),
          Center(child: Text('noNotifications'.tr, style: AppTextStyle.text16BM())),
        ],
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(0, 12, 0, 30),
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final item = notifications[index];
        return NotificationWidget(
          orderId: item.data?.data?.id ?? 0,
          notification: item,
        );
      },
      separatorBuilder: (_, __) => const SizedBox(height: 12),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationsController>(
      builder: (context, notificationsController, _) {
        final all = notificationsController.notifications;
        return Scaffold(
          backgroundColor: const Color(0xffF8F8F8),
          body: PageContainer(
            bottom: false,
            child: Column(
              children: [
                const SizedBox(height: 18),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      _circleButton(Icons.arrow_back_ios_new_rounded, () => Navigator.of(context).maybePop()),
                      const Spacer(),
                      Text('notifications'.tr, style: AppTextStyle.text22BS()),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          // Read state is not exposed by the current notifications API/model.
                        },
                        child: Text(
                          'تحديد الكل كمقروء',
                          style: AppTextStyle.text13MS().copyWith(color: AppColors.mainAppColor),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: const Color(0xffEFEFF1),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: AnimatedBuilder(
                      animation: _tabController,
                      builder: (_, __) => TabBar(
                        controller: _tabController,
                        indicatorColor: Colors.transparent,
                        dividerColor: Colors.transparent,
                        labelPadding: EdgeInsets.zero,
                        tabs: [
                          _tab(title: 'كل الإشعارات', icon: Icons.notifications_none_rounded, selected: _tabController.index == 0),
                          _tab(title: 'الطلبات', icon: Icons.shopping_bag_outlined, selected: _tabController.index == 1),
                          _tab(title: 'العروض والتنبيهات', icon: Icons.card_giftcard_outlined, selected: _tabController.index == 2),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    decoration: const BoxDecoration(
                      color: Color(0xffF8F8F8),
                    ),
                    child: ApiResponseWidget(
                      apiResponse: notificationsController.notificationsResponse,
                      onReload: () => notificationsController.getNotifications(),
                      isEmpty: all.isEmpty,
                      emptyWidget: _notificationsList(const [], notificationsController),
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _notificationsList(_filter(all, 0), notificationsController),
                          _notificationsList(_filter(all, 1), notificationsController),
                          _notificationsList(_filter(all, 2), notificationsController),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _circleButton(IconData icon, VoidCallback onTap) {
    return Material(
      color: AppColors.whiteColor,
      shape: const CircleBorder(),
      elevation: 2,
      shadowColor: Colors.black12,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(width: 48, height: 48, child: Icon(icon, size: 20, color: AppColors.mainAppColor)),
      ),
    );
  }
}
