import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../helpers/extensions/extensions.dart';
import '../../../../helpers/images/app_images.dart';
import '../../../../helpers/routes/app_routers_import.dart';
import '../../../../helpers/theme/app_colors.dart';
import '../../../../helpers/theme/app_text_style.dart';
import '../../../../helpers/translation/all_translation.dart';
import '../../../../helpers/translation/main_app_bloc.dart';
import '../../../custom_widgets/buttons/custom_button.dart';

class ChangeLangBottomSheet extends StatefulWidget {
  const ChangeLangBottomSheet({super.key});

  @override
  State<ChangeLangBottomSheet> createState() => _MenuBottomSheetWidgetState();
}

class _MenuBottomSheetWidgetState extends State<ChangeLangBottomSheet> {
  // final int _currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Container(
      // height: context.height * .320,
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(36), topRight: Radius.circular(36)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 33, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('changeLanguage'.tr, style: AppTextStyle.text16MS()),
                InkWell(
                  onTap: () => Navigator.pop(context),
                  child: Card(
                    elevation: 10,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.whiteColor,
                      child: SvgPicture.asset(AppImages.closeIcon),
                    ),
                  ),
                ),
              ],
            ),
            15.sbH,
            const Divider(thickness: 1),
            15.sbH,
            CustomButton(
              gradient: isAr(context) ? buildLinearGradient(context) : buildLinearGradient2(context),
              onPressed: () {
                mainAppBloc.updateLang('ar');
                changeLanguage('ar');
                NamedNavigatorImpl.pop();
                setState(() {});
              },
              style: isAr(context) ? AppTextStyle.text18BW() : AppTextStyle.text18BS(),
              color: isAr(context) ? AppColors.whiteColor : AppColors.whiteColor,
              borderColor: isAr(context) ? null : AppColors.mainAppColor,
              text: 'العربية',
            ),
            15.sbH,
            CustomButton(
              gradient: context.isEn ? buildLinearGradient(context) : buildLinearGradient2(context),
              onPressed: () {
                mainAppBloc.updateLang('en');
                changeLanguage('en');
                NamedNavigatorImpl.pop();
                setState(() {});
              },
              style: context.isEn ? AppTextStyle.text18BW() : AppTextStyle.text18BS(),
              color: context.isEn ? AppColors.mainAppColor : AppColors.whiteColor,
              borderColor: context.isEn ? null : AppColors.mainAppColor,
              text: 'English',
            ),
          ],
        ),
      ),
    );
  }

  bool isAr(BuildContext context) => context.languageCode == 'ar';

  LinearGradient buildLinearGradient2(BuildContext context) {
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [AppColors.whiteColor, AppColors.whiteColor],
    );
  }

  LinearGradient buildLinearGradient(BuildContext context) {
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [AppColors.gridOneButtonColor, AppColors.gridTwoButtonColor],
    );
  }
}
