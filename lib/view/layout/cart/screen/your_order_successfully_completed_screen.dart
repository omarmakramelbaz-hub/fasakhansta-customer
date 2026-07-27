import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';

import '../../../../helpers/delivery_activity/delivery_provider.dart';
import '../../../../helpers/extensions/extensions.dart';
import '../../../../helpers/images/app_images.dart';
import '../../../../helpers/pusher_service/pusher_controller.dart';
import '../../../../helpers/routes/app_routers_import.dart';
import '../../../../helpers/theme/app_text_style.dart';
import '../../../../helpers/translation/all_translation.dart';
import '../../../../helpers/utils/common_methods.dart';
import '../../../custom_widgets/buttons/custom_button.dart';
import '../../../custom_widgets/custom_app_bar/custom_app_bar.dart';
import '../../bottom_navigation/bottom_navigation_bar_screen.dart';
import '../../orders/controller/orders_controller.dart';
import '../../orders/screen/tracking_your_order_screen.dart';

class YourOrderSuccessfullyCompletedArgs {
  final int id;
  const YourOrderSuccessfullyCompletedArgs({required this.id});
}

class YourOrderSuccessfullyCompletedScreen extends StatefulWidget {
  final YourOrderSuccessfullyCompletedArgs args;
  static const routeName = 'YourOrderSuccessfullyCompletedScreen';
  const YourOrderSuccessfullyCompletedScreen({super.key, required this.args});

  @override
  State<YourOrderSuccessfullyCompletedScreen> createState() => _YourOrderSuccessfullyCompletedScreenState();
}

class _YourOrderSuccessfullyCompletedScreenState extends State<YourOrderSuccessfullyCompletedScreen> {
  late PusherController _pusherController;
  bool isAcceptedFromDelegate = false;
  @override
  void initState() {
    super.initState();
    _pusherController = context.read<PusherController>();
    _pusherController.addEventListener('finished.updated', _handleFinishedUpdate);

    final liveActivitiesController = Provider.of<DeliveryProvider>(context, listen: false);
    final ordersController = Provider.of<OrdersController>(context, listen: false);

    Future.delayed(
      Duration.zero,
      () async {
        await ordersController.getDetailsOrders(id: widget.args.id).whenComplete(() {
          liveActivitiesController.init(widget.args.id).whenComplete(() {
            liveActivitiesController.startDelivery(ordersController.detailsOrders?.status);
          });
        });
      },
    );
  }

  void _handleFinishedUpdate(PusherEvent event) {
    try {
      var jsonData = jsonDecode(event.data) as Map<String, dynamic>;

      var orderNo = jsonData['order_no']?.toString();
      if (orderNo != null) {
        CommonMethods.showToast(message: '${'thereIsANewOrderWithStatus'.tr} $orderNo');
      }

      log('is Finished $jsonData');

      if (mounted) setState(() => isAcceptedFromDelegate = true);
    } catch (e, stackTrace) {
      log('Error handling Pusher event: $e');
      log('Stack trace: $stackTrace');
    }
  }

  @override
  dispose() {
    _pusherController.removeEventListener('finished.updated', _handleFinishedUpdate);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(actions: const [], height: 90, radius: 60, title: Text('executeTheOrder'.tr)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
        child: Column(
          children: [
            30.sbH,
            Text(
              'yourOrderHasBeenSuccessfullyCompletedItWillBePreparedNow'.tr,
              style: AppTextStyle.text20MS(),
            ),
            50.sbH,
            Image.asset(AppImages.orderSuccessfullyImage),
            70.sbH,
            CustomButton(
              onPressed: () => NamedNavigatorImpl.push(clean: true, BottomNavigationBarScreen.routeName),
              text: 'backToHome'.tr,
            ),
            26.sbH,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (!isAcceptedFromDelegate) ...[
                  Builder(
                    builder: (context) {
                      return TextButton(
                        onPressed: () {
                          context.read<OrdersController>().cancelOrder(
                                orderId: widget.args.id,
                                onSuccess: () {
                                  NamedNavigatorImpl.push(clean: true, BottomNavigationBarScreen.routeName);
                                },
                              );
                        },
                        child: Text('cancelOrder'.tr, style: AppTextStyle.text16MS()),
                      );
                    },
                  ),
                ],
                TextButton(
                  onPressed: () {
                    NamedNavigatorImpl.push(
                      TrackingYourOrderScreen.routeName,
                      arguments: TrackingYourOrderArgs(id: widget.args.id),
                      clean: true,
                    );
                  },
                  child: Text('trackingYourOrder'.tr, style: AppTextStyle.text16MS()),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
