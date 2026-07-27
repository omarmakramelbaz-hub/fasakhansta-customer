import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../helpers/extensions/extensions.dart';
import '../../../../helpers/images/app_images.dart';
import '../../../../helpers/routes/app_routers_import.dart';
import '../../../../helpers/theme/app_colors.dart';
import '../../../../helpers/theme/app_text_style.dart';
import '../../../../helpers/translation/all_translation.dart';
import '../../../../helpers/utils/common_methods.dart';
import '../../../custom_widgets/api_response_widget/api_response_widget.dart';
import '../../../custom_widgets/buttons/custom_button.dart';
import '../../../custom_widgets/custom_app_bar/custom_app_bar.dart';
import '../../../custom_widgets/custom_image/custom_image.dart';
import '../../address/controller/address_controller.dart';
import '../../address/screen/update_address_screen.dart';
import '../../auth/controller/auth_controller.dart';
import '../widgets/no_delevery_location_widget.dart';
import 'execute_the_order_screen.dart';

class ChooseAddressFromMapScreenArgs {
  final List<int> areaId;
  final int resturantId;

  ChooseAddressFromMapScreenArgs({required this.areaId, required this.resturantId});
}

class ChooseAddressFromMapScreen extends StatefulWidget {
  static const String routeName = 'ChooseAddressFromMap';
  final ChooseAddressFromMapScreenArgs args;
  const ChooseAddressFromMapScreen({super.key, required this.args});

  @override
  State<ChooseAddressFromMapScreen> createState() => _ChooseAddressFromMapScreenState();
}

class _ChooseAddressFromMapScreenState extends State<ChooseAddressFromMapScreen> {
  int? selectedAddressId;
  String? selectedAddressLat;
  String? selectedAddressLang;
  int selectedAddressIndex = 0;

  @override
  Widget build(BuildContext context) {
    log(widget.args.areaId.toString());
    return ChangeNotifierProvider(
      create: (context) => AddressController()
        ..initialAddress()
        ..getAddress(areaId: widget.args.areaId),
      child: Consumer<AddressController>(
        builder: (context, addressController, _) {
          if (selectedAddressId == null && addressController.address.isNotEmpty) {
            selectedAddressId = addressController.address[0].id;
            selectedAddressLat = addressController.address[0].lat;
            selectedAddressLang = addressController.address[0].lng;
            selectedAddressIndex = 0;
          }
          return Scaffold(
            appBar: CustomAppBar(
              actions: const [],
              height: 90,
              radius: 60,
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios, color: AppColors.blackColor),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              title: Text('deliveryLocations'.tr, style: AppTextStyle.text16MS()),
            ),
            body: ApiResponseWidget(
              apiResponse: addressController.addressResponse,
              onReload: () => addressController.getAddress(areaId: widget.args.areaId),
              isEmpty: addressController.address.isEmpty,
              emptyWidget: NoDeliveryLocationWidget(addressController: addressController),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    20.sbH,
                    if (addressController.address.isNotEmpty)
                      ...List.generate(addressController.address.length, (index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                selectedAddressIndex = index;
                                selectedAddressId = addressController.address[index].id;
                                selectedAddressLat = addressController.address[index].lat;

                                selectedAddressLang = addressController.address[index].lng;
                              });
                            },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: AppColors.whiteColor,
                                border: Border.all(
                                  color: selectedAddressIndex == index ? AppColors.mainAppColor : Colors.transparent,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.greyColor.withValues(alpha: 0.2),
                                    offset: const Offset(0, -3),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            const CustomImage(path: AppImages.addressIcon, type: ImageType.svg),
                                            const SizedBox(width: 10),
                                            Text('area'.tr, style: AppTextStyle.text14MG()),
                                          ],
                                        ),
                                        10.sbH,
                                        Text(
                                          "${addressController.address[index].countryName ?? ''} - ${addressController.address[index].cityName ?? ''} - ${addressController.address[index].streetName ?? ''}",
                                          style: AppTextStyle.text14RS(),
                                        ),
                                      ],
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      NamedNavigatorImpl.push(
                                        UpdateAddressScreen.routeName,
                                        arguments: UpdateAddressScreenArgs(
                                          id: addressController.address[index].id ?? 0,
                                          areaName: addressController.address[index].areaName ?? '',
                                          apartmentNo: addressController.address[index].apartmentNo ?? '',
                                          floorNo: addressController.address[index].floorNo ?? '',
                                          streetName: addressController.address[index].streetName ?? '',
                                          mobile: addressController.address[index].mobile ?? '',
                                          badge: addressController.address[index].badge ?? '',
                                          addressName: addressController.address[index].addressName ?? '',
                                          type: addressController.address[index].type ?? '',
                                          lat: addressController.address[index].lat ?? '',
                                          lng: addressController.address[index].lng ?? '',
                                          onSuccess: () {
                                            Provider.of<AddressController>(
                                              context,
                                              listen: false,
                                            ).getAddress(areaId: widget.args.areaId);
                                          },
                                          userAddressId: context.read<AuthController>().profile?.id ?? 0,
                                        ),
                                      );
                                    },
                                    child: Text(
                                      'edit'.tr,
                                      style: AppTextStyle.text14MM().copyWith(decoration: TextDecoration.underline),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    SizedBox(height: context.height * 0.1),
                  ],
                ),
              ),
            ),
            bottomNavigationBar: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              decoration: BoxDecoration(
                color: AppColors.whiteColor,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.greyColor.withValues(alpha: 0.2),
                    offset: const Offset(0, 0),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: CustomButton(
                onPressed: () {
                  if (selectedAddressId == null) {
                    CommonMethods.showError(message: 'mustChooseAccount'.tr);
                  } else {
                    addressController.canDeliver(
                      restaurantId: widget.args.resturantId,
                      customerLat: selectedAddressLat!,
                      customerLng: selectedAddressLang!,
                      onSuccess: () {
                        NamedNavigatorImpl.push(
                          ExecuteTheOrderScreen.routeName,
                          arguments: ExecuteTheOrderArgs(userAddressId: selectedAddressId),
                        );
                      },
                    );
                  }
                },
                text: 'confirm'.tr,
              ),
            ),
          );
        },
      ),
    );
  }
}
