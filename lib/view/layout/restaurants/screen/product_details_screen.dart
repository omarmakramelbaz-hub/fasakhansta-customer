import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../../helpers/hive/hive_methods.dart';
import '../../../../helpers/images/app_images.dart';
import '../../../../helpers/routes/app_routers_import.dart';
import '../../../../helpers/theme/app_colors.dart';
import '../../../../helpers/theme/app_text_style.dart';
import '../../../../helpers/translation/all_translation.dart';
import '../../../custom_widgets/api_response_widget/api_response_widget.dart';
import '../../../custom_widgets/custom_image/custom_network_image.dart';
import '../../cart/controller/cart_controller.dart';
import '../../cart/screen/cart_screen.dart';
import '../controller/restaurants_controller.dart';
import '../widgets/custom_button_bottom_navigation.dart';

class ProductDetailsDetailsArgs {
  final int id;
  final VoidCallback? onSuccessAddItem;

  const ProductDetailsDetailsArgs({required this.id, this.onSuccessAddItem});
}

class ProductDetailsScreen extends StatefulWidget {
  final ProductDetailsDetailsArgs args;
  static const String routeName = 'ProductDetailsScreen';

  const ProductDetailsScreen({super.key, required this.args});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int _selectedRadio = 0;
  int _chooseQuantity = 0;
  String productFeature = '';
  int? productFeatureId;
  int quantity = 1;

