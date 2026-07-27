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

class _NotificationsScreenState extends State<NotificationsScreen> {
  late PusherController _pusherController;
  @override
  void initState() {
    super.initState();
    _pusherController = context.read<PusherController>();

    _pusherController.addEventListener('notification.updated', _handleVendorNotificationUpdated);
  }

  void _handleVendorNotificationUpdated(PusherEvent event) {
    try {
      var jsonData = jsonDecode(event.data) as Map<String, dynamic>;
      log('Notification updated: $jsonData');
      if (mounted) {
        var notification = NotificationsModel.fromJson(jsonData);
        context.read<NotificationsController>().addNotificationToTop(notification);
      }
    } catch (e, stackTrace) {
      log('Error handling Pusher event: $e');
      log('Stack trace: $stackTrace');
    }
  }

  @override
  dispose() {
    _pusherController.removeEventListener('notification.updated', _handleVendorNotificationUpdated);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationsController>(
      builder: (context, notificationsController, _) {
        return Scaffold(
          extendBody: true,
          body: PageContainer(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 25),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                  child: Row(
                    children: [
                      Text('notifications'.tr, style: AppTextStyle.text18BS()),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: AppColors.mainAppColor, shape: BoxShape.circle),
                        child: Center(
                          child: Text(
                            notificationsController.notifications.length.toString(),
                            style: AppTextStyle.text20MW().copyWith(fontSize: 17),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                30.sbH,
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.whiteColor,
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(36),
                        topLeft: Radius.circular(36),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.greyColor.withValues(alpha: .2),
                          blurRadius: 10,
                          offset: const Offset(0, -3),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: ApiResponseWidget(
                        apiResponse: notificationsController.notificationsResponse,
                        onReload: () => notificationsController.getNotifications(),
                        isEmpty: notificationsController.notifications.isEmpty,
                        emptyWidget: Center(
                          child: ListView(
                            children: [
                              SizedBox(height: context.height * 0.15),
                              Padding(
                                padding: EdgeInsets.only(right: context.width * 0.19),
                                child: SvgPicture.asset(AppImages.noNotificationIcon),
                              ),
                              SizedBox(height: context.height * 0.1),
                              Center(child: Text('noNotifications'.tr, style: AppTextStyle.text16BM())),
                              SizedBox(height: context.height * 0.15),
                            ],
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 25),
                            Expanded(
                              child: RefreshIndicator(
                                onRefresh: () async {
                                  await notificationsController.getNotifications();
                                },
                                child: ListView.separated(
                                  itemCount: notificationsController.notifications.length,
                                  itemBuilder: (context, index) {
                                    return NotificationWidget(
                                      orderId: notificationsController.notifications[index].data?.data?.id ?? 0,
                                      notification: notificationsController.notifications[index],
                                    );
                                  },
                                  separatorBuilder: (BuildContext context, int index) =>
                                      const Padding(padding: EdgeInsets.only(bottom: 25), child: Divider()),
                                ),
                              ),
                            ),
                          ],
                        ),
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
}
