import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../../helpers/extensions/extensions.dart';
import '../../../../helpers/images/app_images.dart';
import '../../../../helpers/theme/app_colors.dart';
import '../../../../helpers/theme/app_text_style.dart';
import '../../../../helpers/translation/all_translation.dart';
import '../../../../helpers/utils/utils.dart';
import '../../../custom_widgets/api_response_widget/api_response_widget.dart';
import '../../../custom_widgets/buttons/custom_button.dart';
import '../../../custom_widgets/custom_form_field/custom_form_field.dart';
import '../../../custom_widgets/custom_image/custom_image.dart';
import '../../../custom_widgets/custom_select/custom_select_item.dart';
import '../../../custom_widgets/custom_select/custom_single_select.dart';
import '../../../custom_widgets/page_container/page_container.dart';
import '../../../custom_widgets/validation/validation_mixin.dart';
import '../../auth/controller/auth_controller.dart';
import '../account_app_bar/account_app_bar.dart';
import '../bottom_sheet/choose_avatar_bottom_sheet.dart';

class PersonalInformationScreen extends StatefulWidget {
  static const String routeName = 'PersonalInformationScreen';
  const PersonalInformationScreen({super.key});

  @override
  State<PersonalInformationScreen> createState() => _PersonalInformationScreenState();
}

class _PersonalInformationScreenState extends State<PersonalInformationScreen> with ValidationMixin {
  final _nameEc = TextEditingController();
  final _emailEc = TextEditingController();
  final _mobile = TextEditingController();
  int? _country;
  String? _gender;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthController>().getProfile().then((value) {
        _nameEc.text = context.read<AuthController>().profile?.name ?? '';
        _emailEc.text = context.read<AuthController>().profile?.email ?? '';
        _gender = context.read<AuthController>().profile?.gender ?? '';
        _mobile.text = context.read<AuthController>().profile?.mobile ?? '';
      });
      context.read<AuthController>().getArea().then((value) {
        _country = context.read<AuthController>().profile?.areaId;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _nameEc.dispose();
    _emailEc.dispose();
    _mobile.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthController>(
      builder: (context, authController, _) {
        return Scaffold(
          body: PageContainer(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  30.sbH,
                  CustomAccountAppBar(title: 'personalInformation'.tr),
                  const SizedBox(height: 32),
                  ApiResponseWidget(
                    apiResponse: authController.profileResponse,
                    onReload: authController.getProfile,
                    isEmpty: authController.profile == null,
                    child: Container(
                      width: context.width,
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
                        children: [
                          const SizedBox(height: 26),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              children: [
                                InkWell(
                                  onTap: () {
                                    Utils.showAppBottomSheet(const ChooseAvatarBottomSheet());
                                  },
                                  child: _gender == 'male' ||
                                          Provider.of<AuthController>(context).profile?.gender == 'male'
                                      ? SvgPicture.asset(AppImages.avatarMale)
                                      : _gender == 'female' ||
                                              Provider.of<AuthController>(context).profile?.gender == 'female'
                                          ? SvgPicture.asset(AppImages.avatarFemale)
                                          : Container(
                                              height: 56,
                                              width: 56,
                                              decoration: BoxDecoration(
                                                color: AppColors.mainAppColor,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Center(
                                                child: Text(
                                                  authController.profile?.name?.substring(0, 1) ?? '',
                                                  style: AppTextStyle.text18BW().copyWith(fontSize: 40),
                                                ),
                                              ),
                                            ),
                                ),
                                const SizedBox(width: 20),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(authController.profile?.name ?? '', style: AppTextStyle.text18BS()),
                                    10.sbH,
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const CustomImage(path: AppImages.egyptIcon, type: ImageType.svg),
                                        const SizedBox(width: 8),
                                        Text(authController.profile?.areaTitle ?? '', style: AppTextStyle.text18RS()),
                                      ],
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                // GestureDetector(
                                //   onTap: () {
                                //     context.read<AuthController>().updateUserInfo(
                                //           name: _nameEc.text,
                                //           email: _emailEc.text,
                                //           id: _country ?? 1,
                                //           onSuccess: () {
                                //             // Navigator.pop(context);
                                //             authController.getProfile();
                                //           },
                                //         );
                                //   },
                                //   child: Row(
                                //     children: [
                                //       SvgPicture.asset(AppImages.editIcon),
                                //       const SizedBox(
                                //         width: 8,
                                //       ),
                                //       Text(
                                //         'save'.tr,
                                //         style: AppTextStyle.text16RG(),
                                //       ),
                                //     ],
                                //   ),
                                // )
                              ],
                            ),
                          ),
                          const SizedBox(height: 29),
                          Divider(color: AppColors.greyColor.withValues(alpha: 0.2), height: 2),
                          const SizedBox(height: 24),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              children: [
                                CustomFormField(controller: _nameEc, title: 'name'.tr),
                                const SizedBox(height: 24),
                                // CustomFormField(
                                //   controller: _mobile,
                                //   title: 'mobile'.tr,
                                //   keyboardType: TextInputType.number,
                                //   inputFormatters: [
                                //     FilteringTextInputFormatter.digitsOnly
                                //   ],
                                // ),
                                // const SizedBox(
                                //   height: 24,
                                // ),
                                CustomFormField(controller: _emailEc, title: 'email'.tr),
                                const SizedBox(height: 24),
                                CustomSingleSelect(
                                  validator: validateEmptyDropDown,
                                  apiResponse: authController.areaResponse,
                                  onReload: () => authController.getArea(),
                                  value:
                                      _country ?? (authController.area.isNotEmpty ? authController.area[0].id ?? 0 : 0),
                                  onChanged: (value) {
                                    setState(() {
                                      _country = value;
                                    });
                                  },
                                  title: 'country'.tr,
                                  items: authController.area
                                      .map((e) => CustomSelectItem(value: e.id, name: e.title ?? ''))
                                      .toList(),
                                ),
                                const SizedBox(height: 24),
                              ],
                            ),
                          ),
                          20.sbH,
                          Padding(
                            padding: const EdgeInsets.all(21.0),
                            child: CustomButton(
                              text: 'saveChanges'.tr,
                              onPressed: () {
                                context.read<AuthController>().updateUserInfo(
                                      name: _nameEc.text,
                                      email: _emailEc.text,
                                      id: _country ?? 1,
                                      onSuccess: () {
                                        Navigator.pop(context);
                                        // authController.getProfile();
                                      },
                                    );
                              },
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
        );
      },
    );
  }
}
