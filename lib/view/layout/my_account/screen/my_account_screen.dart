import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../helpers/extensions/extensions.dart';
import '../../../../helpers/hive/hive_methods.dart';
import '../../../../helpers/routes/app_routers_import.dart';
import '../../../../helpers/theme/app_colors.dart';
import '../../../../helpers/theme/app_text_style.dart';
import '../../../../helpers/translation/all_translation.dart';
import '../../../../helpers/utils/common_methods.dart';
import '../../../../helpers/utils/utils.dart';
import '../../../custom_widgets/custom_image/custom_network_image.dart';
import '../../address/screen/address_screen.dart';
import '../../auth/bottom_sheet/change_lang_bottom_sheet.dart';
import '../../auth/controller/auth_controller.dart';
import '../../auth/screen/login_screen.dart';
import '../../favorite/screen/favorite_screen.dart';
import '../../orders/controller/orders_controller.dart';
import '../../vendor_and_delivery_register/screen/register_as_delivery.dart';
import '../../vendor_and_delivery_register/screen/register_as_vendor.dart';
import '../../vendor_and_delivery_register/screen/widgets/delete_account_btn.dart';
import '../../wallet/screen/wallet_screen.dart';
import '../bottom_navigation/controller/bottom_nav_controller.dart';
import '../bottom_sheet/change_password_bottom_sheet.dart';
import '../widgets/change_phone_number_bottom_sheet.dart';
import 'contact_us_screen.dart';
import 'personal_information_screen.dart';
import 'privacy_policy_screen.dart';
import 'terms_and_conditions_screen.dart';

