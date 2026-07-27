import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../helpers/extension/string_extension.dart';
import '../../../../helpers/extensions/extensions.dart';
import '../../../../helpers/images/app_images.dart';
import '../../../../helpers/routes/app_routers_import.dart';
import '../../../../helpers/theme/app_colors.dart';
import '../../../../helpers/theme/app_text_style.dart';
import '../../../../helpers/translation/all_translation.dart';
import '../../../../helpers/utils/common_methods.dart';
import '../../../custom_widgets/buttons/custom_button.dart';
import '../../../custom_widgets/custom_app_bar/custom_app_bar.dart';
import '../../../custom_widgets/custom_form_field/custom_form_field.dart';
import '../../../custom_widgets/custom_image/custom_image.dart';
import '../../../custom_widgets/validation/validation_mixin.dart';
import '../controller/auth_controller.dart';
import 'change_password_check_code.dart';

class CheckMobileHasAccount extends StatefulWidget {
  static const routeName = 'CheckMobileHasAccount';
  const CheckMobileHasAccount({super.key});

  @override
  State<CheckMobileHasAccount> createState() => _CheckMobileHasAccountState();
}

class _CheckMobileHasAccountState extends State<CheckMobileHasAccount> with ValidationMixin {
  final _formKey = GlobalKey<FormState>();
  final _mobileEC = TextEditingController();

  Country? _country;

  @override
  void initState() {
    _country = CountryParser.parsePhoneCode('20');

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Scaffold(
        appBar: CustomAppBar(
          centerTitle: false,
          title: const CustomImage(path: AppImages.appLogo, type: ImageType.asset, height: 55, radius: 12),
          appBarColor: AppColors.whiteColor,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 25),
              Row(
                children: [
                  Text('forgotPassword'.tr, style: AppTextStyle.text20BS()),
                  const SizedBox(width: 8),
                  //   SvgPicture.asset(AppImages.welcomeIcon),
                ],
              ),
              30.sbH,
              CustomFormField(
                validator: (v) => validatePhone(v, country: _country),
                controller: _mobileEC,
                keyboardType: TextInputType.number,
                country: _country,
                title: 'mobileNumber'.tr,
              ),
              30.sbH,
              const SizedBox(height: 90),
              CustomButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    context.read<AuthController>().checkMobileHasAccount(
                          mobile: _mobileEC.text.removeZero(),
                          countryCode: _country!.phoneCode,
                          onSuccess: (email) {
                            CommonMethods.showChooseDialog(
                              context,
                              message: 'weWillSendCodeToThisEmail'.translate(args: [email]),
                              onPressed: () {
                                context.read<AuthController>().forgetPassword(
                                      email: email,
                                      mobile: _mobileEC.text.removeZero(),
                                      onSuccess: () {
                                        NamedNavigatorImpl.pop();
                                        NamedNavigatorImpl.push(
                                          ChangePasswordCheckCodeScreen.routeName,
                                          arguments: ChangePasswordCheckCodeArguments(
                                            email: email,
                                            mobile: _mobileEC.text.removeZero(),
                                          ),
                                        );
                                      },
                                    );
                              },
                            );
                          },
                        );
                  }
                },
                radius: 25,
                text: 'send'.tr,
                style: AppTextStyle.text18BW(),
              ),
              30.sbH,
            ],
          ),
        ),
      ),
    );
  }
}

//
