import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../helpers/extensions/extensions.dart';
import '../../../../helpers/images/app_images.dart';
import '../../../../helpers/routes/app_routers_import.dart';
import '../../../../helpers/theme/app_colors.dart';
import '../../../../helpers/theme/app_text_style.dart';
import '../../../../helpers/translation/all_translation.dart';
import '../../../../helpers/utils/common_methods.dart';
import '../../../../helpers/utils/utils.dart';
import '../../../custom_widgets/custom_image/custom_image.dart';
import '../bottom_sheet/submit_your_fee_bottom_sheet.dart';
import '../controller/request_delegate_controller.dart';
import '../screen/search_place_screen.dart';

class CustomMapAnimatedContainer extends StatelessWidget {
  const CustomMapAnimatedContainer({super.key, required this.containerHeight});

  final double? containerHeight;

  @override
  Widget build(BuildContext context) {
    return Consumer<RequestDelegateController>(
      builder: (context, requestDelegateController, _) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: containerHeight ?? context.height * 0.54,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF151B23), Color(0xFF080A0D)],
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(32),
              topRight: Radius.circular(32),
            ),
            border: Border(
              top: BorderSide(color: Colors.white.withOpacity(.24), width: 1),
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x66000000),
                blurRadius: 28,
                offset: Offset(0, -8),
              ),
            ],
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 26),
            child: Column(
              children: [
                Container(
                  width: 54,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                14.sbH,
                _buildHeader(context),
                14.sbH,
                _buildCurrentLocationCard(context, requestDelegateController),
                10.sbH,
                _buildDestinationCard(context, requestDelegateController),
                10.sbH,
                _buildPackageField(context, requestDelegateController),
                10.sbH,
                _buildFareCard(context, requestDelegateController),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      textDirection: TextDirection.ltr,
      children: [
        Expanded(
          child: Directionality(
            textDirection: context.isAr ? TextDirection.rtl : TextDirection.ltr,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'usingMotorcycle'.tr,
                  textAlign: TextAlign.center,
                  style: AppTextStyle.text16RM().copyWith(
                    color: AppColors.whiteColor,
                    fontSize: 23,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  context.isAr ? 'توصيل سريع وآمن لطلباتك' : 'Fast and secure delivery for your orders',
                  textAlign: TextAlign.center,
                  style: AppTextStyle.text14MW().copyWith(
                    color: Colors.white54,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 78,
          height: 72,
          child: Center(
            child: CustomImage(
              path: AppImages.darkMotorCycle,
              type: ImageType.svg,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentLocationCard(
    BuildContext context,
    RequestDelegateController controller,
  ) {
    final lat = controller.fromLat;
    final lng = controller.fromLan;
    final coordinates = lat != null && lng != null && lat.isNotEmpty && lng.isNotEmpty
        ? '$lat, $lng'
        : controller.fromAddress;

    return _actionCard(
      context: context,
      icon: Icons.my_location_rounded,
      iconColor: AppColors.mainAppColor,
      title: coordinates.isNotEmpty ? coordinates : 'deliverFromCurrentLocation'.tr,
      trailing: Container(
        width: 12,
        height: 12,
        decoration: const BoxDecoration(
          color: Color(0xFF26D36B),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: Color(0x6626D36B), blurRadius: 8, spreadRadius: 2),
          ],
        ),
      ),
      onTap: () => _openSearchPlace(controller),
    );
  }

  Widget _buildDestinationCard(
    BuildContext context,
    RequestDelegateController controller,
  ) {
    return _actionCard(
      context: context,
      icon: Icons.location_on_outlined,
      iconColor: AppColors.mainAppColor,
      title: controller.toAddress.isNotEmpty ? controller.toAddress : 'deliverTo'.tr,
      hintStyle: controller.toAddress.isEmpty,
      trailing: Icon(Icons.gps_fixed_rounded, color: Colors.white38, size: 22),
      onTap: () => _openSearchPlace(controller),
    );
  }

  Widget _buildPackageField(
    BuildContext context,
    RequestDelegateController controller,
  ) {
    final title = context.isAr ? 'الغرض المطلوب توصيله' : 'Item to be delivered';
    final hint = context.isAr ? 'اكتب وصف الغرض أو تفاصيله' : 'Describe the item or its details';

    return Container(
      decoration: _fieldDecoration(),
      child: Directionality(
        textDirection: context.isAr ? TextDirection.rtl : TextDirection.ltr,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(width: 14),
            Icon(Icons.inventory_2_outlined, color: AppColors.mainAppColor, size: 25),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: controller.descriptionEC,
                minLines: 1,
                maxLines: 2,
                textInputAction: TextInputAction.done,
                style: AppTextStyle.text14MW().copyWith(
                  color: AppColors.whiteColor,
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 13),
                  hintText: title,
                  hintStyle: AppTextStyle.text14MW().copyWith(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                  helperText: hint,
                  helperMaxLines: 1,
                  helperStyle: AppTextStyle.text14MW().copyWith(
                    color: Colors.white38,
                    fontSize: 11,
                  ),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 14),
              child: Icon(Icons.description_outlined, color: Colors.white30, size: 22),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFareCard(
    BuildContext context,
    RequestDelegateController controller,
  ) {
    final hasFare = controller.priceEC.text.trim().isNotEmpty;
    final fareText = hasFare
        ? '${controller.priceEC.text} ${'egyptianPound'.tr}'
        : 'providePrice'.tr;
    final subtitle = context.isAr
        ? 'اكتب مبلغ الأجرة الذي ترغب في دفعه'
        : 'Enter the fare you would like to pay';

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => _openFareSheet(context, controller),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: _fieldDecoration(
          borderColor: hasFare ? AppColors.mainAppColor.withOpacity(.75) : null,
        ),
        child: Directionality(
          textDirection: context.isAr ? TextDirection.rtl : TextDirection.ltr,
          child: Row(
            children: [
              Icon(Icons.payments_outlined, color: AppColors.mainAppColor, size: 25),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fareText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyle.text14MW().copyWith(
                        color: hasFare ? AppColors.mainAppColor : Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyle.text14MW().copyWith(
                        color: Colors.white38,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.edit_outlined, color: Colors.white38, size: 21),
            ],
          ),
        ),
      ),
    );
  }

  Widget _actionCard({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required Widget trailing,
    required VoidCallback onTap,
    bool hintStyle = false,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        minHeight: 62,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: _fieldDecoration(),
        child: Directionality(
          textDirection: context.isAr ? TextDirection.rtl : TextDirection.ltr,
          child: Row(
            children: [
              Icon(icon, color: iconColor, size: 25),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.text14MW().copyWith(
                    color: hintStyle ? Colors.white38 : Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              trailing,
            ],
          ),
        ),
      ),
    );
  }

  BoxDecoration _fieldDecoration({Color? borderColor}) {
    return BoxDecoration(
      color: const Color(0xFF1A2028),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: borderColor ?? Colors.white.withOpacity(.16),
        width: 1,
      ),
      boxShadow: const [
        BoxShadow(
          color: Color(0x22000000),
          blurRadius: 10,
          offset: Offset(0, 4),
        ),
      ],
    );
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
