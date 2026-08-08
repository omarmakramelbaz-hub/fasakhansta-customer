import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../helpers/extensions/extensions.dart';
import '../../../../helpers/images/app_images.dart';
import '../../../../helpers/theme/app_colors.dart';
import '../../../../helpers/theme/app_text_style.dart';
import '../../../../helpers/translation/all_translation.dart';
import 'my_time_line_widget.dart';

class TrackingYourOrderWidget extends StatelessWidget {
  final String status;
  final String? orderDate;

  const TrackingYourOrderWidget({super.key, required this.status, this.orderDate});

  @override
  Widget build(BuildContext context) {
    if (orderDate == null || orderDate!.isEmpty) return const SizedBox.shrink();

    DateTime createdAtDateTime;
    try {
      createdAtDateTime = DateTime.parse(orderDate!).toLocal();
    } catch (_) {
      return const SizedBox.shrink();
    }

    final createdAtPlus6Hours = createdAtDateTime.add(const Duration(hours: 6));
    if (DateTime.now().isAfter(createdAtPlus6Hours) && status == 'completed') {
      return const SizedBox.shrink();
    }

    final isAccepted = status != 'pending' && status != 'declined' && status != 'cancelled';
    final isPreparing = isAccepted;
    final isShipped = status == 'shipped' || status == 'completed';
    final isDelivered = status == 'completed';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 10),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.greyColor.withValues(alpha: .12)),
        boxShadow: [
          BoxShadow(
            color: AppColors.greyColor.withValues(alpha: .10),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('orderStatus'.tr, style: AppTextStyle.text16BS()),
          14.sbH,
          SizedBox(
            height: 104,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _StatusStep(
                    icon: AppImages.checkIcon,
                    title: 'accepted'.tr,
                    active: isAccepted,
                    done: isAccepted,
                  ),
                ),
                _Connector(done: isPreparing),
                Expanded(
                  child: _StatusStep(
                    icon: AppImages.prepareIcon,
                    title: 'prepareTheOrder'.tr,
                    active: isPreparing,
                    done: isShipped,
                  ),
                ),
                _Connector(done: isShipped),
                Expanded(
                  child: _StatusStep(
                    icon: AppImages.inTheWayIconDone,
                    title: 'inTheWay'.tr,
                    active: isShipped,
                    done: isDelivered,
                  ),
                ),
                _Connector(done: isDelivered),
                Expanded(
                  child: _StatusStep(
                    icon: AppImages.deliveredIconDone,
                    title: 'delivered'.tr,
                    active: isDelivered,
                    done: isDelivered,
                  ),
                ),
              ],
            ),
          ),
          Divider(color: AppColors.greyColor.withValues(alpha: .10), height: 1),
          8.sbH,
          _statusMessage(context),
        ],
      ),
    );
  }

  Widget _statusMessage(BuildContext context) {
    final String message;
    if (status == 'shipped') {
      message = 'theRepresentativeHasReceivedTheOrderAndIsNowHeadingToYourDestination'.tr;
    } else if (status == 'declined') {
      message = 'orderDeclinedFromRestaurant'.tr;
    } else if (status == 'cancelled') {
      message = 'orderCanceled'.tr;
    } else if (status == 'completed') {
      message = 'yourOrderHasBeenDelivered'.tr;
    } else {
      message = 'yourOrderHasBeenReceivedAndIsBeingPreparedPleaseWaitALittle'.tr;
    }

    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: AppColors.mainAppColor, shape: BoxShape.circle),
        ),
        8.sbW,
        Expanded(child: Text(message, style: AppTextStyle.text13RG())),
      ],
    );
  }
}

class _StatusStep extends StatelessWidget {
  final String icon;
  final String title;
  final bool active;
  final bool done;

  const _StatusStep({required this.icon, required this.title, required this.active, required this.done});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active ? AppColors.mainAppColor.withValues(alpha: .10) : AppColors.greyColor.withValues(alpha: .07),
            border: Border.all(
              color: active ? AppColors.mainAppColor : AppColors.greyColor.withValues(alpha: .20),
              width: 1.5,
            ),
          ),
          padding: const EdgeInsets.all(10),
          child: SvgPicture.asset(
            icon,
            colorFilter: ColorFilter.mode(
              active ? AppColors.mainAppColor : AppColors.greyColor,
              BlendMode.srcIn,
            ),
          ),
        ),
        8.sbH,
        Text(
          title,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: active ? AppTextStyle.text12BS() : AppTextStyle.text11RG(),
        ),
      ],
    );
  }
}

class _Connector extends StatelessWidget {
  final bool done;
  const _Connector({required this.done});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 22),
      child: SizedBox(
        width: 12,
        child: Divider(
          thickness: 2,
          color: done ? AppColors.mainAppColor : AppColors.greyColor.withValues(alpha: .18),
        ),
      ),
    );
  }
}
