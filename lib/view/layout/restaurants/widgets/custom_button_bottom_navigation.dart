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
    final displayedPrice = _displayedPrice(context);

    return SafeArea(
      top: false,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
        decoration: BoxDecoration(
          color: AppColors.whiteColor,
          boxShadow: [
            BoxShadow(
              color: AppColors.blackColor.withValues(alpha: 0.10),
              blurRadius: 18,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (addToCartSelected) ...[
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: _buildQuantityStepper(context),
              ),
              const SizedBox(height: 10),
            ],
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(30),
                onTap: () => _handleAddToCart(context),
                child: Container(
                  height: 58,
                  width: double.infinity,
                  padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 0),
                  decoration: BoxDecoration(
                    color: AppColors.mainAppColor,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.mainAppColor.withValues(alpha: 0.22),
                        blurRadius: 14,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 23),
                            const SizedBox(width: 9),
                            Flexible(
                              child: Text(
                                'addToCart'.tr,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyle.buttonStyle,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 28,
                        color: AppColors.whiteColor.withValues(alpha: 0.45),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '${_formatPrice(displayedPrice)} ج.م',
                        style: AppTextStyle.text18BW(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityStepper(BuildContext context) {
    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.borderColorContainer),
        boxShadow: [
          BoxShadow(
            color: AppColors.blackColor.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _stepButton(
            icon: Icons.add,
            color: AppColors.mainAppColor,
            onTap: () {
              setState(() {
                count++;
                context.read<CartController>().totalCountAddTCart =
                    (_baseTotal * count).toString();
              });
            },
          ),
          SizedBox(
            width: 42,
            child: Text(
              count.toString(),
              textAlign: TextAlign.center,
              style: AppTextStyle.text16BS(),
            ),
          ),
          _stepButton(
            icon: Icons.remove,
            color: AppColors.secondAppColor,
            onTap: () {
              if (count <= 1) return;
              setState(() {
                count--;
                context.read<CartController>().totalCountAddTCart =
                    (_baseTotal * count).toString();
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _stepButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 32,
          height: 32,
          child: Icon(icon, color: color, size: 19),
        ),
      ),
    );
  }

  void _handleAddToCart(BuildContext context) {
    if (HiveMethods.getToken() == null) {
      CommonMethods.showChooseDialog(
        context,
        onPressed: () {
          Navigator.pop(context);
          NamedNavigatorImpl.push(RegisterScreen.routeName);
        },
        message: 'youMustLoginFirst'.tr,
      );
      return;
    }

    if (!addToCartSelected) {
      setState(() {
        addToCartSelected = true;
        count = 1;
        context.read<CartController>().totalCountAddTCart = null;
      });
      return;
    }

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

  int get _baseTotal => int.tryParse(widget.total ?? '0') ?? 0;

  num _displayedPrice(BuildContext context) {
    final rawTotal = context.watch<CartController>().totalCountAddTCart;
    final total = int.tryParse(rawTotal ?? '') ?? _baseTotal;
    final divider = widget.qty <= 0 ? 1 : widget.qty;
    return total / divider;
  }

  String _formatPrice(num value) {
    final rounded = value.round();
    final digits = rounded.toString();
    return digits.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]},',
    );
  }
}
