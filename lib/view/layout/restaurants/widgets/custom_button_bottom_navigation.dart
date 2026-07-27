import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../helpers/hive/hive_methods.dart';
import '../../../../helpers/routes/app_routers_import.dart';
import '../../../../helpers/theme/app_colors.dart';
import '../../../../helpers/theme/app_text_style.dart';
import '../../../../helpers/translation/all_translation.dart';
import '../../../../helpers/utils/common_methods.dart';
import '../../auth/screen/register_screen.dart';
import '../../cart/controller/cart_controller.dart';

class CustomButtonBottomNavigation extends StatefulWidget {
  final int restaurantProductId;
  final String productFeature;
  final int? featureId;
  final int qty;

  final String? productClean;
  final String? total;
  final VoidCallback? onSuccessAddItems;

  const CustomButtonBottomNavigation({
    super.key,
    required this.restaurantProductId,
    required this.productFeature,
    this.productClean,
    this.total,
    this.onSuccessAddItems,
    required this.qty,
    required this.featureId,
  });

  @override
  State<CustomButtonBottomNavigation> createState() => _CustomButtonBottomNavigationState();
}

class _CustomButtonBottomNavigationState extends State<CustomButtonBottomNavigation> {
  bool addToCartSelected = false;
  int count = 1;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 74,
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.5), blurRadius: 10, offset: const Offset(0, 0))],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        children: [
          Builder(
            builder: (context) {
              return Flexible(
                child: InkWell(
                  onTap: () {
                    if (HiveMethods.getToken() == null) {
                      CommonMethods.showChooseDialog(
                        context,
                        onPressed: () {
                          Navigator.pop(context);
                          NamedNavigatorImpl.push(RegisterScreen.routeName);
                        },
                        message: 'youMustLoginFirst'.tr,
                      );
                    } else if (addToCartSelected) {
                      context.read<CartController>().addToCart(
                            restaurantProductId: widget.restaurantProductId,
                            productFeature: widget.featureId,
                            productClean: widget.productClean,
                            qty: count,
                            onSuccess: () {
                              widget.onSuccessAddItems?.call();
                              context.read<CartController>().getCart();
                            },
                            anotherCart: () {
                              CommonMethods.showChooseDialog(
                                context,
                                title: 'didYouWantToDeleteCart'.tr,
                                message: '',
                                onPressed: () {
                                  context.read<CartController>().emptyCart(
                                    onSuccess: () {
                                      Navigator.pop(context);
                                      widget.onSuccessAddItems?.call();
                                      context.read<CartController>().addToCart(
                                            restaurantProductId: widget.restaurantProductId,
                                            productFeature: widget.featureId,
                                            productClean: widget.productClean,
                                            qty: count,
                                            onSuccess: () {
                                              widget.onSuccessAddItems?.call();
                                              context.read<CartController>().getCart();
                                            },
                                            anotherCart: () {},
                                          );
                                    },
                                  );
                                },
                              );
                            },
                          );
                    }
                    setState(() {
                      addToCartSelected = true;
                    });
                  },
                  child: Container(
                    width: double.infinity,
                    // height: 45,
                    padding: const EdgeInsets.symmetric(horizontal: 29, vertical: 10),
                    decoration: BoxDecoration(color: AppColors.mainAppColor, borderRadius: BorderRadius.circular(23)),
                    child: Row(
                      children: [
                        Flexible(child: Text('addToCart'.tr, style: AppTextStyle.buttonStyle)),
                        const SizedBox(width: 10),
                        if (context.read<CartController>().totalCountAddTCart != null)
                          Text(
                            (int.tryParse(context.read<CartController>().totalCountAddTCart!)! / widget.qty).toString(),
                            style: AppTextStyle.buttonStyle,
                          ),
                        if (context.read<CartController>().totalCountAddTCart == null) ...[
                          Text((int.tryParse(widget.total!)! / widget.qty).toString(), style: AppTextStyle.buttonStyle),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          if (addToCartSelected)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.whiteColor,
                    borderRadius: BorderRadius.circular(23),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.5),
                        blurRadius: 7,
                        offset: const Offset(0, 0),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () {
                          context.read<CartController>().totalCountAddTCart == null ? count = 1 : count;
                          setState(() {
                            count++;
                            context.read<CartController>().totalCountAddTCart =
                                (int.parse(widget.total ?? '1') * count).toString();
                          });
                        },
                        child: Icon(Icons.add, color: AppColors.yellowColor, size: 20),
                      ),
                      const SizedBox(width: 15),
                      Text(context.read<CartController>().totalCountAddTCart == null ? '1' : count.toString()),
                      const SizedBox(width: 20),
                      InkWell(
                        onTap: () {
                          context.read<CartController>().totalCountAddTCart == null ? count = 1 : count;
                          if (count > 1) {
                            setState(() {
                              count--;
                              context.read<CartController>().totalCountAddTCart =
                                  (int.parse(widget.total ?? '1') * count).toString();
                            });
                          }
                        },
                        child: Icon(Icons.remove, color: AppColors.secondAppColor, size: 12),
                      ),
                    ],
                  ),
                ),
              ],
            )
          else
            const SizedBox(),
        ],
      ),
    );
  }
}