  @override
  void initState() {
    context.read<CartController>().totalCountAddTCart = null;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (BuildContext context) => RestaurantsController()
            ..initialProductsDetailsRestaurant()
            ..getProductsDetailsRestaurant(id: widget.args.id),
        ),
      ],
      child: Consumer<RestaurantsController>(
        builder: (BuildContext context, restaurantsController, _) {
          final product = restaurantsController.productsDetailsRestaurant;
          final quantityFeatures = product?.features
                  ?.where(
                    (feature) =>
                        feature.name == 'kilo' || feature.name == 'half' || feature.name == 'quarter',
                  )
                  .toList() ??
              [];

          final dynamic defaultFeature;
          if (product?.features?.any((e) => e.name == 'kilo') == true) {
            defaultFeature = product?.features?.firstWhere((e) => e.name == 'kilo').id;
          } else if (product?.features?.any((e) => e.name == 'large') == true) {
            defaultFeature = product?.features?.firstWhere((e) => e.name == 'large').id;
          } else {
            defaultFeature = null;
          }

          return Scaffold(
            backgroundColor: AppColors.whiteColor,
            body: ApiResponseWidget(
              apiResponse: restaurantsController.productsDetailsRestaurantApiResponse,
              onReload: () => restaurantsController.getProductsDetailsRestaurant(id: widget.args.id),
              isEmpty: product == null,
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHero(context, restaurantsController),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product?.productName ?? '',
                            style: AppTextStyle.text22BS(),
                          ),
                          if ((product?.productDescription ?? '').trim().isNotEmpty) ...[
                            const SizedBox(height: 10),
                            Text(
                              product?.productDescription ?? '',
                              textAlign: TextAlign.start,
                              style: AppTextStyle.text14RG().copyWith(height: 1.65),
                            ),
                          ],
                          const SizedBox(height: 22),
                          Divider(height: 1, color: AppColors.borderColorContainer),
                          if (quantityFeatures.isNotEmpty) ...[
                            const SizedBox(height: 24),
                            _buildSectionHeader('chooseQuantity'.tr),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                for (int index = 0; index < quantityFeatures.length; index++) ...[
                                  if (index > 0) const SizedBox(width: 10),
                                  Expanded(
                                    child: _buildQuantityButton(
                                      label: _quantityLabel(quantityFeatures[index].name),
                                      selected: _chooseQuantity == index,
                                      onTap: () {
                                        final feature = quantityFeatures[index];
                                        setState(() {
                                          _chooseQuantity = index;
                                          productFeatureId = feature.id ?? 0;
                                          productFeature = feature.name ?? '';
                                          quantity = _quantityDivider(productFeature);
                                        });
                                        context.read<CartController>().totalCountAddTCart = null;
                                        log(quantity.toString());
                                      },
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 26),
                            Divider(height: 1, color: AppColors.borderColorContainer),
                          ],
                          const SizedBox(height: 24),
                          _buildSectionHeader('selectTheCategory'.tr),
                          const SizedBox(height: 16),
                          if (_asInt(product?.productPrice) != 0)
                            _buildCategoryOption(
                              value: 0,
                              label: 'full'.tr,
                              price: _asInt(product?.productPrice),
                              onTap: () => _selectCategory(restaurantsController, 0),
                            ),
                          if (_asInt(product?.extraClean) != 0)
                            _buildCategoryOption(
                              value: 1,
                              label: 'clean'.tr,
                              price: _asInt(product?.productPrice) + _asInt(product?.extraClean),
                              onTap: () => _selectCategory(restaurantsController, 1),
                            ),
                          if (_asInt(product?.extraClear) != 0)
                            _buildCategoryOption(
                              value: 2,
                              label: 'clear'.tr,
                              price: _asInt(product?.productPrice) + _asInt(product?.extraClear),
                              onTap: () => _selectCategory(restaurantsController, 2),
                            ),
                          if (_asInt(product?.extraLarge) != 0)
                            _buildCategoryOption(
                              value: 3,
                              label: 'large'.tr,
                              price: _asInt(product?.productPrice) + _asInt(product?.extraLarge),
                              onTap: () => _selectCategory(restaurantsController, 3, featureName: 'large'),
                            ),
                          if (_asInt(product?.extraMedium) != 0)
                            _buildCategoryOption(
                              value: 4,
                              label: 'medium'.tr,
                              price: _asInt(product?.productPrice) + _asInt(product?.extraMedium),
                              onTap: () => _selectCategory(restaurantsController, 4, featureName: 'medium'),
                            ),
                          if (_asInt(product?.extraVacuim) != 0)
                            _buildCategoryOption(
                              value: 5,
                              label: 'vacuum'.tr,
                              price: _asInt(product?.productPrice) + _asInt(product?.extraVacuim),
                              onTap: () => _selectCategory(restaurantsController, 5, featureName: 'vacuim'),
                            ),
                          if (_asInt(product?.extraCombo) != 0)
                            _buildCategoryOption(
                              value: 6,
                              label: 'combo'.tr,
                              price: _asInt(product?.productPrice) + _asInt(product?.extraCombo),
                              onTap: () => _selectCategory(restaurantsController, 6, featureName: 'combo'),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            bottomNavigationBar: ApiResponseWidget(
              loadingWidget: const SizedBox(),
              apiResponse: restaurantsController.productsDetailsRestaurantApiResponse,
              onReload: () => restaurantsController.getProductsDetailsRestaurant(id: widget.args.id),
              isEmpty: product == null,
              child: CustomButtonBottomNavigation(
                featureId: productFeatureId ?? defaultFeature,
                qty: quantity,
                onSuccessAddItems: () {
                  widget.args.onSuccessAddItem?.call();
                  context.read<CartController>().getCart();
                },
                restaurantProductId: product?.id ?? 0,
                productFeature: productFeature,
                productClean: _selectedRadio == 0 ? null : getProductClean(_selectedRadio),
                total: getTotalFromSelectedRadio(restaurantsController),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHero(BuildContext context, RestaurantsController restaurantsController) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(28),
            bottomRight: Radius.circular(28),
          ),
          child: CustomNetworkImage(
            imageUrl: restaurantsController.productsDetailsRestaurant?.productImage ?? '',
            height: 238,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 45,
          right: 16,
          child: _roundActionButton(
            onTap: () => Navigator.pop(context),
            child: SvgPicture.asset(
              AppImages.backIosIcon,
              width: 20,
              height: 20,
              colorFilter: ColorFilter.mode(AppColors.mainAppColor, BlendMode.srcIn),
            ),
          ),
        ),
        if (HiveMethods.getToken() != null)
          Positioned(
            top: 45,
            left: 16,
            child: _roundActionButton(
              onTap: () => NamedNavigatorImpl.push(CartScreen.routeName),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  SvgPicture.asset(AppImages.nCartIcon, width: 22, height: 22),
                  Positioned(
                    top: -8,
                    right: -9,
                    child: Container(
                      constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: AppColors.mainAppColor,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.whiteColor, width: 1.5),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        context.watch<CartController>().cart?.carts?.length.toString() ?? '0',
                        style: AppTextStyle.text10BW().copyWith(height: 1.1),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _roundActionButton({required VoidCallback onTap, required Widget child}) {
    return Material(
      color: AppColors.whiteColor,
      shape: const CircleBorder(),
      elevation: 2,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(width: 42, height: 42, child: Center(child: child)),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Text(title, style: AppTextStyle.text18BS()),
        const Spacer(),
        Text(
          '${'required'.tr}*',
          style: AppTextStyle.text14RM(color: AppColors.mainAppColor),
        ),
      ],
    );
  }

  Widget _buildQuantityButton({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 48,
          decoration: BoxDecoration(
            color: selected ? AppColors.mainAppColor : AppColors.whiteColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? AppColors.mainAppColor : AppColors.borderColorContainer,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: AppColors.mainAppColor.withValues(alpha: 0.16),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: selected ? AppTextStyle.text16BW() : AppTextStyle.text16MS(),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryOption({
    required int value,
    required String label,
    required int price,
    required VoidCallback onTap,
  }) {
    final selected = _selectedRadio == value;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            constraints: const BoxConstraints(minHeight: 78),
            padding: const EdgeInsetsDirectional.fromSTEB(8, 12, 16, 12),
            decoration: BoxDecoration(
              color: selected ? AppColors.mainAppColor.withValues(alpha: 0.045) : AppColors.whiteColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: selected ? AppColors.mainAppColor.withValues(alpha: 0.65) : AppColors.borderColorContainer,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.blackColor.withValues(alpha: 0.045),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                Radio<int>(
                  value: value,
                  groupValue: _selectedRadio,
                  onChanged: (_) => onTap(),
                  activeColor: AppColors.mainAppColor,
                  visualDensity: VisualDensity.compact,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    label,
                    style: selected
                        ? AppTextStyle.text16BM(color: AppColors.mainAppColor)
                        : AppTextStyle.text16MS(),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${_formatPrice(price)} ج.م',
                  style: AppTextStyle.text17BS(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _selectCategory(
    RestaurantsController restaurantsController,
    int value, {
    String? featureName,
  }) {
    setState(() {
      _selectedRadio = value;
      if (featureName != null &&
          restaurantsController.productsDetailsRestaurant?.features?.any((e) => e.name == featureName) == true) {
        productFeatureId = restaurantsController.productsDetailsRestaurant?.features
            ?.firstWhere((e) => e.name == featureName)
            .id;
      }
    });
    context.read<CartController>().totalCountAddTCart = null;
  }

  String _quantityLabel(String? name) {
    return switch (name) {
      'kilo' => 'kilo'.tr,
      'half' => 'half'.tr,
      'quarter' => 'quarter'.tr,
      _ => '',
    };
  }

  int _quantityDivider(String name) {
    return switch (name) {
      'half' => 2,
      'quarter' => 4,
      _ => 1,
    };
  }

  int _asInt(dynamic value) => int.tryParse(value?.toString() ?? '') ?? 0;

  String _formatPrice(num value) {
    final digits = value.round().toString();
    return digits.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]},',
    );
  }

  String getTotalFromSelectedRadio(RestaurantsController restaurantsController) {
    final data = restaurantsController.productsDetailsRestaurant;
    final base = _asInt(data?.productPrice);
    return switch (_selectedRadio) {
      0 => '$base',
      1 => '${base + _asInt(data?.extraClean)}',
      2 => '${base + _asInt(data?.extraClear)}',
      3 => '${base + _asInt(data?.extraLarge)}',
      4 => '${base + _asInt(data?.extraMedium)}',
      5 => '${base + _asInt(data?.extraVacuim)}',
      6 => '${base + _asInt(data?.extraCombo)}',
      _ => '$base',
    };
  }

  String? getProductClean(int selectRadio) {
    switch (selectRadio) {
      case 1:
        return 'extra_clean';
      case 2:
        return 'extra_clear';
      case 3:
        return 'extra_large';
      case 4:
        return 'extra_medium';
      case 5:
        return 'extra_vacuim';
      case 6:
        return 'extra_combo';
      default:
        return null;
    }
  }
}
