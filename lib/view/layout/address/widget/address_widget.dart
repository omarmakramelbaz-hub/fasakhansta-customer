import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../../helpers/extensions/extensions.dart';
import '../../../../helpers/images/app_images.dart';
import '../../../../helpers/routes/app_routers_import.dart';
import '../../../../helpers/theme/app_colors.dart';
import '../../../../helpers/theme/app_text_style.dart';
import '../../../../helpers/translation/all_translation.dart';
import '../../../../helpers/utils/common_methods.dart';
import '../../auth/controller/auth_controller.dart';
import '../controller/address_controller.dart';
import '../model/address_model.dart';
import '../screen/update_address_screen.dart';

class AddressWidget extends StatelessWidget {
  final AddressModel address;
  const AddressWidget({super.key, required this.address});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: AppColors.whiteColor,
          boxShadow: [
            BoxShadow(color: AppColors.greyColor.withValues(alpha: 0.2), offset: const Offset(0, -3), blurRadius: 10),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SvgPicture.asset(AppImages.addressIcon, width: 16),
                      const SizedBox(width: 10),
                      Text('area'.tr, style: AppTextStyle.text14MG()),
                      const Spacer(),
                    ],
                  ),
                  5.sbH,
                  Padding(
                    padding: const EdgeInsets.only(left: 10, right: 22),
                    child: Text(
                      "${address.countryName ?? ""} \t-\t ${address.cityName ?? ""} \t-\t ${address.streetName ?? ""}",
                      style: AppTextStyle.text14RG(),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                TextButton(
                  onPressed: () {
                    {
                      NamedNavigatorImpl.push(
                        UpdateAddressScreen.routeName,
                        arguments: UpdateAddressScreenArgs(
                          id: address.id ?? 0,
                          areaName: address.areaName ?? '',
                          apartmentNo: address.apartmentNo ?? '',
                          floorNo: address.floorNo ?? '',
                          streetName: address.streetName ?? '',
                          mobile: address.mobile ?? '',
                          badge: address.badge ?? '',
                          addressName: address.addressName ?? '',
                          type: address.type ?? '',
                          lat: address.lat ?? '',
                          lng: address.lng ?? '',
                          onSuccess: () {
                            Provider.of<AddressController>(context, listen: false).getAddress();
                          },
                          userAddressId: context.read<AuthController>().profile?.id ?? 0,
                        ),
                      );
                    }
                  },
                  child: Text(
                    'edit'.tr,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.mainAppColor,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    CommonMethods.showChooseDialog(
                      context,
                      message: 'wantToDeleteThisAddress'.tr,
                      onPressed: () {
                        Navigator.pop(context);
                        Provider.of<AddressController>(context, listen: false).deleteAddress(
                          id: address.id!,
                          onSuccess: () {
                            context.read<AuthController>().getProfile();
                          },
                        );
                      },
                    );
                  },
                  child: Text('delete'.tr),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
