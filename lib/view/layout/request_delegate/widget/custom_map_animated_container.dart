import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../helpers/extensions/extensions.dart';
import '../../../../helpers/images/app_images.dart';
import '../../../../helpers/routes/app_routers_import.dart';
import '../../../../helpers/theme/app_colors.dart';
import '../../../../helpers/translation/all_translation.dart';
import '../../../../helpers/utils/common_methods.dart';
import '../../../../helpers/utils/utils.dart';
import '../../../custom_widgets/custom_image/custom_image.dart';
import '../bottom_sheet/payment_rd_bottom_sheet.dart';
import '../bottom_sheet/submit_your_fee_bottom_sheet.dart';
import '../controller/request_delegate_controller.dart';
import '../screen/search_place_screen.dart';

class CustomMapAnimatedContainer extends StatelessWidget {
  const CustomMapAnimatedContainer({super.key, required this.containerHeight});

  final double? containerHeight;

  static const _textColor = Color(0xFF181C22);
  static const _mutedColor = Color(0xFF8A8F98);
  static const _borderColor = Color(0xFFE9EBEF);
  static const _cardColor = Color(0xFFFFFFFF);

  bool _isArabic(BuildContext context) => context.languageCode == 'ar';

  @override
  Widget build(BuildContext context) {
    return Consumer<RequestDelegateController>(
      builder: (context, controller, _) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          height: containerHeight ?? context.height * 0.62,
          clipBehavior: Clip.antiAlias,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0x22000000),
                blurRadius: 30,
                offset: Offset(0, -8),
              ),
            ],
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 24),
            child: Directionality(
              textDirection: _isArabic(context) ? TextDirection.rtl : TextDirection.ltr,
              child: Column(
                children: [
                  _dragHandle(),
                  const SizedBox(height: 13),
                  _header(context),
                  const SizedBox(height: 15),
                  _currentLocationCard(context, controller),
                  const SizedBox(height: 10),
                  _destinationCard(context, controller),
                  const SizedBox(height: 10),
                  _packageField(context, controller),
                  const SizedBox(height: 10),
                  _fareCard(context, controller),
                  const SizedBox(height: 10),
                  _paymentCard(context, controller),
                  const SizedBox(height: 14),
                  _summaryCard(context, controller),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _dragHandle() {
    return Container(
      width: 52,
      height: 5,
      decoration: BoxDecoration(
        color: const Color(0xFFD7D9DD),
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isArabic(context) ? 'توصيل سريع وآمن' : 'Fast & secure delivery',
                style: const TextStyle(
                  color: _textColor,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _isArabic(context)
                    ? 'خيارات مرنة تناسب احتياجاتك'
                    : 'Flexible options that fit your needs',
                style: const TextStyle(
                  color: _mutedColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 82,
          height: 70,
          child: CustomImage(
            path: AppImages.darkMotorCycle,
            type: ImageType.svg,
            fit: BoxFit.contain,
          ),
        ),
      ],
    );
  }

  Widget _currentLocationCard(
    BuildContext context,
    RequestDelegateController controller,
  ) {
    final lat = controller.fromLat;
    final lng = controller.fromLan;
    final coordinates = lat != null && lng != null && lat.isNotEmpty && lng.isNotEmpty
        ? '${_shortCoordinate(lat)}, ${_shortCoordinate(lng)}'
        : controller.fromAddress;

    return _actionCard(
      context: context,
      icon: Icons.my_location_rounded,
      iconColor: AppColors.mainAppColor,
      title: _isArabic(context) ? 'موقع التوصيل الحالي' : 'Current pickup location',
      subtitle: coordinates.isNotEmpty
          ? coordinates
          : (_isArabic(context) ? 'حدد موقع الاستلام' : 'Select pickup location'),
      trailing: Container(
        width: 11,
        height: 11,
        decoration: const BoxDecoration(
          color: Color(0xFF26C95C),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: Color(0x4426C95C), blurRadius: 7, spreadRadius: 2),
          ],
        ),
      ),
      onTap: () => _openSearchPlace(controller),
    );
  }

  Widget _destinationCard(
    BuildContext context,
    RequestDelegateController controller,
  ) {
    return _actionCard(
      context: context,
      icon: Icons.location_on_outlined,
      iconColor: AppColors.mainAppColor,
      title: _isArabic(context) ? 'التوصيل إلى' : 'Deliver to',
      subtitle: controller.toAddress.isNotEmpty
          ? controller.toAddress
          : (_isArabic(context) ? 'اختر عنوان التوصيل' : 'Choose delivery address'),
      trailing: const Icon(Icons.chevron_left_rounded, color: Color(0xFFB1B4BA), size: 24),
      onTap: () => _openSearchPlace(controller),
    );
  }

  Widget _packageField(
    BuildContext context,
    RequestDelegateController controller,
  ) {
    return Container(
      decoration: _cardDecoration(),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, color: AppColors.mainAppColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller.descriptionEC,
              minLines: 1,
              maxLines: 2,
              textInputAction: TextInputAction.done,
              textAlign: _isArabic(context) ? TextAlign.right : TextAlign.left,
              style: const TextStyle(
                color: _textColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                isDense: true,
                hintText: _isArabic(context) ? 'الغرض المطلوب توصيله' : 'Item to be delivered',
                hintStyle: const TextStyle(
                  color: _textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                helperText: _isArabic(context)
                    ? 'اكتب وصف الغرض أو تفاصيله'
                    : 'Describe the item or its details',
                helperMaxLines: 1,
                helperStyle: const TextStyle(
                  color: _mutedColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.description_outlined, color: Color(0xFFB1B4BA), size: 22),
        ],
      ),
    );
  }

  Widget _fareCard(
    BuildContext context,
    RequestDelegateController controller,
  ) {
    final hasFare = controller.priceEC.text.trim().isNotEmpty;
    final fareValue = hasFare
        ? '${controller.priceEC.text.trim()} ${_isArabic(context) ? 'ج' : 'EGP'}'
        : (_isArabic(context) ? 'حدد الأجرة التي تريد دفعها' : 'Set the fare you want to pay');

    return _actionCard(
      context: context,
      icon: Icons.payments_outlined,
      iconColor: AppColors.mainAppColor,
      title: _isArabic(context) ? 'قدم أجرتك' : 'Offer your fare',
      subtitle: fareValue,
      highlight: hasFare,
      trailing: const Icon(Icons.chevron_left_rounded, color: Color(0xFFB1B4BA), size: 24),
      onTap: () => _openFareSheet(context, controller),
    );
  }

  Widget _paymentCard(
    BuildContext context,
    RequestDelegateController controller,
  ) {
    final payment = switch (controller.selectedPayment) {
      'wallet' => _isArabic(context) ? 'المحفظة' : 'Wallet',
      'cash' => _isArabic(context) ? 'نقدًا' : 'Cash',
      _ => _isArabic(context) ? 'طريقة الدفع المختارة' : 'Selected payment method',
    };

    return _actionCard(
      context: context,
      icon: Icons.account_balance_wallet_outlined,
      iconColor: AppColors.mainAppColor,
      title: _isArabic(context) ? 'الدفع' : 'Payment',
      subtitle: payment,
      trailing: const Icon(Icons.chevron_left_rounded, color: Color(0xFFB1B4BA), size: 24),
      onTap: () {
        Utils.showAppBottomSheet(
          ChangeNotifierProvider.value(
            value: controller,
            child: PaymentRDBottomSheet(requestDelegateController: controller),
          ),
        );
      },
    );
  }

  Widget _summaryCard(
    BuildContext context,
    RequestDelegateController controller,
  ) {
    final fare = controller.priceEC.text.trim().isEmpty
        ? '—'
        : '${controller.priceEC.text.trim()} ${_isArabic(context) ? 'ج' : 'EGP'}';

    return Container(
      decoration: _cardDecoration(),
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: _summaryItem(
              icon: Icons.shield_outlined,
              label: _isArabic(context) ? 'دفع آمن' : 'Secure',
              value: '100%',
            ),
          ),
          _divider(),
          Expanded(
            child: _summaryItem(
              icon: Icons.account_balance_wallet_outlined,
              label: _isArabic(context) ? 'الأجرة' : 'Fare',
              value: fare,
            ),
          ),
          _divider(),
          Expanded(
            child: _summaryItem(
              icon: Icons.schedule_rounded,
              label: _isArabic(context) ? 'وقت التوصيل المتوقع' : 'ETA',
              value: _isArabic(context) ? '20 - 30 د' : '20 - 30 min',
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: const Color(0xFF868A91), size: 22),
        const SizedBox(height: 6),
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: _textColor,
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: AppColors.mainAppColor,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _divider() {
    return Container(
      width: 1,
      height: 55,
      color: const Color(0xFFE5E7EA),
    );
  }

  Widget _actionCard({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required Widget trailing,
    required VoidCallback onTap,
    bool highlight = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 70),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: _cardDecoration(highlight: highlight),
          child: Row(
            children: [
              Icon(icon, color: iconColor, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _textColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: highlight ? AppColors.mainAppColor : _mutedColor,
                        fontSize: 12,
                        fontWeight: highlight ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              trailing,
            ],
          ),
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration({bool highlight = false}) {
    return BoxDecoration(
      color: _cardColor,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(
        color: highlight ? AppColors.mainAppColor : _borderColor,
        width: highlight ? 1.2 : 1,
      ),
      boxShadow: const [
        BoxShadow(
          color: Color(0x10000000),
          blurRadius: 14,
          offset: Offset(0, 5),
        ),
      ],
    );
  }

  String _shortCoordinate(String value) {
    final number = double.tryParse(value);
    return number?.toStringAsFixed(5) ?? value;
  }

  void _openSearchPlace(RequestDelegateController controller) {
    NamedNavigatorImpl.push(SearchPlaceScreen.routeName);
    if (controller.fromAddress.isNotEmpty) {
      controller.setFromController(controller.fromAddress);
    }
    if (controller.fromLat != null && controller.fromLat!.isNotEmpty) {
      controller.setFromLat(controller.fromLat!);
    }
    if (controller.fromLan != null && controller.fromLan!.isNotEmpty) {
      controller.setFromLan(controller.fromLan!);
    }
  }

  void _openFareSheet(
    BuildContext context,
    RequestDelegateController controller,
  ) {
    if (controller.toLat != null &&
        controller.toLan != null &&
        controller.fromLat != null &&
        controller.fromLan != null) {
      Utils.showAppBottomSheet(
        ChangeNotifierProvider.value(
          value: controller,
          child: SubmitYourFeeBottomSheet(
            requestDelegateController: controller,
            kmPrice: int.tryParse('${controller.delegatesOnMap?.shippingKmPrice}') ?? 0,
            shippingPercentage: int.tryParse(
                  '${controller.delegatesOnMap?.shippingMinPricePrecentage}',
                ) ??
                0,
            distance: num.tryParse('${controller.distance}') ?? 0,
          ),
        ),
      );
    } else {
      CommonMethods.showError(message: 'chooseDeliveryLocationsFirst'.tr);
    }
  }
}
