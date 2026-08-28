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
import '../../../custom_widgets/custom_image/custom_image.dart';
import '../../auth/controller/auth_controller.dart';
import '../../restaurants/screen/restaurant_details_screen.dart';
import '../controller/cart_controller.dart';
import '../widgets/button_nav_cart_widget.dart';
import '../widgets/cart_minimum_order_widget.dart';
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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cart = context.read<CartController>();
      cart.initialCart();
      cart.getCart();
      context.read<AuthController>().initialProfile();
      context.read<AuthController>().getProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<CartController, AuthController>(
      builder: (context, cartController, authController, _) {
        final totalPrice = cartController.totalPrice;
        final serviceFees = ((cartController.cart?.resturant?.serviceFees ?? 0) * totalPrice) / 100;
        final addedPrice = ((cartController.cart?.resturant?.tax ?? 0) * totalPrice) / 100;
        final grandTotal = serviceFees + addedPrice + totalPrice;
        final hasItems = cartController.cart?.carts?.isNotEmpty ?? false;
        final minimumOrder = (cartController.cart?.resturant?.resturantMinOrderPrice ?? 0).toDouble();

        return Scaffold(
          backgroundColor: const Color(0xFFF8F8F8),
          appBar: AppBar(
            elevation: 0,
            backgroundColor: AppColors.mainAppColor,
            foregroundColor: AppColors.whiteColor,
            centerTitle: true,
            title: Text('shoppingCart'.tr, style: AppTextStyle.text18BS().copyWith(color: AppColors.whiteColor)),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              if (hasItems && (cartController.cart?.resturant?.resturantId ?? 0) != 0)
                IconButton(
                  tooltip: 'addMore'.tr,
                  icon: const Icon(Icons.add_shopping_cart_rounded),
                  onPressed: () {
                    NamedNavigatorImpl.push(
                      RestaurantDetailsScreen.routeName,
                      arguments: RestaurantDetailsArgs(
                        id: cartController.cart?.resturant?.resturantId ?? 0,
                        onSuccessAddItem: () => cartController.getCart(),
                      ),
                    );
                  },
                ),
            ],
          ),
          body: ApiResponseWidget(
            apiResponse: cartController.cartResponse,
            onReload: cartController.getCart,
            isEmpty: !hasItems || cartController.cart == null,
            emptyWidget: _buildEmptyCart(),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(top: 14, bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (minimumOrder > 0)
                    CartMinimumOrderWidget(current: totalPrice.toDouble(), minimum: minimumOrder),
                  10.sbH,
                  _buildRestaurantHeader(cartController),
                  14.sbH,
                  ...List.generate(
                    cartController.cart?.carts?.length ?? 0,
                    (index) => OrdersInCartWidget(cart: cartController.cart!.carts![index]),
                  ),
                  _buildRecommended(cartController),
                  14.sbH,
                  _buildPaymentSummary(totalPrice, serviceFees, addedPrice, grandTotal, cartController),
                ],
              ),
            ),
          ),
          bottomNavigationBar: hasItems
              ? _buildCheckoutBar(cartController, totalPrice, grandTotal)
              : null,
        );
      },
    );
  }

  Widget _buildRestaurantHeader(CartController controller) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.mainAppColor.withValues(alpha: .15)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.mainAppColor.withValues(alpha: .1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.storefront_rounded, color: AppColors.mainAppColor),
          ),
          12.sbW,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('yourOrderFrom'.tr, style: AppTextStyle.text12RG()),
                2.sbH,
                Text(
                  controller.cart?.resturant?.resturantName ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.text16BS(),
                ),
              ],
            ),
          ),
          8.sbW,
          InkWell(
            onTap: () => _showClearCartDialog(controller),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.redColor.withValues(alpha: .07),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.redColor.withValues(alpha: .22)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.redColor),
                  5.sbW,
                  Text(
                    context.languageCode == 'ar' ? 'حذف السلة' : 'Clear cart',
                    style: AppTextStyle.text12MS().copyWith(color: AppColors.redColor),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showClearCartDialog(CartController controller) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        final isArabic = context.languageCode == 'ar';
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          insetPadding: const EdgeInsets.symmetric(horizontal: 28),
          titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
          contentPadding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          title: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.redColor.withValues(alpha: .08),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(Icons.delete_sweep_rounded, color: AppColors.redColor),
              ),
              10.sbW,
              Expanded(
                child: Text(
                  isArabic ? 'حذف السلة' : 'Clear cart',
                  style: AppTextStyle.text18BS(),
                ),
              ),
            ],
          ),
          content: Text(
            isArabic
                ? 'هل أنت متأكد أنك تريد حذف جميع المنتجات من السلة؟'
                : 'Are you sure you want to remove all products from your cart?',
            style: AppTextStyle.text14RG(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                isArabic ? 'إلغاء' : 'Cancel',
                style: AppTextStyle.text14MS().copyWith(color: AppColors.greyColor),
              ),
            ),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.redColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                Navigator.pop(dialogContext);
                controller.emptyCart(
                  onSuccess: () {
                    controller.initialCart();
                    controller.getCart();
                  },
                );
              },
              icon: const Icon(Icons.delete_outline_rounded, size: 18),
              label: Text(isArabic ? 'حذف السلة' : 'Clear cart'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRecommended(CartController controller) {
    final products = controller.cart?.recommendedProducts ?? [];
    if (products.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Text('youMayAlsoLike'.tr, style: AppTextStyle.text17BS()),
        ),
        SizedBox(
          height: 168,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: products.length,
            separatorBuilder: (_, __) => 10.sbW,
            itemBuilder: (context, index) {
              final product = products[index];
              return Container(
                width: 132,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.whiteColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.greyColor.withValues(alpha: .12)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        CustomImage(
                          height: 82,
                          width: double.infinity,
                          radius: 12,
                          fit: BoxFit.cover,
                          path: product.productImage ?? '',
                          type: ImageType.network,
                        ),
                        Positioned(
                          left: 5,
                          bottom: 5,
                          child: InkWell(
                            onTap: () => controller.addToCart(
                              restaurantProductId: product.id ?? 0,
                              qty: 1,
                              onSuccess: () => controller.getCart(),
                              anotherCart: () {},
                            ),
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: AppColors.whiteColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(Icons.add, color: AppColors.mainAppColor, size: 19),
                            ),
                          ),
                        ),
                      ],
                    ),
                    6.sbH,
                    Text(product.productName ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTextStyle.text13BS()),
                    3.sbH,
                    Text(
                      'egyp'.tr.replaceAll('{}', '${product.productPrice ?? 0}'),
                      style: AppTextStyle.text12MS().copyWith(color: AppColors.mainAppColor),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentSummary(double subtotal, double serviceFees, double addedPrice, double total, CartController controller) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.greyColor.withValues(alpha: .12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('paymentSummary'.tr, style: AppTextStyle.text17BS()),
          16.sbH,
          _summaryRow('subtotal'.tr, subtotal),
          10.sbH,
          _summaryRow('serviceFees'.tr, serviceFees),
          10.sbH,
          _summaryRow('addedValuePrice'.tr, addedPrice),
          14.sbH,
          Divider(color: AppColors.greyColor.withValues(alpha: .2)),
          14.sbH,
          Row(
            children: [
              Text('total'.tr, style: AppTextStyle.text17BS()),
              const Spacer(),
              Text(
                'pound'.tr.replaceAll('{}', total.toStringAsFixed(2)),
                style: AppTextStyle.text18BS().copyWith(color: AppColors.mainAppColor),
              ),
            ],
          ),
          if (controller.cart?.resturant?.resturantKmPrice != 0) ...[
            6.sbH,
            Text('thisTotalWithoutDeliveryCharge'.tr, style: AppTextStyle.text12MS().copyWith(color: AppColors.redColor)),
          ],
        ],
      ),
    );
  }

  Widget _summaryRow(String title, double value) {
    return Row(
      children: [
        Text(title, style: AppTextStyle.text14RG()),
        const Spacer(),
        Text('pound'.tr.replaceAll('{}', value.toStringAsFixed(2)), style: AppTextStyle.text14RM()),
      ],
    );
  }

  Widget _buildCheckoutBar(CartController controller, double subtotal, double grandTotal) {
    return ButtonNavCartWidget(
      totalInCart: grandTotal.toStringAsFixed(2),
      onPressedExecuteTheOrder: () => _executeOrder(controller, subtotal),
    );
  }

  void _executeOrder(CartController controller, double subtotal) {
    log(controller.cart?.resturant?.resturantAreas?.map((area) => area.areaId).whereType<int>().toList().toString() ?? '');
    if ((controller.cart?.resturant?.resturantMinOrderPrice ?? 0) > subtotal) {
      CommonMethods.showError(
        message: 'cantExecuteOrderLessThan'.tr.replaceAll('{}', '${controller.cart?.resturant?.resturantMinOrderPrice ?? 0}'),
      );
      return;
    }

    NamedNavigatorImpl.push(
      ChooseAddressFromMapScreen.routeName,
      arguments: ChooseAddressFromMapScreenArgs(
        resturantId: controller.cart?.resturant?.resturantId ?? 0,
        areaId: controller.cart?.resturant?.resturantAreas?.map((area) => area.areaId).whereType<int>().toList() ?? [1],
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: ListView(
        shrinkWrap: true,
        children: [
          SizedBox(height: context.height * .16),
          const CustomImage(path: AppImages.emptyCartIcon, type: ImageType.svg, height: 110),
          28.sbH,
          Center(child: Text('cartIsEmpty'.tr, style: AppTextStyle.text16BS().copyWith(color: AppColors.mainAppColor))),
          8.sbH,
          Center(child: Text('addYourFavoriteProducts'.tr, style: AppTextStyle.text13RG())),
        ],
      ),
    );
  }
}
