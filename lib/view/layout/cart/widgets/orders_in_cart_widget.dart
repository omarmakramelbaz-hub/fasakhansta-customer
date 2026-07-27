import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../helpers/extensions/extensions.dart';
import '../../../../helpers/routes/app_routers_import.dart';
import '../../../../helpers/theme/app_colors.dart';
import '../../../../helpers/theme/app_text_style.dart';
import '../../../../helpers/translation/all_translation.dart';
import '../../../custom_widgets/buttons/custom_button.dart';
import '../../../custom_widgets/custom_image/custom_network_image.dart';
import '../controller/cart_controller.dart';
import '../model/user_cart_model.dart';
import '../screen/update_cart_screen.dart';

class OrdersInCartWidget extends StatefulWidget {
  final Carts cart;

  const OrdersInCartWidget({super.key, required this.cart});

  @override
  State<OrdersInCartWidget> createState() => _OrdersInCartWidgetState();
}

class _OrdersInCartWidgetState extends State<OrdersInCartWidget> {
  @override
  Widget build(BuildContext context) {
    final cartController = Provider.of<CartController>(context, listen: false);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(width: 5),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 15),
                    Text(widget.cart.resturantProduct?.productName ?? '', style: AppTextStyle.text16BS()),
                    10.sbH,
                    Text(widget.cart.resturantProduct?.productTitle ?? '', style: AppTextStyle.text16RS()),
                    10.sbH,
                    CustomButton(
                      onPressed: () {
                        NamedNavigatorImpl.push(
                          ProductInCartDetailsScreen.routeName,
                          arguments: ProductInCartDetailsDetailsArgs(
                            cartItemId: widget.cart.id!,
                            id: widget.cart.resturantProduct?.id ?? 0,
                            onSuccessAddItem: () {},
                          ),
                        );
                        // NavigatorMethods.showAppBottomSheet(
                        //     context,
                        //     UpdateItemInCartBottomSheet(
                        //       productName:
                        //           widget.cart.resturantProduct?.productName ??
                        //               "",
                        //       resturantProduct: widget.cart.resturantProduct!,
                        //     ));
                      },
                      width: 85,
                      color: Colors.transparent,
                      prefixIcon: Icon(Icons.edit_outlined, color: AppColors.mainAppColor),
                      text: 'edit'.tr,
                      style: AppTextStyle.text16RM(),
                    ),
                    10.sbH,
                    Row(
                      children: [
                        Text(
                          'pound'.translate(
                            args: [(double.parse(widget.cart.price.toString()) * widget.cart.qty!).toString()],
                          ),
                          style: AppTextStyle.text16RS(),
                        ),
                      ],
                    ),
                    5.sbH,
                    widget.cart.productClean != null
                        ? Text(getProductClean(widget.cart.productClean ?? '') ?? '')
                        : const SizedBox(),
                    5.sbH,
                    widget.cart.productFeatureName != null
                        ? Text(getProductFeatureName(widget.cart.productFeatureName ?? '') ?? '')
                        : const SizedBox(),
                  ],
                ),
              ),
              const SizedBox(width: 5),
              Stack(
                children: [
                  CustomNetworkImage(
                    imageUrl: widget.cart.resturantProduct?.productImage ?? '',
                    height: 125,
                    width: 130,
                    radius: 12,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    bottom: 5,
                    left: 10,
                    right: 10,
                    child: Container(
                      height: 35,
                      decoration: BoxDecoration(
                        color: AppColors.whiteColor,
                        borderRadius: BorderRadius.circular(5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withValues(alpha: 0.5),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: () {
                              cartController.incrementQty(widget.cart);
                            },
                            icon: Icon(Icons.add, color: AppColors.mainAppColor, size: 20),
                          ),
                          Expanded(
                            child: Text(
                              (widget.cart.qty).toString(),
                              style: AppTextStyle.text14BS().copyWith(height: 2),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              cartController.decrementQty(widget.cart);
                              if (widget.cart.qty == 0) {
                                cartController.removeFromCart(widget.cart);
                              }
                            },
                            icon: widget.cart.qty == 1
                                ? Icon(Icons.delete_outline, color: AppColors.mainAppColor, size: 20)
                                : Icon(Icons.remove, color: AppColors.mainAppColor, size: 20),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
        ],
      ),
    );
  }

  String? getProductClean(String? productClean) {
    switch (productClean) {
      case 'extra_clean':
        return 'clean'.tr;
      case 'extra_clear':
        return 'clear'.tr;
      case 'extra_large':
        return 'large'.tr;
      case 'extra_medium':
        return 'medium'.tr;
      case 'extra_vacuim':
        return 'vacuum'.tr;
      case 'extra_combo':
        return 'combo'.tr;
      default:
        return '';
    }
  }

  String? getProductFeatureName(String? productFeatureName) {
    switch (productFeatureName) {
      case 'kilo':
        return 'kilo'.tr;
      case 'half':
        return 'half'.tr;
      case 'quarter':
        return 'quarter'.tr;
      default:
        return '';
    }
  }
}
