import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../helpers/extensions/extensions.dart';
import '../../../../helpers/images/app_images.dart';
import '../../../../helpers/routes/app_routers_import.dart';
import '../../../../helpers/theme/app_colors.dart';
import '../../../../helpers/translation/all_translation.dart';
import '../../../../helpers/utils/common_methods.dart';
import '../../../../helpers/utils/utils.dart';
import '../bottom_sheet/payment_rd_bottom_sheet.dart';
import '../bottom_sheet/submit_your_fee_bottom_sheet.dart';
import '../controller/request_delegate_controller.dart';
import '../screen/search_place_screen.dart';

class CustomMapAnimatedContainer extends StatelessWidget {
  const CustomMapAnimatedContainer({super.key, required this.containerHeight});

  final double? containerHeight;

  static const _textColor = Color(0xFF171A1F);
  static const _mutedColor = Color(0xFF888E97);
  static const _borderColor = Color(0xFFE8EBEF);
  static const _softOrange = Color(0xFFFFF6EC);

  bool _isArabic(BuildContext context) => context.languageCode == 'ar';

  @override
  Widget build(BuildContext context) {
    return Consumer<RequestDelegateController>(
      builder: (context, controller, _) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          height: containerHeight ?? context.height * 0.64,
          clipBehavior: Clip.antiAlias,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(34),
              topRight: Radius.circular(34),
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0x20000000),
                blurRadius: 28,
                offset: Offset(0, -8),
              ),
            ],
          ),
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
            child: Directionality(
              textDirection: _isArabic(context) ? TextDirection.rtl : TextDirection.ltr,
              child: Column(
                children: [
                  _dragHandle(),
                  const SizedBox(height: 14),
                  _header(context),
                  const SizedBox(height: 16),
                  _currentLocationCard(context, controller),
                  const SizedBox(height: 10),
                  _destinationCard(context, controller),
                  const SizedBox(height: 10),
                  _packageCard(context, controller),
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
      width: 50,
      height: 5,
      decoration: BoxDecoration(
        color: const Color(0xFFD7DADF),
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(4, 2, 4, 2),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isArabic(context) ? 'توصيل سريع وآمن' : 'Fast & secure delivery',
                  style: const TextStyle(
                    color: _textColor,
                    fontSize: 25,
                    fontWeight: FontWeight.w800,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _isArabic(context)
                      ? 'حدد تفاصيل طلبك واختر ما يناسبك'
                      : 'Set your order details and choose what suits you',
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
          Container(
            width: 86,
            height: 72,
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: _softOrange,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Image.asset(
              AppImages.gooDriveImage,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
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
      title: _isArabic(context) ? 'موقع التوصيل الحالي' : 'Current pickup location',
      subtitle: coordinates.isNotEmpty
          ? coordinates
          : (_isArabic(context) ? 'حدد موقع الاستلام' : 'Select pickup location'),
      trailing: Container(
        width: 12,
        height: 12,
        decoration: const BoxDecoration(
          color: Color(0xFF25C862),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: Color(0x4425C862), blurRadius: 7, spreadRadius: 2),
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
      title: _isArabic(context) ? 'التوصيل إلى' : 'Deliver to',
      subtitle: controller.toAddress.isNotEmpty
          ? controller.toAddress
          : (_isArabic(context) ? 'اختر عنوان التوصيل' : 'Choose delivery address'),
      trailing: const Icon(Icons.chevron_left_rounded, color: Color(0xFFB3B7BD), size: 24),
      onTap: () => _openSearchPlace(controller),
    );
  }

  Widget _packageCard(
    BuildContext context,
    RequestDelegateController controller,
  ) {
    final value = controller.descriptionEC.text.trim();
    return _actionCard(
      context: context,
      icon: Icons.inventory_2_outlined,
      title: _isArabic(context) ? 'الغرض المطلوب توصيله' : 'Item to be delivered',
      subtitle: value.isNotEmpty
          ? value
          : (_isArabic(context) ? 'اضغط هنا واكتب وصف الغرض أو تفاصيله' : 'Tap to describe the item'),
      highlight: value.isNotEmpty,
      trailing: const Icon(Icons.edit_outlined, color: Color(0xFFB3B7BD), size: 22),
      onTap: () => _openPackageEditor(context, controller),
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
      title: _isArabic(context) ? 'قدم أجرتك' : 'Offer your fare',
      subtitle: fareValue,
      highlight: hasFare,
      trailing: const Icon(Icons.chevron_left_rounded, color: Color(0xFFB3B7BD), size: 24),
      onTap: () => _openFareSheet(context, controller),
    );
  }

  Widget _paymentCard(
    BuildContext context,
    RequestDelegateController controller,
  ) {
    final payment = switch (controller.selectedPayment) {
      'wallet' => _isArabic(context) ? 'المحفظة' : 'Wallet',
      'online' => _isArabic(context) ? 'بطاقة بنكية' : 'Bank card',
      'v_cash' => _isArabic(context) ? 'محفظة إلكترونية / إنستا باي' : 'Digital wallet',
      'cash' => _isArabic(context) ? 'نقدًا' : 'Cash',
      _ => _isArabic(context) ? 'اختر طريقة الدفع' : 'Choose payment method',
    };

    return _actionCard(
      context: context,
      icon: Icons.account_balance_wallet_outlined,
      title: _isArabic(context) ? 'الدفع' : 'Payment',
      subtitle: payment,
      trailing: const Icon(Icons.chevron_left_rounded, color: Color(0xFFB3B7BD), size: 24),
      onTap: () => _openPaymentSheet(context, controller),
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
        Icon(icon, color: const Color(0xFF858A92), size: 22),
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
            fontWeight: FontWeight.w800,
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
        child: Ink(
          decoration: _cardDecoration(highlight: highlight),
          child: Container(
            constraints: const BoxConstraints(minHeight: 72),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: _softOrange,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(icon, color: AppColors.mainAppColor, size: 23),
                ),
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
      ),
    );
  }

  BoxDecoration _cardDecoration({bool highlight = false}) {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(
        color: highlight ? AppColors.mainAppColor.withOpacity(.75) : _borderColor,
        width: highlight ? 1.2 : 1,
      ),
      boxShadow: const [
        BoxShadow(
          color: Color(0x0D000000),
          blurRadius: 13,
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

  Future<void> _openPackageEditor(
    BuildContext context,
    RequestDelegateController controller,
  ) async {
    final textController = TextEditingController(text: controller.descriptionEC.text);

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final isAr = _isArabic(sheetContext);
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(sheetContext).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 22),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Directionality(
                textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(child: _dragHandle()),
                    const SizedBox(height: 18),
                    Text(
                      isAr ? 'الغرض المطلوب توصيله' : 'Item to be delivered',
                      style: const TextStyle(
                        color: _textColor,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isAr ? 'اكتب وصفًا واضحًا للغرض أو أي تفاصيل مهمة' : 'Add a clear description and important details',
                      style: const TextStyle(color: _mutedColor, fontSize: 12),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: textController,
                      autofocus: true,
                      minLines: 3,
                      maxLines: 5,
                      keyboardType: TextInputType.multiline,
                      textInputAction: TextInputAction.newline,
                      style: const TextStyle(color: _textColor, fontSize: 15),
                      decoration: InputDecoration(
                        hintText: isAr ? 'مثال: كرتونة مستندات صغيرة' : 'Example: small document box',
                        hintStyle: const TextStyle(color: Color(0xFFB0B4BB)),
                        filled: true,
                        fillColor: const Color(0xFFF8F9FA),
                        contentPadding: const EdgeInsets.all(16),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: _borderColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: AppColors.mainAppColor, width: 1.4),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {
                          controller.setDescriptionEC(textController.text.trim());
                          Navigator.pop(sheetContext);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.mainAppColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Text(
                          isAr ? 'حفظ التفاصيل' : 'Save details',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    textController.dispose();
  }

  Future<void> _openPaymentSheet(
    BuildContext context,
    RequestDelegateController controller,
  ) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChangeNotifierProvider.value(
        value: controller,
        child: PaymentRDBottomSheet(requestDelegateController: controller),
      ),
    );
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
