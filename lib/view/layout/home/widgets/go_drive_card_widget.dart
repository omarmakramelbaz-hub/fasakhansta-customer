import 'package:flutter/material.dart';

import '../../../../helpers/extensions/extensions.dart';
import '../../../../helpers/hive/hive_methods.dart';
import '../../../../helpers/images/app_images.dart';
import '../../../../helpers/routes/app_routers_import.dart';
import '../../../../helpers/theme/app_colors.dart';
import '../../../../helpers/theme/app_text_style.dart';
import '../../../../helpers/translation/all_translation.dart';
import '../../../../helpers/utils/common_methods.dart';
import '../../../custom_widgets/custom_image/custom_image.dart';
import '../../request_delegate/screen/request_delegate_screen.dart';
import '../controller/home_controller.dart';

class GoDriveCardWidget extends StatelessWidget {
  final HomeController controller;

  const GoDriveCardWidget({super.key, required this.controller});

  void _openRequestDelegate() {
    if (HiveMethods.getToken() == null) {
      CommonMethods.showError(message: 'youMustLoginFirst'.tr);
      return;
    }
    NamedNavigatorImpl.push(RequestDelegateScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 4, 14, 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(26),
          onTap: _openRequestDelegate,
          child: Container(
            height: 205,
            decoration: BoxDecoration(
              color: AppColors.whiteColor,
              borderRadius: BorderRadius.circular(26),
              border: Border.all(
                color: AppColors.mainAppColor.withValues(alpha: .42),
                width: 1.15,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: .07),
                  blurRadius: 22,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                Positioned(
                  left: -20,
                  top: -30,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.mainAppColor.withValues(alpha: .035),
                    ),
                  ),
                ),
                Positioned(
                  right: -28,
                  bottom: -38,
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.mainAppColor.withValues(alpha: .045),
                    ),
                  ),
                ),
                Row(
                  textDirection: TextDirection.ltr,
                  children: [
                    Expanded(
                      flex: 58,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(17, 16, 10, 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Go Drive',
                                  style: AppTextStyle.text18BS().copyWith(
                                    color: const Color(0xFF102033),
                                    fontSize: 24,
                                    letterSpacing: -.25,
                                  ),
                                ),
                                8.sbW,
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: AppColors.mainAppColor,
                                    borderRadius: BorderRadius.circular(999),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.mainAppColor.withValues(alpha: .22),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    'جديد',
                                    style: AppTextStyle.text11BS().copyWith(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                            4.sbH,
                            Text(
                              'خدمة توصيل',
                              textAlign: TextAlign.left,
                              style: AppTextStyle.text16BS().copyWith(
                                color: AppColors.mainAppColor,
                                fontSize: 18,
                              ),
                            ),
                            5.sbH,
                            Text(
                              'اطلب مندوب في أي وقت ومن أي مكان',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.left,
                              style: AppTextStyle.text12MS().copyWith(
                                color: const Color(0xFF73777D),
                                height: 1.45,
                              ),
                            ),
                            const Spacer(),
                            Row(
                              children: [
                                _FeatureChip(
                                  icon: Icons.bolt_rounded,
                                  label: 'سريع',
                                ),
                                6.sbW,
                                _FeatureChip(
                                  icon: Icons.shield_outlined,
                                  label: 'آمن',
                                ),
                                6.sbW,
                                _FeatureChip(
                                  icon: Icons.near_me_outlined,
                                  label: 'مباشر',
                                ),
                              ],
                            ),
                            10.sbH,
                            SizedBox(
                              width: double.infinity,
                              height: 42,
                              child: ElevatedButton(
                                onPressed: _openRequestDelegate,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.mainAppColor,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'اطلب الآن',
                                      style: AppTextStyle.text14BS().copyWith(color: Colors.white),
                                    ),
                                    8.sbW,
                                    Container(
                                      width: 26,
                                      height: 26,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: .18),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.arrow_back_ios_new_rounded,
                                        size: 13,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 42,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(3, 12, 10, 12),
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF7EF),
                            borderRadius: BorderRadius.circular(23),
                            border: Border.all(
                              color: AppColors.mainAppColor.withValues(alpha: .08),
                            ),
                          ),
                          child: Stack(
                            children: [
                              Positioned(
                                top: 14,
                                right: 14,
                                child: Icon(
                                  Icons.location_on_rounded,
                                  color: AppColors.mainAppColor,
                                  size: 27,
                                ),
                              ),
                              Positioned(
                                left: 11,
                                top: 17,
                                child: Icon(
                                  Icons.cloud_rounded,
                                  color: const Color(0xFFFFE7D1),
                                  size: 37,
                                ),
                              ),
                              Positioned.fill(
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(8, 29, 8, 7),
                                  child: CustomImage(
                                    path: AppImages.gooDriveImage,
                                    type: ImageType.asset,
                                    fit: BoxFit.contain,
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  const _FeatureChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 31,
        padding: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF8F1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppColors.mainAppColor.withValues(alpha: .10),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: AppColors.mainAppColor),
            4.sbW,
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyle.text10RG().copyWith(
                  color: const Color(0xFF313131),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
