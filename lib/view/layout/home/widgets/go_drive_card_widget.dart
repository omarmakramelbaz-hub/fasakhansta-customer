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
      padding: const EdgeInsets.fromLTRB(14, 2, 14, 14),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: _openRequestDelegate,
          child: Container(
            height: 156,
            decoration: BoxDecoration(
              color: AppColors.whiteColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.mainAppColor, width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: AppColors.blackColor.withOpacity(.07),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(19),
              child: Row(
                children: [
                  SizedBox(
                    width: context.width * .36,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.lightGreyColor,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(19),
                              bottomLeft: Radius.circular(19),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: CustomImage(
                            path: AppImages.gooDriveImage,
                            type: ImageType.asset,
                            fit: BoxFit.contain,
                          ),
                        ),
                        Positioned(
                          top: 10,
                          left: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.mainAppColor,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              'جديد',
                              style: AppTextStyle.text12BS().copyWith(color: AppColors.whiteColor),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(10, 10, 12, 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Go Drive',
                            style: AppTextStyle.text18BS().copyWith(color: AppColors.darkTextColor),
                            textAlign: TextAlign.right,
                          ),
                          2.sbH,
                          Text(
                            'خدمة توصيل',
                            style: AppTextStyle.text14BS().copyWith(color: AppColors.mainAppColor),
                            textAlign: TextAlign.right,
                          ),
                          4.sbH,
                          Text(
                            'اطلب مندوب في أي وقت ومن أي مكان',
                            style: AppTextStyle.text12MS().copyWith(color: AppColors.greyColor, height: 1.3),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.right,
                          ),
                          const Spacer(),
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 5),
                                  decoration: BoxDecoration(
                                    color: AppColors.lightGreyColor,
                                    borderRadius: BorderRadius.circular(9),
                                  ),
                                  child: Text(
                                    'سريع • آمن • مباشر',
                                    style: AppTextStyle.text10MS().copyWith(color: AppColors.darkTextColor),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                              7.sbW,
                              SizedBox(
                                height: 34,
                                child: ElevatedButton(
                                  onPressed: _openRequestDelegate,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.mainAppColor,
                                    foregroundColor: AppColors.whiteColor,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  child: Text('اطلب الآن', style: AppTextStyle.text12BS()),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