class MyAccountScreen extends StatelessWidget {
  const MyAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final profile = auth.profile;
    final loggedIn = HiveMethods.getToken() != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
          child: Column(
            children: [
              _header(context),
              const SizedBox(height: 18),
              if (loggedIn) ...[
                _profileCard(context, profile),
                const SizedBox(height: 14),
                _statsCard(context, profile),
                const SizedBox(height: 14),
                _menuCard(context, [
                  _MenuItem(Icons.shopping_bag_outlined, 'orders'.tr, 'orders'.tr, () => _goToOrders(context)),
                  _MenuItem(Icons.location_on_outlined, 'addresses'.tr, 'addresses'.tr, () => NamedNavigatorImpl.push(AddressScreen.routeName)),
                  _MenuItem(Icons.credit_card_outlined, 'theWallet'.tr, 'theWallet'.tr, () => NamedNavigatorImpl.push(WalletScreen.routeName)),
                  _MenuItem(Icons.favorite_border_rounded, 'favorite'.tr, 'favorite'.tr, () => NamedNavigatorImpl.push(FavoriteScreen.routeName)),
                ]),
                const SizedBox(height: 14),
              ],
              _menuCard(context, [
                _MenuItem(Icons.language_rounded, 'changeTheLanguage'.tr, 'changeTheLanguage'.tr, () => Utils.showAppBottomSheet(const ChangeLangBottomSheet())),
                _MenuItem(Icons.headset_mic_outlined, 'contactUs'.tr, 'contactUs'.tr, () => NamedNavigatorImpl.push(ContactUsScreen.routeName)),
                _MenuItem(Icons.verified_user_outlined, 'privacyPolicy'.tr, 'privacyPolicy'.tr, () => NamedNavigatorImpl.push(PrivacyPolicyScreen.routeName)),
                _MenuItem(Icons.description_outlined, 'termsAndConditions'.tr, 'termsAndConditions'.tr, () => NamedNavigatorImpl.push(TermsAndConditionsScreen.routeName)),
              ]),
              if (loggedIn) ...[
                const SizedBox(height: 14),
                _menuCard(context, [
                  _MenuItem(Icons.person_outline_rounded, 'personalInformation'.tr, 'personalInformation'.tr, () => NamedNavigatorImpl.push(PersonalInformationScreen.routeName)),
                  _MenuItem(Icons.phone_outlined, 'changePhoneNumber'.tr, 'changePhoneNumber'.tr, () => Utils.showAppBottomSheet(enableDrag: true, isScrollControlled: true, const ChangePhoneNumberBottomSheet())),
                  _MenuItem(Icons.lock_outline_rounded, 'changePassword'.tr, 'changePassword'.tr, () => Utils.showAppBottomSheet(isScrollControlled: true, const ChangePasswordBottomSheet())),
                  _MenuItem(Icons.logout_rounded, 'logOut'.tr, 'logOut'.tr, () => _logout(context), destructive: true),
                ]),
                const SizedBox(height: 10),
                const DeleteAccountBtn(),
              ],
              if (!loggedIn) ...[
                const SizedBox(height: 18),
                _loginCard(context),
              ],
              const SizedBox(height: 22),
              _extraActions(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Row(
      children: [
        _roundIcon(Icons.settings_outlined, () => Utils.showAppBottomSheet(const ChangeLangBottomSheet())),
        const Spacer(),
        Text('account'.tr, style: AppTextStyle.text24BS()),
        const Spacer(),
        _roundIcon(Icons.notifications_none_rounded, () {
          context.read<BottomNavigationController>().updateIndex(2);
        }, badge: context.read<AuthController>().profile?.notificaionsCount),
      ],
    );
  }

  Widget _roundIcon(IconData icon, VoidCallback onTap, {int? badge}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.borderColor.withValues(alpha: .55)),
            ),
            child: Icon(icon, color: AppColors.mainAppColor, size: 25),
          ),
          if (badge != null && badge > 0)
            Positioned(
              right: -3,
              top: -4,
              child: Container(
                constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                padding: const EdgeInsets.symmetric(horizontal: 5),
                decoration: const BoxDecoration(color: Color(0xFFF45116), shape: BoxShape.circle),
                child: Center(child: Text('$badge', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700))),
              ),
            ),
        ],
      ),
    );
  }

  Widget _profileCard(BuildContext context, dynamic profile) {
    final name = profile?.name ?? '';
    final mobile = profile?.mobile ?? '';
    final photo = profile?.photoProfile?.toString() ?? '';
    final area = profile?.areaTitle ?? profile?.cityName ?? '';
    final balance = profile?.balance ?? 0;

    return InkWell(
      onTap: () => NamedNavigatorImpl.push(PersonalInformationScreen.routeName),
      borderRadius: BorderRadius.circular(28),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFFFE8D5), Color(0xFFFFF4EA)]),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.mainAppColor.withValues(alpha: .10)),
        ),
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                ClipOval(
                  child: photo.isNotEmpty
                      ? CustomNetworkImage(imageUrl: photo, width: 86, height: 86, fit: BoxFit.cover, radius: 43)
                      : Container(width: 86, height: 86, color: Colors.white, child: Icon(Icons.person_rounded, size: 50, color: AppColors.mainAppColor)),
                ),
                Positioned(
                  bottom: -2,
                  right: -2,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: Icon(Icons.camera_alt_outlined, size: 17, color: AppColors.mainAppColor),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name.isEmpty ? 'account'.tr : name, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTextStyle.text20BS()),
                  const SizedBox(height: 5),
                  Text(mobile, style: AppTextStyle.text13RG()),
                  const SizedBox(height: 10),
                  Row(children: [Icon(Icons.location_on_outlined, size: 16, color: AppColors.mainAppColor), const SizedBox(width: 4), Expanded(child: Text(area, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTextStyle.text12RG()))]),
                  const SizedBox(height: 10),
                  Text('balance'.tr, style: AppTextStyle.text11RG()),
                  const SizedBox(height: 2),
                  Text('${balance ?? 0} ${'pound'.tr.replaceAll('{}', '').trim()}', style: AppTextStyle.text16BS().copyWith(color: AppColors.mainAppColor)),
                ],
              ),
            ),
            const Icon(Icons.chevron_left_rounded, size: 28),
          ],
        ),
      ),
    );
  }

  Widget _statsCard(BuildContext context, dynamic profile) {
    final addressCount = profile?.userAddresses?.length ?? 0;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: AppColors.borderColor.withValues(alpha: .55))),
      child: Row(
        children: [
          Expanded(child: _stat(Icons.account_balance_wallet_outlined, 'theWallet'.tr, '${profile?.balance ?? 0}', () => NamedNavigatorImpl.push(WalletScreen.routeName))),
          Container(width: 1, height: 54, color: AppColors.borderColor.withValues(alpha: .45)),
          Expanded(child: _stat(Icons.location_on_outlined, 'addresses'.tr, '$addressCount', () => NamedNavigatorImpl.push(AddressScreen.routeName))),
        ],
      ),
    );
  }

  Widget _stat(IconData icon, String title, String value, VoidCallback onTap) {
    return InkWell(onTap: onTap, child: Row(children: [const SizedBox(width: 16), Container(width: 48, height: 48, decoration: BoxDecoration(color: const Color(0xFFFFF4EA), borderRadius: BorderRadius.circular(16)), child: Icon(icon, color: AppColors.mainAppColor, size: 25)), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTextStyle.text12RG()), const SizedBox(height: 3), Text(value, style: AppTextStyle.text18BS().copyWith(color: AppColors.mainAppColor))])), const SizedBox(width: 8), const Icon(Icons.chevron_left_rounded, size: 22), const SizedBox(width: 12)]));
  }

  Widget _menuCard(BuildContext context, List<_MenuItem> items) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: AppColors.borderColor.withValues(alpha: .55))),
      child: Column(children: List.generate(items.length, (index) {
        final item = items[index];
        return Column(children: [
          InkWell(
            onTap: item.onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              child: Row(children: [
                Container(width: 44, height: 44, decoration: BoxDecoration(color: item.destructive ? const Color(0xFFFFF0F0) : const Color(0xFFFFF5EC), borderRadius: BorderRadius.circular(15)), child: Icon(item.icon, color: item.destructive ? Colors.red : AppColors.mainAppColor, size: 23)),
                const SizedBox(width: 12),
                Expanded(child: Text(item.title, style: AppTextStyle.text15BS().copyWith(color: item.destructive ? Colors.red : null))),
                Icon(context.languageCode == 'en' ? Icons.chevron_right_rounded : Icons.chevron_left_rounded, size: 25, color: item.destructive ? Colors.red : AppColors.greyColor),
              ]),
            ),
          ),
          if (index != items.length - 1) Divider(height: 1, indent: 70, endIndent: 14, color: AppColors.borderColor.withValues(alpha: .45)),
        ]);
      })),
    );
  }

  Widget _loginCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: AppColors.borderColor.withValues(alpha: .55))),
      child: Column(children: [Icon(Icons.person_outline_rounded, size: 48, color: AppColors.mainAppColor), const SizedBox(height: 8), Text('youMustLoginFirst'.tr, textAlign: TextAlign.center, style: AppTextStyle.text15BS()), const SizedBox(height: 14), SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => NamedNavigatorImpl.push(clean: true, LoginScreen.routeName), style: ElevatedButton.styleFrom(backgroundColor: AppColors.mainAppColor, foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), padding: const EdgeInsets.symmetric(vertical: 14)), child: Text('signIn'.tr, style: AppTextStyle.text15BS().copyWith(color: Colors.white))))]),
    );
  }

  Widget _extraActions(BuildContext context) {
    return Column(children: [
      InkWell(onTap: () => NamedNavigatorImpl.push(RegisterAsDeliveryScreen.routeName), child: Padding(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8), child: Row(children: [Icon(Icons.delivery_dining_rounded, color: AppColors.mainAppColor), const SizedBox(width: 12), Expanded(child: Text('registerAsADelegate'.tr, style: AppTextStyle.text14BS())), const Icon(Icons.chevron_left_rounded)]))),
      const SizedBox(height: 4),
      InkWell(onTap: () => NamedNavigatorImpl.push(RegisterAsVendorScreen.routeName), child: Padding(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8), child: Row(children: [Icon(Icons.storefront_outlined, color: AppColors.mainAppColor), const SizedBox(width: 12), Expanded(child: Text('registerAsAMerchant'.tr, style: AppTextStyle.text14BS())), const Icon(Icons.chevron_left_rounded)]))),
    ]);
  }

  void _goToOrders(BuildContext context) {
    context.read<BottomNavigationController>().updateIndex(1);
  }

  void _logout(BuildContext context) {
    CommonMethods.showChooseDialog(
      context,
      title: 'doYouWantToLogout'.tr,
      message: '',
      onPressed: () => context.read<AuthController>().logout(),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool destructive;

  const _MenuItem(this.icon, this.title, this.subtitle, this.onTap, {this.destructive = false});
}
