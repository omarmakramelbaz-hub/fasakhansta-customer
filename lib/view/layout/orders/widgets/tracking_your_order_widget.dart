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
    if (orderDate != null) {
      DateTime createdAtDateTime = DateTime.parse(orderDate!).toLocal();

      // Add 6 hours to the createdAtDateTime
      DateTime createdAtPlus6Hours = createdAtDateTime.add(const Duration(hours: 6));

      if (DateTime.now().isBefore(createdAtPlus6Hours) || (status != 'completed')) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              MyTimeLineWidget(
                isDone: true,
                isFirst: true,
                isLast: false,
                endChild: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      Text('prepareTheOrder'.tr, style: AppTextStyle.text18MS()),
                      const Spacer(),
                      SvgPicture.asset(AppImages.checkIcon),
                    ],
                  ),
                ),
                icon: SvgPicture.asset(AppImages.prepareIcon),
              ),
              MyTimeLineWidget(
                isDone: false,
                isFirst: false,
                isLast: false,
                endChild: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      Text(
                        'inTheWay'.tr,
                        style: status == 'shipped' || status == 'completed' || status == 'new_order'
                            ? AppTextStyle.text18MS()
                            : AppTextStyle.text16ML(),
                      ),
                      const Spacer(),
                      status == 'shipped' || status == 'completed' || status == 'new_order'
                          ? SvgPicture.asset(AppImages.checkIcon)
                          : const SizedBox(),
                    ],
                  ),
                ),
                icon: SvgPicture.asset(
                  status == 'shipped' || status == 'completed' || status == 'new_order'
                      ? AppImages.inTheWayIconDone
                      : AppImages.inTheWayIcon,
                ),
              ),
              MyTimeLineWidget(
                isDone: false,
                isFirst: false,
                isLast: true,
                endChild: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      Text(
                        'delivered'.tr,
                        style: status == 'completed' ? AppTextStyle.text18MS() : AppTextStyle.text16ML(),
                      ),
                      const Spacer(),
                      status == 'completed' ? SvgPicture.asset(AppImages.checkIcon) : const SizedBox(),
                    ],
                  ),
                ),
                icon: SvgPicture.asset(status == 'completed' ? AppImages.deliveredIconDone : AppImages.deliveredIcon),
              ),
              Divider(color: AppColors.greyColor.withValues(alpha: .1), thickness: 5),
              15.sbH,
            ],
          ),
        );
      } else {
        // If createdAt is still within 6 hours, hide the widget by returning SizedBox
        return const SizedBox.shrink(); // Or use Container()
      }
    } else {
      return const SizedBox.shrink();
    }
  }
}
