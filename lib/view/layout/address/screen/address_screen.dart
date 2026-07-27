import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../../helpers/extensions/extensions.dart';
import '../../../../helpers/images/app_images.dart';
import '../../../../helpers/routes/app_routers_import.dart';
import '../../../../helpers/theme/app_colors.dart';
import '../../../../helpers/theme/app_text_style.dart';
import '../../../../helpers/translation/all_translation.dart';
import '../../../custom_widgets/api_response_widget/api_response_widget.dart';
import '../../../custom_widgets/buttons/custom_button.dart';
import '../../../custom_widgets/page_container/page_container.dart';
import '../../auth/controller/auth_controller.dart';
import '../../my_account/account_app_bar/account_app_bar.dart';
import '../controller/address_controller.dart';
import '../widget/address_widget.dart';
import '../widget/circle_avatar_widget.dart';
import 'add_address_screen.dart';

class AddressScreen extends StatelessWidget {
  static const String routeName = 'AddressScreen';
  const AddressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (BuildContext context) {
        return AddressController()
          ..initialAddress()
          ..getAddress();
      },
      child: Consumer<AddressController>(
        builder: (context, addressController, _) {
          return Scaffold(
            extendBody: true,
            appBar: AppBar(
              backgroundColor: AppColors.whiteColor,
              centerTitle: false,
              automaticallyImplyLeading: false,
              title: CustomAccountAppBar(title: 'addresses'.tr),
            ),
            body: PageContainer(
              bottom: false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 22),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.whiteColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(34),
                      topRight: Radius.circular(34),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.greyColor.withValues(alpha: 0.2),
                        offset: const Offset(0, -3),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      24.sbH,
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                        child: Row(
                          children: [
                            CircleAvatarWidget(
                              gender: Provider.of<AuthController>(context).profile?.gender,
                              name: Provider.of<AuthController>(context).profile?.name,
                            ),
                            10.sbW,
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  Provider.of<AuthController>(context).profile?.name ?? '',
                                  style: AppTextStyle.text18MS(),
                                ),
                                5.sbH,
                                Row(
                                  children: [
                                    SvgPicture.asset(AppImages.egyptIcon),
                                    10.sbW,
                                    Text(
                                      Provider.of<AuthController>(context).profile?.areaTitle ?? '',
                                      style: AppTextStyle.text16RG(),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      20.sbH,
                      const Divider(thickness: 1),
                      24.sbH,
                      Center(
                        child: ApiResponseWidget(
                          apiResponse: addressController.addressResponse,
                          onReload: addressController.getAddress,
                          isEmpty: addressController.address.isEmpty,
                          emptyWidget: Column(
                            children: [
                              (context.height * 0.15).sbH,
                              SvgPicture.asset(AppImages.noAddressIcon),
                              20.sbH,
                              Text('noAddresses'.tr, style: AppTextStyle.text16BM()),
                              (context.height * 0.15).sbH,
                            ],
                          ),
                          child: Column(
                            children: List.generate(
                              addressController.address.length,
                              (index) => Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: Column(
                                  children: [
                                    AddressWidget(address: addressController.address[index]),
                                    20.sbH,
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      24.sbH,
                    ],
                  ),
                ),
              ),
            ),
            bottomNavigationBar: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 21, vertical: 20),
              child: CustomButton(
                onPressed: () {
                  NamedNavigatorImpl.push(
                    AddAddressScreen.routeName,
                    arguments: AddAddressArgs(
                      onSuccess: () {
                        addressController.getAddress();
                      },
                    ),
                  );
                },
                text: 'addAddress'.tr,
              ),
            ),
          );
        },
      ),
    );
  }
}
