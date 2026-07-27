import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../../helpers/extensions/extensions.dart';
import '../../../../helpers/hive/hive_methods.dart';
import '../../../../helpers/images/app_images.dart';
import '../../../../helpers/routes/app_routers_import.dart';
import '../../../../helpers/theme/app_colors.dart';
import '../../../../helpers/theme/app_text_style.dart';
import '../../../../helpers/translation/all_translation.dart';
import '../../../../helpers/utils/common_methods.dart';
import '../../../../helpers/utils/utils.dart';
import '../../../custom_widgets/buttons/custom_button.dart';
import '../../../custom_widgets/custom_image/custom_image.dart';
import '../../../custom_widgets/page_container/page_container.dart';
import '../../address/screen/address_screen.dart';
import '../../auth/bottom_sheet/change_lang_bottom_sheet.dart';
import '../../auth/controller/auth_controller.dart';
import '../../auth/screen/login_screen.dart';
import '../../favorite/screen/favorite_screen.dart';
import '../../request_delegate/screen/delegats_orders_screen.dart';
import '../../vendor_and_delivery_register/screen/register_as_delivery.dart';
import '../../vendor_and_delivery_register/screen/register_as_vendor.dart';
import '../../vendor_and_delivery_register/screen/widgets/delete_account_btn.dart';
import '../../wallet/screen/wallet_screen.dart';
import '../bottom_sheet/change_password_bottom_sheet.dart';
import '../widgets/change_phone_number_bottom_sheet.dart';
import '../widgets/setting_button_widget.dart';
import 'contact_us_screen.dart';
import 'personal_information_screen.dart';
import 'privacy_policy_screen.dart';
import 'terms_and_conditions_screen.dart';

