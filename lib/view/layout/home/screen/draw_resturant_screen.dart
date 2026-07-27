import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';

import '../../../../helpers/extensions/extensions.dart';
import '../../../../helpers/hive/hive_methods.dart';
import '../../../../helpers/pusher_service/pusher_controller.dart';
import '../../../../helpers/theme/app_text_style.dart';
import '../../../../helpers/translation/all_translation.dart';
import '../../my_account/account_app_bar/account_app_bar.dart';
import '../controller/home_controller.dart';
import '../widgets/draw_widget.dart';

class DrawRestaurantScreen extends StatefulWidget {
  static const String routeName = 'DrawRestaurantScreen';
  const DrawRestaurantScreen({super.key});

  @override
  State<DrawRestaurantScreen> createState() => _DrawRestaurantScreenState();
}

class _DrawRestaurantScreenState extends State<DrawRestaurantScreen> {
  late PusherController _pusherController;

  @override
  void initState() {
    _pusherController = context.read<PusherController>();
    _pusherController.addEventListener('coupon.wheel.updated', _couponWheelUpdated);
    Future.microtask(() {
      Provider.of<HomeController>(context, listen: false).initialCoupon();
      Provider.of<HomeController>(
        context,
        listen: false,
      ).getCoupon(lat: HiveMethods.getLat(), lng: HiveMethods.getLan());
    });
    super.initState();
  }

  void _couponWheelUpdated(PusherEvent event) {
    final homeProvider = Provider.of<HomeController>(context, listen: false);
    if (mounted) {
      homeProvider.getCoupon(lat: HiveMethods.getLat(), lng: HiveMethods.getLan()).then(
            (value) => setState(() {
              homeProvider.coupon == null ? Navigator.pop(context) : null;
            }),
          );
    }
  }

  @override
  void dispose() {
    _pusherController.removeEventListener('coupon.wheel.updated', _couponWheelUpdated);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeController>(
      builder: (context, homeController, _) {
        return Scaffold(
          body: Column(
            children: [
              35.sbH,
              CustomAccountAppBar(title: 'restaurantRaffle'.tr),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                      child: Text(homeController.coupon?.data?.name ?? '', style: AppTextStyle.text16BS()),
                    ),
                    // Padding(
                    //   padding:
                    //       const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                    //   child: CustomImage(
                    //     path: homeController.coupon?.data?.image ?? "",
                    //     type: ImageType.network,
                    //     height: 200,
                    //     width: double.infinity,
                    //     radius: 20,
                    //     fit: BoxFit.cover,
                    //   ),
                    // ),
                    10.sbH,
                    // Padding(
                    //   padding: const EdgeInsets.symmetric(
                    //     horizontal: 16,
                    //   ),
                    //   child: Text(
                    //     restaurantRaffle.tr,
                    //     style: AppTextStyle.text16BS(),
                    //   ),
                    // ),
                    RestaurantsDrawWidget(homeController: homeController),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'drawFee'.tr.replaceAll('{}', homeController.coupon?.data?.price.toString() ?? ''),
                  style: AppTextStyle.text16BS(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
