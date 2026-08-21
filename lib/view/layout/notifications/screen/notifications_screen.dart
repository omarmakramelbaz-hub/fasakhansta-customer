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
  int _selectedCategory = 0;

  static const List<_NotificationCategory> _categories = [
    _NotificationCategory('الكل', Icons.grid_view_rounded),
    _NotificationCategory('الطلبات', Icons.shopping_bag_outlined),
    _NotificationCategory('العروض', Icons.local_offer_outlined),
    _NotificationCategory('المعاملات', Icons.account_balance_wallet_outlined),
    _NotificationCategory('النظام', Icons.settings_outlined),
  ];

  @override
  void initState() {
    super.initState();
    _pusherController = context.read<PusherController>();
    _pusherController.addEventListener('notification.updated', _handleVendorNotificationUpdated);
  }

  void _handleVendorNotificationUpdated(PusherEvent event) {
    try {
      final jsonData = jsonDecode(event.data) as Map<String, dynamic>;
      log('Notification updated: $jsonData');
      if (!mounted) return;
      final notification = NotificationsModel.fromJson(jsonData);
      context.read<NotificationsController>().addNotificationToTop(notification);
    } catch (e, stackTrace) {
      log('Error handling Pusher event: $e');
      log('Stack trace: $stackTrace');
    }
  }

  @override
  void dispose() {
    _pusherController.removeEventListener('notification.updated', _handleVendorNotificationUpdated);
    super.dispose();
  }

  List<NotificationsModel> _filter(List<NotificationsModel> list) {
    if (_selectedCategory == 0) return list;

    return list.where((item) {
      final type = item.data?.data?.notificationType;
      switch (_selectedCategory) {
        case 1:
          return type == 1;
        case 2:
          return type == 2;
        case 3:
          return type == 3;
        case 4:
          return type == null || (type != 1 && type != 2 && type != 3);
        default:
          return true;
      }
    }).toList();
  }

  Widget _notificationsList(
    List<NotificationsModel> notifications,
    NotificationsController controller,
  ) {
    if (notifications.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: context.height * .14),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: context.width * .28),
            child: SvgPicture.asset(AppImages.noNotificationIcon),
          ),
          const SizedBox(height: 22),
          Center(child: Text('noNotifications'.tr, style: AppTextStyle.text16BM())),
          const SizedBox(height: 7),
          Center(
            child: Text(
              'لا توجد إشعارات في هذا القسم حالياً',
              style: AppTextStyle.text13RM().copyWith(color: const Color(0xFF929292)),
            ),
          ),
        ],
      );
    }

    return RefreshIndicator(
      color: AppColors.mainAppColor,
      onRefresh: controller.getNotifications,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 34),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final item = notifications[index];
          return NotificationWidget(
            orderId: item.data?.data?.id ?? 0,
            notification: item,
          );
        },
        separatorBuilder: (_, __) => const SizedBox(height: 12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationsController>(
      builder: (context, notificationsController, _) {
        final all = notificationsController.notifications;
        final visible = _filter(all);

        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FB),
          body: PageContainer(
            bottom: false,
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  _TopBar(
                    onBack: () => Navigator.of(context).maybePop(),
                    onMarkAllRead: () {
                      // The current API/model does not expose persisted read state yet.
                    },
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 58,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                      itemCount: _categories.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 9),
                      itemBuilder: (context, index) {
                        final category = _categories[index];
                        return _CategoryChip(
                          title: category.title,
                          icon: category.icon,
                          selected: index == _selectedCategory,
                          onTap: () => setState(() => _selectedCategory = index),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 4),
                  Expanded(
                    child: ApiResponseWidget(
                      apiResponse: notificationsController.notificationsResponse,
                      onReload: notificationsController.getNotifications,
                      isEmpty: all.isEmpty,
                      emptyWidget: _notificationsList(const [], notificationsController),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        child: KeyedSubtree(
                          key: ValueKey(_selectedCategory),
                          child: _notificationsList(visible, notificationsController),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onBack, required this.onMarkAllRead});

  final VoidCallback onBack;
  final VoidCallback onMarkAllRead;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text('notifications'.tr, style: AppTextStyle.text22BS()),
          Positioned(
            left: 14,
            child: Material(
              color: Colors.white,
              shape: const CircleBorder(),
              elevation: 1.5,
              shadowColor: Colors.black12,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onBack,
                child: const SizedBox(
                  width: 44,
                  height: 44,
                  child: Icon(Icons.arrow_back_ios_new_rounded, size: 19, color: Color(0xFF111111)),
                ),
              ),
            ),
          ),
          Positioned(
            right: 12,
            child: TextButton(
              onPressed: onMarkAllRead,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                foregroundColor: AppColors.mainAppColor,
              ),
              child: Text(
                'تحديد الكل كمقروء',
                style: AppTextStyle.text13MS().copyWith(
                  color: AppColors.mainAppColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.title,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? const Color(0xFFFFF3E9) : Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected ? AppColors.mainAppColor : const Color(0xFFE7E7E7),
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: AppColors.mainAppColor.withValues(alpha: .08),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: selected ? AppColors.mainAppColor : const Color(0xFF777777),
              ),
              const SizedBox(width: 7),
              Text(
                title,
                style: AppTextStyle.text13MS().copyWith(
                  color: selected ? AppColors.mainAppColor : const Color(0xFF696969),
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationCategory {
  const _NotificationCategory(this.title, this.icon);

  final String title;
  final IconData icon;
}
