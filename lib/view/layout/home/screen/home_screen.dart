import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';

import '../../../../helpers/extensions/extensions.dart';
import '../../../../helpers/hive/hive_methods.dart';
import '../../../../helpers/images/app_images.dart';
import '../../../../helpers/pusher_service/pusher_controller.dart';
import '../../../../helpers/routes/app_routers_import.dart';
import '../../../../helpers/theme/app_colors.dart';
import '../../../../helpers/theme/app_text_style.dart';
import '../../../../helpers/translation/all_translation.dart';
import '../../../custom_widgets/api_response_widget/api_response_widget.dart';
import '../../../custom_widgets/bottom_sheet/bottom_sheet_helper.dart';
import '../../../custom_widgets/custom_image/custom_image.dart';
import '../../address/screen/add_address_screen.dart';
import '../../auth/controller/auth_controller.dart';
import '../../auth/model/profile_model.dart';
import '../controller/home_controller.dart';
import '../model/previous_order_home_model.dart';
import '../model/restaurants_near_you_home_model.dart';
import '../widgets/home_feature_cards.dart';
import '../widgets/home_header.dart';
import '../widgets/home_wallet_card.dart';
import '../widgets/restaurants_and_delegate_request_widget.dart';
import 'home_screen_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final PusherController _pusherController;

  @override
  void initState() {
    super.initState();
    _pusherController = context.read<PusherController>();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _ensureProfileLoaded();
      await _checkSelectedCity();
    });

    _registerPusherListeners();
  }

  void _registerPusherListeners() {
    _pusherController.addEventListener('coupon.wheel.updated', _onCouponWheelUpdated);
    _pusherController.addEventListener('resturant.updated', _onResturantUpdated);
  }

  void _unregisterPusherListeners() {
    _pusherController.removeEventListener('resturant.updated', _onResturantUpdated);
    _pusherController.removeEventListener('coupon.wheel.updated', _onCouponWheelUpdated);
  }

  Future<void> _ensureProfileLoaded() async {
    final auth = context.read<AuthController>();
    if (auth.profile == null) {
      await auth.getProfile();
    }
  }

  void _onCouponWheelUpdated(PusherEvent event) {
    log('Coupon Wheel Updated: ${event.data}');
    if (!mounted) return;
    final homeProvider = context.read<HomeController>();
    homeProvider.getCoupon(lat: HiveMethods.getLat(), lng: HiveMethods.getLan());
  }

  void _onResturantUpdated(PusherEvent event) {
    try {
      final decoded = json.decode(event.data) as Map<String, dynamic>;
      final resturantData = decoded['resturant'] as Map<String, dynamic>;
      if (!mounted) return;

      final resturantModel = RestaurantsNearYouHomeModel.fromJson(resturantData);
      final previousModel = PreviousOrderHomeModel.fromJson(resturantData);

      final homeController = context.read<HomeController>();
      homeController.updateResturantNearestYou(resturantModel);
      homeController.updateSpacialResturant(resturantModel);
      homeController.updatePreviousResturant(previousModel);
    } catch (e, st) {
      log('Error handling Pusher event: $e');
      log('Stack trace: $st');
    }
  }

  @override
  void dispose() {
    _unregisterPusherListeners();
    super.dispose();
  }

  Future<void> _checkSelectedCity() async {
    final selectedCity = HiveMethods.getSelectedCity();
    if (selectedCity == null && mounted) {
      await context.read<AuthController>().getProfile();
      _showCitySelectionSheet();
    }
  }

  void _showCitySelectionSheet() {
    final authProvider = context.read<AuthController>();
    final userAddresses = authProvider.profile?.userAddresses ?? [];

    if (userAddresses.isEmpty) return;

    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      BottomSheetHelper.gShowModalBottomSheet(
        context: context,
        maxHeight: context.height * 0.8,
        barrierDismissible: false,
        content: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('deliveryAddresses'.tr, style: AppTextStyle.text16MS().copyWith(color: AppColors.blackColor)),
              SizedBox(
                height: context.height * 0.65,
                child: ListView.builder(
                  itemCount: userAddresses.length,
                  itemBuilder: (context, index) {
                    final address = userAddresses[index];
                    return ListTile(
                      leading: CustomImage(path: AppImages.addressIcon, type: ImageType.svg, color: AppColors.blackColor),
                      title: Text(
                        "${address.countryName ?? ""} - ${address.cityName ?? ""} - ${address.streetName ?? ""}",
                        style: AppTextStyle.text16BS(),
                      ),
                      onTap: () => _onAddressSelected(address),
                    );
                  },
                ),
              ),
              ListTile(
                title: Text('deliveryToAnotherAddress'.tr, style: AppTextStyle.text16BS()),
                trailing: Icon(Icons.arrow_forward_ios, color: AppColors.blackColor),
                onTap: () {
                  NamedNavigatorImpl.push(
                    AddAddressScreen.routeName,
                    arguments: AddAddressArgs(onSuccess: () {}),
                  );
                },
              ),
            ],
          ),
        ),
      );
    });
  }

  void _onAddressSelected(UserAddresses address) {
    Navigator.pop(context);

    final homeController = context.read<HomeController>();

    homeController.initialCountCart();
    homeController.initialSlider();
    homeController.initialDefaultSlider();
    homeController.initialPreviousOrder();
    homeController.initialRestaurantsNearYou();
    homeController.initialCoupon();
    homeController.initialSpacialRestaurants();

    HiveMethods.updateSelectedCity(address.id!);
    HiveMethods.updateLat(double.tryParse(address.lat.toString()) ?? 0);
    HiveMethods.updateLan(double.tryParse(address.lng.toString()) ?? 0);
    HiveMethods.updateCity(address.streetName ?? '');
    HiveMethods.updateSelectedCityAreaId(address.cityId ?? 0);

    Future.wait([
      homeController.getRestaurantsNearYou(
        lat: double.tryParse(address.lat ?? '') ?? HiveMethods.getLat(),
        lng: double.tryParse(address.lng ?? '') ?? HiveMethods.getLan(),
      ),
      homeController.getCoupon(lat: HiveMethods.getLat(), lng: HiveMethods.getLan()),
      homeController.getPreviousOrder(),
      homeController.getSpacialRestaurants(lat: HiveMethods.getLat(), lng: HiveMethods.getLan()),
      homeController.getSlider(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeController>(
      builder: (context, controller, _) {
        return Scaffold(
          appBar: HomeHeader(controller: controller),
          body: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Transform.translate(
                  offset: const Offset(0, -56),
                  child: const HomeWalletCard(),
                ),
                Transform.translate(
                  offset: const Offset(0, -46),
                  child: SliderWidget(controller: controller),
                ),
                HomeFeatureCards(controller: controller),
                RestaurantsNearYouWidget(controller: controller),
                10.sbH,
                Row(
                  children: [
                    RestaurantsAndDelegateRequestWidget(controller: controller),
                  ],
                ),
                20.sbH,
              ],
            ),
          ),
        );
      },
    );
  }
}
