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
  bool initial = false;

  @override
  void initState() {
    initial = true;
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
          final dynamic defaultFeature;
          if (restaurantsController.productsDetailsRestaurant?.features?.any((e) => e.name == 'kilo') == true) {
            defaultFeature =
                restaurantsController.productsDetailsRestaurant?.features?.firstWhere((e) => e.name == 'kilo').id;
          } else if (restaurantsController.productsDetailsRestaurant?.features?.any((e) => e.name == 'large') == true) {
            defaultFeature =
                restaurantsController.productsDetailsRestaurant?.features?.firstWhere((e) => e.name == 'large').id;
          } else {
            defaultFeature = null;
          }

          return Scaffold(
            body: ApiResponseWidget(
              apiResponse: restaurantsController.productsDetailsRestaurantApiResponse,
              onReload: () => restaurantsController.getProductsDetailsRestaurant(id: widget.args.id),
              isEmpty: restaurantsController.productsDetailsRestaurant == null,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(20),
                            bottomRight: Radius.circular(20),
                          ),
                          child: CustomNetworkImage(
                            imageUrl: restaurantsController.productsDetailsRestaurant?.productImage ?? '',
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 45,
                          right: 20,
                          child: InkWell(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: CircleAvatar(
                              radius: 20,
                              backgroundColor: AppColors.whiteColor,
                              child: Center(
                                child: SvgPicture.asset(
                                  AppImages.backIosIcon,
                                  colorFilter: ColorFilter.mode(AppColors.yellowColor, BlendMode.srcIn),
                                ),
                              ),
                            ),
                          ),
                        ),
                        HiveMethods.getToken() != null
                            ? Positioned(
                                top: 45,
                                left: 20,
                                child: CircleAvatar(
                                  radius: 20,
                                  backgroundColor: AppColors.whiteColor,
                                  child: InkWell(
                                    onTap: () => NamedNavigatorImpl.push(CartScreen.routeName),
                                    child: Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        SvgPicture.asset(AppImages.nCartIcon),
                                        Positioned(
                                          bottom: 0,
                                          right: -2,
                                          child: CircleAvatar(
                                            radius: 20,
                                            backgroundColor: AppColors.mainAppColor,
                                            child: InkWell(
                                              onTap: () => NamedNavigatorImpl.push(CartScreen.routeName),
                                              child: Stack(
                                                clipBehavior: Clip.none,
                                                children: [
                                                  SvgPicture.asset(AppImages.nCartIcon),
                                                  Positioned(
                                                    bottom: 0,
                                                    right: -2,
                                                    child: CircleAvatar(
                                                      radius: 8,
                                                      backgroundColor: AppColors.darkMainAppColor,
                                                      child: Text(
                                                        context
                                                                .watch<CartController>()
                                                                .cart
                                                                ?.carts
                                                                ?.length
                                                                .toString() ??
                                                            '0',
                                                        style: AppTextStyle.text16BW().copyWith(
                                                          height: 1.4,
                                                          fontSize: 14,
                                                          color: AppColors.whiteColor,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            : const SizedBox(),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            restaurantsController.productsDetailsRestaurant?.productName ?? '',
                            style: AppTextStyle.text18BS(),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            restaurantsController.productsDetailsRestaurant?.productDescription ?? '',
                            textAlign: TextAlign.justify,
                            style: AppTextStyle.text14RS().copyWith(height: 1.5),
                          ),

                          if (restaurantsController.productsDetailsRestaurant?.features?.isEmpty != true &&
                                  restaurantsController.productsDetailsRestaurant?.features
                                          ?.any((e) => e.name == 'kilo') ==
                                      true ||
                              restaurantsController.productsDetailsRestaurant?.features?.any(
                                    (e) => e.name == 'half',
                                  ) ==
                                  true ||
                              restaurantsController.productsDetailsRestaurant?.features?.any(
                                    (e) => e.name == 'quarter',
                                  ) ==
                                  true)
                            Column(
                              children: [
                                const SizedBox(height: 40),
                                Row(
                                  children: [
                                    Text('chooseQuantity'.tr, style: AppTextStyle.text16BS()),
                                    const Spacer(),
                                    Text(
                                      '${'required'.tr}*',
                                      style: AppTextStyle.text14RS().copyWith(color: AppColors.yellowColor),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    ...List.generate(
                                      restaurantsController.productsDetailsRestaurant?.features?.length ?? 0,
                                      (index) => InkWell(
                                        onTap: () {
                                          setState(() {
                                            _chooseQuantity = index;
                                            productFeatureId =
                                                restaurantsController.productsDetailsRestaurant?.features?[index].id ??
                                                    0;

                                            productFeature = restaurantsController
                                                    .productsDetailsRestaurant?.features?[index].name ??
                                                '';
                                            if (productFeature == 'kilo') {
                                              quantity = 1;
                                            } else if (productFeature == 'half') {
                                              quantity = 2;
                                            } else if (productFeature == 'quarter') {
                                              quantity = 4;
                                            }
                                          });

                                          log(quantity.toString());
                                        },
                                        child: Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                                              height: 37,
                                              decoration: BoxDecoration(
                                                color: _chooseQuantity == index
                                                    ? AppColors.mainAppColor
                                                    : AppColors.whiteColor,
                                                borderRadius: BorderRadius.circular(8),
                                                border: Border.all(color: AppColors.borderColorContainer),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  restaurantsController
                                                              .productsDetailsRestaurant?.features?[index].name ==
                                                          'kilo'
                                                      ? 'kilo'.tr
                                                      : restaurantsController
                                                                  .productsDetailsRestaurant?.features?[index].name ==
                                                              'half'
                                                          ? 'half'.tr
                                                          : restaurantsController.productsDetailsRestaurant
                                                                      ?.features?[index].name ==
                                                                  'quarter'
                                                              ? 'quarter'.tr
                                                              : '',
                                                  style: _chooseQuantity == index
                                                      ? AppTextStyle.text18MW().copyWith(fontSize: 16)
                                                      : AppTextStyle.text16MS(),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            )
                          else
                            const SizedBox(),
                          const SizedBox(height: 40),

                          //============================================ Category Column =================================
                          Row(
                            children: [
                              Text('selectTheCategory'.tr, style: AppTextStyle.text16BS()),
                              const Spacer(),
                              Text(
                                '${'required'.tr}*',
                                style: AppTextStyle.text14RS().copyWith(color: AppColors.yellowColor),
                              ),
                            ],
                          ),
                          const SizedBox(height: 22),
                          restaurantsController.productsDetailsRestaurant?.productPrice != 0
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Radio(
                                      activeColor: AppColors.yellowColor,
                                      value: 0,
                                      groupValue: _selectedRadio,
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedRadio = value!;
                                        });
                                        context.read<CartController>().totalCountAddTCart = null;
                                      },
                                    ),
                                    Text(
                                      'full'.tr,
                                      style: _selectedRadio == 0
                                          ? AppTextStyle.text16MS().copyWith(color: AppColors.yellowColor)
                                          : AppTextStyle.text16MG(),
                                    ),
                                    const Spacer(),
                                    restaurantsController.productsDetailsRestaurant == null
                                        ? const SizedBox()
                                        : Text(
                                            "${(int.tryParse(restaurantsController.productsDetailsRestaurant?.productPrice.toString() ?? "0") ?? 0)}",
                                            style:
                                                _selectedRadio == 0 ? AppTextStyle.text16MS() : AppTextStyle.text16MG(),
                                          ),
                                  ],
                                )
                              : const SizedBox(),
                          Column(
                            children: [
                              restaurantsController.productsDetailsRestaurant?.extraClean != 0
                                  ? Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Radio(
                                          activeColor: AppColors.yellowColor,
                                          value: 1,
                                          groupValue: _selectedRadio,
                                          onChanged: (value) {
                                            setState(() {
                                              _selectedRadio = value!;
                                            });
                                            context.read<CartController>().totalCountAddTCart = null;
                                          },
                                        ),
                                        Text(
                                          'clean'.tr,
                                          style: _selectedRadio == 1
                                              ? AppTextStyle.text16MS().copyWith(color: AppColors.yellowColor)
                                              : AppTextStyle.text16MG(),
                                        ),
                                        const Spacer(),
                                        restaurantsController.productsDetailsRestaurant == null
                                            ? const SizedBox()
                                            : Text(
                                                "${(int.tryParse(restaurantsController.productsDetailsRestaurant?.extraClean?.toString() ?? "0") ?? 0) + (int.tryParse(restaurantsController.productsDetailsRestaurant?.productPrice.toString() ?? "0") ?? 0)}",
                                                style: _selectedRadio == 1
                                                    ? AppTextStyle.text16MS()
                                                    : AppTextStyle.text16MG(),
                                              ),
                                      ],
                                    )
                                  : const SizedBox(),
                              restaurantsController.productsDetailsRestaurant?.extraClear != 0
                                  ? Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Radio(
                                          activeColor: AppColors.yellowColor,
                                          value: 2,
                                          groupValue: _selectedRadio,
                                          onChanged: (value) {
                                            setState(() {
                                              _selectedRadio = value!;
                                            });
                                            context.read<CartController>().totalCountAddTCart = null;
                                          },
                                        ),
                                        Text(
                                          'clear'.tr,
                                          style: _selectedRadio == 2
                                              ? AppTextStyle.text16MS().copyWith(color: AppColors.yellowColor)
                                              : AppTextStyle.text16MG(),
                                        ),
                                        const Spacer(),
                                        restaurantsController.productsDetailsRestaurant == null
                                            ? const SizedBox()
                                            : Text(
                                                "${(int.tryParse(restaurantsController.productsDetailsRestaurant?.extraClear?.toString() ?? "0") ?? 0) + (int.tryParse(restaurantsController.productsDetailsRestaurant?.productPrice.toString() ?? "0") ?? 0)}",
                                                style: _selectedRadio == 2
                                                    ? AppTextStyle.text16MS()
                                                    : AppTextStyle.text16MG(),
                                              ),
                                      ],
                                    )
                                  : const SizedBox(),
                              restaurantsController.productsDetailsRestaurant?.extraLarge != 0
                                  ? Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Radio(
                                          activeColor: AppColors.yellowColor,
                                          value: 3,
                                          groupValue: _selectedRadio,
                                          onChanged: (value) {
                                            setState(() {
                                              _selectedRadio = value!;
                                            });
                                            context.read<CartController>().totalCountAddTCart = null;
                                            if (restaurantsController.productsDetailsRestaurant?.features?.any(
                                                  (e) => e.name == 'large',
                                                ) ==
                                                true) {
                                              productFeatureId = restaurantsController
                                                  .productsDetailsRestaurant?.features
                                                  ?.firstWhere((e) => e.name == 'large')
                                                  .id;
                                            }
                                          },
                                        ),
                                        Text(
                                          'large'.tr,
                                          style: _selectedRadio == 3
                                              ? AppTextStyle.text16MS().copyWith(color: AppColors.yellowColor)
                                              : AppTextStyle.text16MG(),
                                        ),
                                        const Spacer(),
                                        restaurantsController.productsDetailsRestaurant == null
                                            ? const SizedBox()
                                            : Text(
                                                "${(int.tryParse(restaurantsController.productsDetailsRestaurant?.extraLarge?.toString() ?? "0") ?? 0) + (int.tryParse(restaurantsController.productsDetailsRestaurant?.productPrice.toString() ?? "0") ?? 0)}",
                                                style: _selectedRadio == 3
                                                    ? AppTextStyle.text16MS()
                                                    : AppTextStyle.text16MG(),
                                              ),
                                      ],
                                    )
                                  : const SizedBox(),
                              restaurantsController.productsDetailsRestaurant?.extraMedium != 0
                                  ? Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Radio(
                                          activeColor: AppColors.yellowColor,
                                          value: 4,
                                          groupValue: _selectedRadio,
                                          onChanged: (value) {
                                            setState(() {
                                              _selectedRadio = value!;
                                            });
                                            context.read<CartController>().totalCountAddTCart = null;
                                            if (restaurantsController.productsDetailsRestaurant?.features?.any(
                                                  (e) => e.name == 'medium',
                                                ) ==
                                                true) {
                                              productFeatureId = restaurantsController
                                                  .productsDetailsRestaurant?.features
                                                  ?.firstWhere((e) => e.name == 'medium')
                                                  .id;
                                            }
                                          },
                                        ),
                                        Text(
                                          'medium'.tr,
                                          style: _selectedRadio == 4
                                              ? AppTextStyle.text16MS().copyWith(color: AppColors.yellowColor)
                                              : AppTextStyle.text16MG(),
                                        ),
                                        const Spacer(),
                                        restaurantsController.productsDetailsRestaurant == null
                                            ? const SizedBox()
                                            : Text(
                                                "${(int.tryParse(restaurantsController.productsDetailsRestaurant?.extraMedium?.toString() ?? "0") ?? 0) + (int.tryParse(restaurantsController.productsDetailsRestaurant?.productPrice.toString() ?? "0") ?? 0)}",
                                                style: _selectedRadio == 4
                                                    ? AppTextStyle.text16MS()
                                                    : AppTextStyle.text16MG(),
                                              ),
                                      ],
                                    )
                                  : const SizedBox(),
                              restaurantsController.productsDetailsRestaurant?.extraVacuim != 0
                                  ? Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Radio(
                                          activeColor: AppColors.yellowColor,
                                          value: 5,
                                          groupValue: _selectedRadio,
                                          onChanged: (value) {
                                            setState(() {
                                              _selectedRadio = value!;
                                            });
                                            context.read<CartController>().totalCountAddTCart = null;
                                            if (restaurantsController.productsDetailsRestaurant?.features?.any(
                                                  (e) => e.name == 'vacuim',
                                                ) ==
                                                true) {
                                              productFeatureId = restaurantsController
                                                  .productsDetailsRestaurant?.features
                                                  ?.firstWhere((e) => e.name == 'vacuim')
                                                  .id;
                                            }
                                          },
                                        ),
                                        Text(
                                          'vacuum'.tr,
                                          style: _selectedRadio == 5
                                              ? AppTextStyle.text16MS().copyWith(color: AppColors.yellowColor)
                                              : AppTextStyle.text16MG(),
                                        ),
                                        const Spacer(),
                                        restaurantsController.productsDetailsRestaurant == null
                                            ? const SizedBox()
                                            : Text(
                                                "${(int.tryParse(restaurantsController.productsDetailsRestaurant?.extraVacuim?.toString() ?? "0") ?? 0) + (int.tryParse(restaurantsController.productsDetailsRestaurant?.productPrice.toString() ?? "0") ?? 0)}",
                                                style: _selectedRadio == 5
                                                    ? AppTextStyle.text16MS()
                                                    : AppTextStyle.text16MG(),
                                              ),
                                      ],
                                    )
                                  : const SizedBox(),
                              restaurantsController.productsDetailsRestaurant?.extraCombo != 0
                                  ? Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Radio(
                                          activeColor: AppColors.yellowColor,
                                          value: 6,
                                          groupValue: _selectedRadio,
                                          onChanged: (value) {
                                            setState(() {
                                              _selectedRadio = value!;
                                            });
                                            context.read<CartController>().totalCountAddTCart = null;
                                            if (restaurantsController.productsDetailsRestaurant?.features?.any(
                                                  (e) => e.name == 'combo',
                                                ) ==
                                                true) {
                                              productFeatureId = restaurantsController
                                                  .productsDetailsRestaurant?.features
                                                  ?.firstWhere((e) => e.name == 'combo')
                                                  .id;
                                            }
                                          },
                                        ),
                                        Text(
                                          'combo'.tr,
                                          style: _selectedRadio == 6
                                              ? AppTextStyle.text16MS().copyWith(color: AppColors.yellowColor)
                                              : AppTextStyle.text16MG(),
                                        ),
                                        const Spacer(),
                                        restaurantsController.productsDetailsRestaurant == null
                                            ? const SizedBox()
                                            : Text(
                                                "${(int.tryParse(restaurantsController.productsDetailsRestaurant?.extraCombo?.toString() ?? "0") ?? 0) + (int.tryParse(restaurantsController.productsDetailsRestaurant?.productPrice.toString() ?? "0") ?? 0)}",
                                                style: _selectedRadio == 6
                                                    ? AppTextStyle.text16MS()
                                                    : AppTextStyle.text16MG(),
                                              ),
                                      ],
                                    )
                                  : const SizedBox(),
                            ],
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
              isEmpty: restaurantsController.productsDetailsRestaurant == null,
              child: CustomButtonBottomNavigation(
                featureId: productFeatureId ?? defaultFeature,
                qty: quantity,
                onSuccessAddItems: () {
                  widget.args.onSuccessAddItem?.call();
                  context.read<CartController>().getCart();
                },
                restaurantProductId: restaurantsController.productsDetailsRestaurant?.id ?? 0,
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

  String getTotalFromSelectedRadio(RestaurantsController restaurantsController) {
    var data = restaurantsController.productsDetailsRestaurant;
    return switch (_selectedRadio) {
      0 => data?.productPrice.toString() ?? '',
      1 => '${data!.productPrice! + data.extraClean!}',
      2 => '${data!.productPrice! + data.extraClear!}',
      3 => '${data!.productPrice! + data.extraLarge!}',
      4 => '${data!.productPrice! + data.extraMedium!}',
      5 => '${data!.productPrice! + data.extraVacuim!}',
      6 => '${data!.productPrice! + data.extraCombo!}',
      _ => '',
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
