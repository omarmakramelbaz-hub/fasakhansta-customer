import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../helpers/delivery_activity/delivery_provider.dart';
import '../../../../helpers/extensions/extensions.dart';
import '../../../../helpers/routes/app_routers_import.dart';
import '../../../../helpers/theme/app_colors.dart';
import '../../../../helpers/theme/app_text_style.dart';
import '../../../../helpers/translation/all_translation.dart';
import '../../../../helpers/utils/common_methods.dart';
import '../../../../helpers/utils/date_methods.dart';
import '../../../custom_widgets/custom_image/custom_network_image.dart';
import '../../../custom_widgets/state_conditional_builder.dart';
import '../controller/orders_controller.dart';
import '../model/orders_model.dart';
import '../screen/request_again_screen.dart';
import '../screen/tracking_your_order_screen.dart';

class InPreparationWidget extends StatelessWidget {
  final OrdersModel orders;

  const InPreparationWidget({super.key, required this.orders});

  @override
  Widget build(BuildContext context) {
    DateTime createdAtPlus6Hours = DateTime.now();
    if (orders.updatedAt != null) {
      DateTime createdAtDateTime = DateTime.parse(orders.updatedAt.toString()).toLocal();
      createdAtPlus6Hours = createdAtDateTime.add(const Duration(hours: 6));
    }
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 25),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      width: context.width * 0.9,
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: AppColors.greyColor.withValues(alpha: .4), blurRadius: 9, offset: const Offset(0, 1)),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              if (orders.scheduleDate != null)
                Text(DateMethods.formatToDate(orders.scheduleDate ?? ''))
              else
                Text(DateMethods.formatToDate(orders.createdAt ?? ''), style: AppTextStyle.text14RG()),
              const Spacer(),
              Column(
                children: [
                  Container(
                    height: 30,
                    padding: const EdgeInsets.symmetric(horizontal: 13),
                    decoration: BoxDecoration(
                      color: AppColors.greyColor.withValues(alpha: .12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(
                      child: Text(
                        getStatusTitle(orders.status, orders.scheduleDate, orders.delegateFromOut),
                        style: AppTextStyle.text14RG(),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    if (orders.status != 'completed' && orders.status != 'cancelled' && orders.status != 'declined') {
                      final liveActivitiesController = Provider.of<DeliveryProvider>(context, listen: false);
                      liveActivitiesController.init(orders.id ?? 0).whenComplete(() {
                        liveActivitiesController.startDelivery(orders.status);
                      });
                    }

                    NamedNavigatorImpl.push(
                      TrackingYourOrderScreen.routeName,
                      arguments: TrackingYourOrderArgs(id: orders.id ?? 0),
                    );
                  },
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.all(Radius.circular(12)),
                          border: Border.all(color: AppColors.lightDarkColor.withValues(alpha: 0.5)),
                        ),
                        child: CustomNetworkImage(
                          radius: 12,
                          imageUrl: orders.resturantLogo ?? '',
                          width: 60,
                          height: 60,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(orders.resturantName ?? '', style: AppTextStyle.text14RS()),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Text('requestCode'.tr, style: AppTextStyle.text14RL()),
                                const SizedBox(width: 10),
                                Text(orders.orderNo ?? '', style: AppTextStyle.text14RL()),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // orders.status == 'shipped'
              //     ? InkWell(
              //         onTap: () {
              //           NamedNavigatorImpl.pushNamed(
              //             context,
              //             TrackingYourOrderScreen.routeName,
              //             arguments: TrackingYourOrderArgs(id: orders.id ?? 0, onSuccess: onSuccess),
              //           );
              //         },
              //         child: Text(
              //           tr( 'trackingYourOrder'),
              //           style: TextStyle(
              //             color: AppColor.mainAppColor,
              //             fontSize: 14,
              //             fontWeight: FontWeight.w400,
              //             decoration: TextDecoration.underline,
              //           ),
              //         ),
              //       )
              //     : orders.status == 'completed'
              //         ? InkWell(
              //             onTap: () => NamedNavigatorImpl.pushNamed(
              //               context,
              //               RequestAgainScreen.routeName,
              //               arguments: RequestAgainArgs(id: orders.id ?? 0),
              //             ),
              //             child: Column(
              //               children: [
              //                 Text(
              //                   tr( 'requestAgain'),
              //                   style: TextStyle(
              //                     color: AppColor.mainAppColor,
              //                     fontSize: 14,
              //                     fontWeight: FontWeight.w400,
              //                     decoration: TextDecoration.underline,
              //                   ),
              //                 ),
              //                 const SizedBox(height: 12),
              //                 orders.hasRatedBefore == 0
              //                     ? DateTime.now().isBefore(createdAtPlus6Hours)
              //                         ? InkWell(
              //                             onTap: () {
              //                               NamedNavigatorImpl.pushNamed(
              //                                 context,
              //                                 TrackingYourOrderScreen.routeName,
              //                                 arguments: TrackingYourOrderArgs(id: orders.id ?? 0),
              //                               );
              //                             },
              //                             child: Text(
              //                                'serviceEvaluation'.tr,
              //                               style: TextStyle(
              //                                 color: AppColor.mainAppColor,
              //                                 fontSize: 14,
              //                                 fontWeight: FontWeight.w400,
              //                                 decoration: TextDecoration.underline,
              //                               ),
              //                             ),
              //                           )
              //                         : const SizedBox()
              //                     : const SizedBox(),
              //               ],
              //             ),
              //           )
              //         : orders.status == 'pending' ||
              //                 orders.status == 'another_delegate' && orders.paymentType == 'cash'
              //             ? Builder(
              //                 builder: (context) {
              //                   return TextButton(
              //                     onPressed: () {
              //                       CommonMethods.showChooseDialog(
              //                         context,
              //                         message:  'didYouWantToCancelThisOrder'.tr,
              //                         onPressed: () {
              //                           context.read<OrdersController>().cancelOrder(
              //                                 orderId: orders.id!,
              //                                 onSuccess: () {
              //                                   onSuccess?.call();
              //                                   Navigator.pop(context);
              //                                 },
              //                               );
              //                         },
              //                       );
              //                     },
              //                     child: Text(
              //                        'cancelOrder'.tr,
              //                       style: TextStyle(
              //                         color: AppColor.mainAppColor,
              //                         fontSize: 14,
              //                         fontWeight: FontWeight.w400,
              //                         decoration: TextDecoration.underline,
              //                       ),
              //                     ),
              //                   );
              //                 },
              //               )
              //             : const SizedBox(),
              MultiStateConditionalBuilder(
                conditions: [
                  ConditionBuilder(
                    when: orders.status == 'shipped',
                    builder: (context) => InkWell(
                      onTap: () {
                        NamedNavigatorImpl.push(
                          TrackingYourOrderScreen.routeName,
                          arguments: TrackingYourOrderArgs(id: orders.id ?? 0),
                        );
                      },
                      child: Text(
                        'trackingYourOrder'.tr,
                        style: TextStyle(
                          color: AppColors.mainAppColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                  ConditionBuilder(
                    when: orders.status == 'completed',
                    builder: (context) => InkWell(
                      onTap: () => NamedNavigatorImpl.push(
                        RequestAgainScreen.routeName,
                        arguments: RequestAgainArgs(id: orders.id ?? 0),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'requestAgain'.tr,
                            style: TextStyle(
                              color: AppColors.mainAppColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          const SizedBox(height: 12),
                          orders.hasRatedBefore == 0
                              ? DateTime.now().isBefore(createdAtPlus6Hours)
                                  ? InkWell(
                                      onTap: () {
                                        NamedNavigatorImpl.push(
                                          TrackingYourOrderScreen.routeName,
                                          arguments: TrackingYourOrderArgs(id: orders.id ?? 0),
                                        );
                                      },
                                      child: Text(
                                        'serviceEvaluation'.tr,
                                        style: TextStyle(
                                          color: AppColors.mainAppColor,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    )
                                  : const SizedBox()
                              : const SizedBox(),
                        ],
                      ),
                    ),
                  ),
                  ConditionBuilder(
                    when: orders.status == 'pending' ||
                        orders.status == 'another_delegate' && orders.paymentType == 'cash',
                    builder: (context) => Builder(
                      builder: (context) {
                        return TextButton(
                          onPressed: () {
                            CommonMethods.showChooseDialog(
                              context,
                              message: 'didYouWantToCancelThisOrder'.tr,
                              onPressed: () {
                                context.read<OrdersController>().cancelOrder(
                                      orderId: orders.id!,
                                      onSuccess: () => NamedNavigatorImpl.pop(),
                                    );
                              },
                            );
                          },
                          child: Text(
                            'cancelOrder'.tr,
                            style: TextStyle(
                              color: AppColors.mainAppColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
                fallback: (_) => const SizedBox(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String getStatusTitle(String? status, String? scheduleDate, String? delegateFromOut) {
    switch (status) {
      case 'completed':
        return 'delivered'.tr;
      case 'cancelled':
        return 'canceled'.tr;
      case 'declined':
        return 'rejectOrder'.tr;
      case 'pending':
      case 'another_delegate':
        return 'pending'.tr;
      case 'accepted':
        return 'inPreparation'.tr;
      case 'shipped':
      case 'new_order':
        return 'delegateInRoute'.tr;
      default:
        if (scheduleDate != null && status != 'completed') {
          return 'scheduledOrder'.tr;
        }
        if (delegateFromOut == 'in_resturant') {
          return 'delivered'.tr;
        }
        return ''; // Default case
    }
  }
}