class MyAccountScreen extends StatelessWidget {
  const MyAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: PageContainer(
        // bottom: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              35.sbH,
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Text('settings'.tr, style: AppTextStyle.text18BS()),
              ),
              22.sbH,
              Container(
                width: context.width,
                decoration: BoxDecoration(
                  color: AppColors.whiteColor,
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(34), topRight: Radius.circular(34)),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.greyColor.withValues(alpha: 0.2),
                      offset: const Offset(0, -3),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    if (HiveMethods.getToken() != null) ...[
                      26.sbH,
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            if (Provider.of<AuthController>(context).profile?.gender == 'male')
                              SvgPicture.asset(AppImages.avatarMale)
                            else if (Provider.of<AuthController>(context).profile?.gender == 'female')
                              SvgPicture.asset(AppImages.avatarFemale)
                            else
                              Container(
                                height: 56,
                                width: 56,
                                decoration: BoxDecoration(color: AppColors.mainAppColor, shape: BoxShape.circle),
                                child: Center(
                                  child: Text(
                                    Provider.of<AuthController>(context).profile?.name?.substring(0, 1) ?? '',
                                    style: AppTextStyle.text18BW().copyWith(fontSize: 40),
                                  ),
                                ),
                              ),
                            20.sbW,
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  Provider.of<AuthController>(context).profile?.name ?? '',
                                  style: AppTextStyle.text18BS(),
                                ),
                                10.sbH,
                                Row(
                                  children: [
                                    const CustomImage(path: AppImages.egyptIcon, type: ImageType.svg),
                                    8.sbW,
                                    Text(
                                      Provider.of<AuthController>(context).profile?.areaTitle ?? '',
                                      style: AppTextStyle.text18RS(),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      29.sbH,
                      Divider(color: AppColors.greyColor.withValues(alpha: 0.2), height: 2),
                      32.sbH,
                      SettingButton(
                        title: 'personalInformation'.tr,
                        onTap: () => NamedNavigatorImpl.push(PersonalInformationScreen.routeName),
                      ),
                      32.sbH,
                      SettingButton(
                        title: 'changePhoneNumber'.tr,
                        onTap: () {
                          Utils.showAppBottomSheet(
                            enableDrag: true,
                            isScrollControlled: true,
                            const ChangePhoneNumberBottomSheet(),
                          );
                        },
                      ),
                      32.sbH,
                      SettingButton(
                        title: 'theWallet'.tr,
                        onTap: () {
                          NamedNavigatorImpl.push(WalletScreen.routeName);
                        },
                      ),
                      32.sbH,
                      SettingButton(
                        title: 'delegatesOrders'.tr,
                        onTap: () {
                          NamedNavigatorImpl.push(DelegateOrdersScreen.routeName);
                        },
                      ),
                      32.sbH,
                      SettingButton(
                        title: 'addresses'.tr,
                        onTap: () {
                          NamedNavigatorImpl.push(AddressScreen.routeName);
                        },
                      ),
                      32.sbH,
                      SettingButton(
                        title: 'favorite'.tr,
                        onTap: () {
                          NamedNavigatorImpl.push(FavoriteScreen.routeName);
                        },
                      ),
                      32.sbH,
                    ],
                    if (HiveMethods.getToken() == null) ...[SizedBox(height: context.height / 12)],
                    SettingButton(
                      title: 'changeTheLanguage'.tr,
                      onTap: () => Utils.showAppBottomSheet(const ChangeLangBottomSheet()),
                    ),
                    32.sbH,
                    SettingButton(
                      title: 'termsAndConditions'.tr,
                      onTap: () => NamedNavigatorImpl.push(TermsAndConditionsScreen.routeName),
                    ),
                    32.sbH,
                    SettingButton(
                      title: 'privacyPolicy'.tr,
                      onTap: () => NamedNavigatorImpl.push(PrivacyPolicyScreen.routeName),
                    ),
                    32.sbH,
                    SettingButton(
                      title: 'contactUs'.tr,
                      onTap: () => NamedNavigatorImpl.push(ContactUsScreen.routeName),
                    ),
                    if (HiveMethods.getToken() != null) ...[
                      32.sbH,
                      SettingButton(
                        title: 'changePassword'.tr,
                        onTap: () =>
                            Utils.showAppBottomSheet(isScrollControlled: true, const ChangePasswordBottomSheet()),
                      ),
                      32.sbH,
                      const DeleteAccountBtn(),
                    ],
                    50.sbH,
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 21),
                      child: InkWell(
                        onTap: () => NamedNavigatorImpl.push(RegisterAsDeliveryScreen.routeName),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SvgPicture.asset(AppImages.delegateIcon),
                            15.sbW,
                            Text('registerAsADelegate'.tr, style: AppTextStyle.text16BS()),
                          ],
                        ),
                      ),
                    ),
                    24.sbH,
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 21),
                      child: InkWell(
                        onTap: () => NamedNavigatorImpl.push(RegisterAsVendorScreen.routeName),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SvgPicture.asset(AppImages.merchantIcon),
                            15.sbW,
                            Text('registerAsAMerchant'.tr, style: AppTextStyle.text16BS()),
                          ],
                        ),
                      ),
                    ),
                    31.sbH,
                    if (HiveMethods.getToken() != null) ...[
                      GestureDetector(
                        onTap: () {
                          CommonMethods.showChooseDialog(
                            context,
                            title: 'doYouWantToLogout'.tr,
                            message: '',
                            onPressed: () {
                              if (HiveMethods.getToken() != null) {
                                context.read<AuthController>().logout();
                              } else {
                                NamedNavigatorImpl.push(clean: true, LoginScreen.routeName);
                              }
                            },
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 41),
                          child: CustomButton(
                            text: 'logOut'.tr,
                            prefixIcon: SvgPicture.asset(
                              AppImages.logoutIcon,
                              colorFilter: ColorFilter.mode(AppColors.whiteColor, BlendMode.srcIn),
                            ),
                          ),
                        ),
                      ),
                    ],
                    if (HiveMethods.getToken() == null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 41),
                        child: CustomButton(
                          text: 'signIn'.tr,
                          onPressed: () => NamedNavigatorImpl.push(clean: true, LoginScreen.routeName),
                        ),
                      ),
                    50.sbH,
                    if (HiveMethods.getToken() == null) SizedBox(height: context.height / 4),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
