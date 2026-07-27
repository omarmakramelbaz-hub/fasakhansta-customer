import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';

import '../../../../helpers/extensions/extensions.dart';
import '../../../../helpers/hive/hive_methods.dart';
import '../../../../helpers/images/app_images.dart';
import '../../../../helpers/pusher_service/pusher_controller.dart';
import '../../../../helpers/theme/app_colors.dart';
import '../../../../helpers/theme/app_text_style.dart';
import '../../../../helpers/translation/all_translation.dart';
import '../../../custom_widgets/custom_app_bar/custom_app_bar.dart';
import '../../../custom_widgets/custom_form_field/custom_form_field.dart';
import '../../home/model/previous_order_home_model.dart';
import '../controller/restaurants_controller.dart';
import '../model/restaurants_model.dart';
import '../widgets/all_restaurants_widget.dart';
import '../widgets/filtration_list_view_widget.dart';
import '../widgets/previous_orders_restaurant_widget.dart';

class RestaurantsScreen extends StatefulWidget {
  static const routeName = 'RestaurantsScreen';
  const RestaurantsScreen({super.key});

  @override
  State<RestaurantsScreen> createState() => _RestaurantsScreenState();
}

class _RestaurantsScreenState extends State<RestaurantsScreen> {
  late PusherController _pusherController; // Saved reference
  @override
  void initState() {
    _pusherController = context.read<PusherController>();
    _pusherController.addEventListener('resturant.updated', _handleResturantUpdated);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      context.read<RestaurantsController>().initialRestPreviousOrder();
      context.read<RestaurantsController>().getPreviousRestOrder();
      context.read<RestaurantsController>().initialRestaurants();
      context.read<RestaurantsController>().getRestaurants(lat: HiveMethods.getLat(), lng: HiveMethods.getLan());
    });
    super.initState();
  }

  void _handleResturantUpdated(PusherEvent event) {
    try {
      final decodedData = json.decode(event.data) as Map<String, dynamic>;
      final resturantData = decodedData['resturant'];

      if (mounted) {
        final resturantModel = RestaurantsModel.fromJson(resturantData as Map<String, dynamic>);
        final previousModel = PreviousOrderHomeModel.fromJson(resturantData);
        context.read<RestaurantsController>().updateResturant(resturantModel);
        context.read<RestaurantsController>().updatePreviousResturant(previousModel);
      }
    } catch (e, stackTrace) {
      log('Error handling Pusher event: $e');
      log('Stack trace: $stackTrace');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: CustomAppBar(
        actions: const [],
        height: 50,
        appBarColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.blackColor),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('restaurants'.tr, style: AppTextStyle.text16BS()),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (HiveMethods.getToken() != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text('askAgain'.tr, style: AppTextStyle.text14BS()),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Consumer<RestaurantsController>(
                builder: (context, restaurantsController, _) {
                  return PreviousOrdersRestaurantListViewWidget(
                    previousOrders: restaurantsController.previousRestOrders,
                  );
                },
              ),
            ),
          ],
          10.sbH,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Builder(
              builder: (context) {
                return CustomFormField(
                  onFieldSubmitted: (value) {
                    if (value.isNotEmpty) {
                      context.read<RestaurantsController>().getRestaurants(search: value);
                    }
                  },
                  onChanged: (value) {
                    if (value.isEmpty) {
                      context.read<RestaurantsController>().getRestaurants();
                    }
                  },
                  prefixIcon: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 13),
                    child: SvgPicture.asset(AppImages.searchIcon),
                  ),
                  hintText: 'searchForWhatYouWant'.tr,
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          const FiltrationListViewWidget(),
          const SizedBox(height: 16),
          const Expanded(child: AllRestaurantsWidget()),
          // const Expanded(child: ClosedRestaurantsWidget())
        ],
      ),
    );
  }
}
