import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../helpers/extensions/extensions.dart';
import '../../../../helpers/hive/hive_methods.dart';
import '../../../../helpers/images/app_images.dart';
import '../../../../helpers/routes/app_routers_import.dart';
import '../../../../helpers/theme/app_colors.dart';
import '../../../../helpers/theme/app_text_style.dart';
import '../../../../helpers/translation/all_translation.dart';
import '../../../../helpers/utils/common_methods.dart';
import '../../../custom_widgets/api_response_widget/api_response_widget.dart';
import '../../../custom_widgets/custom_app_bar/custom_app_bar.dart';
import '../../../custom_widgets/custom_image/custom_image.dart';
import '../../auth/controller/auth_controller.dart';
import '../../restaurants/screen/restaurant_details_screen.dart';
import '../controller/cart_controller.dart';
import '../widgets/button_nav_cart_widget.dart';
import '../widgets/orders_in_cart_widget.dart';
import 'choose_address_from_map_screen.dart';

class CartScreen extends StatefulWidget {
  static const String routeName = 'CartScreen';
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Provider.of<CartController>(context, listen: false).initialCart();
      Provider.of<CartController>(context, listen: false).getCart();
      Provider.of<AuthController>(context, listen: false).initialProfile();
      Provider.of<AuthController>(context, listen: false).getProfile();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<CartController, AuthController>(
      builder: (context, cartController, authController, _) {
        final totalPrice = cartController.totalPrice;
        final num serviceFees = (((cartController.cart?.resturant?.serviceFees ?? 0) * (totalPrice)) / 100);
        final num addedPrice = (((cartController.cart?.resturant?.tax ?? 0) * (totalPrice)) / 100);
        final num grandTotal = (serviceFees + addedPrice + (totalPrice));
        return Scaffold(
          appBar: CustomAppBar(
            actions: [
              ((cartController.cart?.carts?.isNotEmpty ?? false) && cartController.cart?.resturant?.resturantId != 0)
                  ? TextButton(
                      onPressed: () {
                        NamedNavigatorImpl.push(
                          RestaurantDetailsScreen.routeName,
                          arguments: RestaurantDetailsArgs(
                            id: cartController.cart?.resturant?.resturantId ?? 0,
                            onSuccessAddItem: () => cartController.getCart(),
                          ),
                        );
                      },
                      child: Text(
                        'addMore'.tr,
                        style: AppTextStyle.text16BS().copyWith(color: AppColors.mainAppColor),
                      ),
                    )
                  : const SizedBox(),
            ],
            height: 70,
            centerTitle: false,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            title: Text('shoppingCart'.tr, style: AppTextStyle.text16BS()),
          ),
          body: ApiResponseWidget(
            apiResponse: cartController.cartResponse,
            onReload: cartController.getCart,
            isEmpty: cartController.cart?.carts?.isEmpty ?? false || cartController.cart == null,
            emptyWidget: Center(
              child: ListView(
                children: [
                  SizedBox(height: context.height * 0.2),
                  const CustomImage(path: AppImages.emptyCartIcon, type: ImageType.svg, height: 100),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'cartIsEmpty'.tr,
                        style: AppTextStyle.text14BS().copyWith(color: AppColors.mainAppColor),
                      ),
                      const SizedBox(width: 35),
                    ],
                  ),
                ],
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 28),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(cartController.cart?.resturant?.resturantName ?? '', style: AppTextStyle.text16BS()),
                  ),
                  const SizedBox(height: 24),
                  ListView.separated(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    separatorBuilder: (context, index) => const Divider(indent: 20, endIndent: 20, thickness: 1),
                    itemCount: cartController.cart?.carts?.length ?? 0,
                    itemBuilder: (context, index) => OrdersInCartWidget(cart: cartController.cart!.carts![index]),
                  ),
                  Divider(color: AppColors.greyColor.withValues(alpha: 0.5), height: 2),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text('youMayAlsoLike'.tr, style: AppTextStyle.text16BS()),
                  ),
                  buildYouMayAlsoLikeWidget(cartController),
                  //===========> Empty Cart button
                  // Padding(
                  //   padding: const EdgeInsets.all(16.0),
                  //   child: CustomButton(
                  //     text: 'emptyCart'.tr,
                  //     prefixIcon: Icon(
                  //       Icons.delete_forever_sharp,
                  //       color: AppColor.whiteColor,
                  //     ),
                  //     onPressed: () {
                  //       cartController.emptyCart(onSuccess: () {
                  //         cartController.getCart();
                  //       });
                  //     },
                  //   ),
                  // ),
                  const SizedBox(height: 24),
                  Container(
                    height: 5,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.greyColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('paymentSummary'.tr, style: AppTextStyle.text16BS()),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Text('subtotal'.tr, style: AppTextStyle.text16RG()),
                            const Spacer(),
                            Text(
                              'pound'.tr.replaceAll('{}', totalPrice.toString()),
                              style: AppTextStyle.text16RG(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Row(
                        //   children: [
                        //     Text(
                        //       'deliveryCharges'.tr,
                        //       style: AppTextStyle.text16RG(),
                        //     ),
                        //     const Spacer(),
                        //     //======== ======= todo: add km price acceding to location
                        //     //علي حسب المسافة بالكيلو متر ولنفرصض مثلا انها كيلو متر واحد
                        //     Text(
                        //       'pound'.tr.replaceAll(
                        //           "{}", kmPrice.toStringAsFixed(2).toString()),
                        //       style: AppTextStyle.text16RG(),
                        //     ),
                        //   ],
                        // ),
                        // const SizedBox(
                        //   height: 24,
                        // ),
                        Row(
                          children: [
                            Text('serviceFees'.tr, style: AppTextStyle.text16RG()),
                            const Spacer(),
                            Text(
                              'pound'.tr.replaceAll('{}', (serviceFees.toStringAsFixed(2).toString())),
                              style: AppTextStyle.text16RG(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Text('addedValuePrice'.tr, style: AppTextStyle.text16RG()),
                            const Spacer(),
                            Text(
                              'pound'.tr.replaceAll('{}', (addedPrice.toStringAsFixed(2).toString())),
                              style: AppTextStyle.text16RG(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Divider(color: AppColors.greyColor.withValues(alpha: 0.5), height: 2),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('total'.tr, style: AppTextStyle.text16MS()),
                                5.sbH,
                                cartController.cart?.resturant?.resturantKmPrice != 0
                                    ? Text(
                                        'thisTotalWithoutDeliveryCharge'.tr,
                                        style: AppTextStyle.text14MS().copyWith(color: AppColors.redColor),
                                      )
                                    : const SizedBox(),
                              ],
                            ),
                            const Spacer(),
                            Text(
                              'pound'.tr.replaceAll('{}', (grandTotal.toStringAsFixed(2).toString())),
                              style: AppTextStyle.text16MS(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Text(
                        //   'minOrderPrice'
                        //       .tr
                        //       .replaceAll("{}", "$resturantMinOrderPrice"),
                        //   style: AppTextStyle.text16MS(),
                        // ),
                      ],
                    ),
                  ),
                  20.sbH,
                ],
              ),
            ),
          ),
          bottomNavigationBar: cartController.cart?.carts?.isEmpty ?? false || cartController.cart == null
              ? null
              : ButtonNavCartWidget(
                  totalInCart: grandTotal.toStringAsFixed(2).toString(),
                  onPressedExecuteTheOrder: () {
                    log(
                      cartController.cart?.resturant?.resturantAreas
                              ?.map((area) => area.areaId)
                              .whereType<int>()
                              .toList()
                              .toString() ??
                          '',
                    );
                    if (((cartController.cart?.resturant?.resturantMinOrderPrice ?? 0) > totalPrice)) {
                      CommonMethods.showError(
                        message: 'cantExecuteOrderLessThan'.tr.replaceAll(
                              '{}',
                              '${cartController.cart?.resturant?.resturantMinOrderPrice ?? 0}',
                            ),
                      );
                    } else {
                      if (cartController.cart?.resturant?.resturantAreas
                              ?.map((area) => area.areaId)
                              .whereType<int>()
                              .toList()
                              .isNotEmpty ??
                          true) {
                        NamedNavigatorImpl.push(
                          ChooseAddressFromMapScreen.routeName,
                          arguments: ChooseAddressFromMapScreenArgs(
                            resturantId: cartController.cart?.resturant?.resturantId ?? 0,
                            areaId: cartController.cart?.resturant?.resturantAreas
                                    ?.map((area) => area.areaId)
                                    .whereType<int>()
                                    .toList() ??
                                [],
                          ),
                        );
                      } else {
                        NamedNavigatorImpl.push(
                          ChooseAddressFromMapScreen.routeName,
                          arguments: ChooseAddressFromMapScreenArgs(
                            resturantId: cartController.cart?.resturant?.resturantId ?? 0,
                            areaId: [1],
                          ),
                        );
                      }
                      // PrintLog.e(cartController.cart?.resturant?.toJson());
                    }
                  },
                ),
        );
      },
    );
  }

  SizedBox buildYouMayAlsoLikeWidget(CartController cartController) {
    return SizedBox(
      width: double.infinity,
      height: 170,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: cartController.cart?.recommendedProducts?.length ?? 0,
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                children: [
                  CustomImage(
                    height: 106,
                    width: 96,
                    radius: 12,
                    fit: BoxFit.cover,
                    path: cartController.cart?.recommendedProducts?[index].productImage ?? '',
                    type: ImageType.network,
                  ),
                  Positioned(
                    bottom: 5,
                    left: 2,
                    child: InkWell(
                      onTap: () {
                        cartController.addToCart(
                          restaurantProductId: cartController.cart?.recommendedProducts?[index].id ?? 0,
                          qty: 1,
                          onSuccess: () => cartController.getCart(),
                          anotherCart: () {},
                        );
                      },
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Icon(Icons.add, color: AppColors.mainAppColor, size: 15),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              5.sbH,
              SizedBox(
                width: 96,
                child: Text(cartController.cart?.recommendedProducts?[index].productName ?? '', maxLines: 2),
              ),
              SizedBox(
                width: 96,
                child: Text(
                  'egyp'.tr.replaceAll(
                        '{}',
                        '${cartController.cart?.recommendedProducts?[index].productPrice.toString()}',
                      ),
                  maxLines: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  dynamic resturantAreaId({CartController? cartController, AuthController? authController}) {
    // Retrieve user's address list from authController
    var userAddresses = authController?.profile?.userAddresses;

    // Retrieve restaurant areas from cartController
    var resturantAreas = cartController?.cart?.resturant?.resturantAreas;

    // Return null if either list is null
    if (userAddresses == null || resturantAreas == null) {
      return null; // Handle null scenario
    }

    // Iterate over user addresses and restaurant areas to find a matching areaId
    for (var userAddress in userAddresses) {
      for (var resturantArea in resturantAreas) {
        // Ensure resturantArea has a valid areaId
        if (resturantArea.areaId == null) {
          continue; // Skip if restaurant areaId is null
        }

        // Check if the selected city area ID matches the restaurant areaId
        if (HiveMethods.getSelectedCityAreaId() == resturantArea.areaId) {
          return resturantArea.areaId;
        }

        // Check if the userAddress cityId matches the restaurant areaId
        if (userAddress.cityId == resturantArea.areaId) {
          return resturantArea.areaId;
        }
      }
    }

    // No matching area found, return null
    return null;
  }
}
