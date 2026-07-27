import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../helpers/extension/string_extension.dart';
import '../../../../helpers/extensions/extensions.dart';
import '../../../../helpers/images/app_images.dart';
import '../../../../helpers/pusher_service/pusher_controller.dart';
import '../../../../helpers/routes/app_routers_import.dart';
import '../../../../helpers/theme/app_colors.dart';
import '../../../../helpers/theme/app_text_style.dart';
import '../../../../helpers/translation/all_translation.dart';
import 'social_login_row_widget.dart';
import '../../../custom_widgets/buttons/custom_button.dart';
import '../../../custom_widgets/custom_app_bar/custom_app_bar.dart';
import '../../../custom_widgets/custom_form_field/custom_form_field.dart';
import '../../../custom_widgets/custom_image/custom_image.dart';
import '../../../custom_widgets/validation/validation_mixin.dart';
import '../../bottom_navigation/bottom_navigation_bar_screen.dart';
import '../controller/auth_controller.dart';
import 'create_new_account_screen.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  static const routeName = 'RegisterScreen';

  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with ValidationMixin {
  final _formKey = GlobalKey<FormState>();
  final _mobileEC = TextEditingController();
  final _passwordEC = TextEditingController();
  final _focusNode = FocusNode();

  Country? _country;

  @override
  void initState() {
    _country = CountryParser.parsePhoneCode('20');
    super.initState();
  }

  @override
  void dispose() {
    _mobileEC.dispose();
    _passwordEC.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Scaffold(
        appBar: CustomAppBar(
          showLang: true,
          centerTitle: false,
          height: 70,
          title: const CustomImage(path: AppImages.appLogo, type: ImageType.asset, height: 55, radius: 12),
          appBarColor: AppColors.whiteColor,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 25),
              Text('createANewAccount'.tr, style: AppTextStyle.text20BS()),
              18.sbH,
              Text(
                'heyYouPleaseEnterYourMobileNumberToCompleteTheAccountCreation'.tr,
                style: AppTextStyle.text18RDG(),
              ),
              30.sbH,
              CustomFormField(
                validator: (v) => validatePhone(v, country: _country),
                controller: _mobileEC,
                keyboardType: TextInputType.number,
                title: 'mobileNumber'.tr,
                country: _country,
              ),
              30.sbH,
              CustomFormField(
                validator: validatePassword,
                controller: _passwordEC,
                title: 'password'.tr,
                isPassword: true,
                focusNode: _focusNode,
                onFieldSubmitted: (p0) {
                  _focusNode.unfocus();
                },
              ),
              const SizedBox(height: 90),
              CustomButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    context.read<AuthController>().login(
                          onHaveIdANDToken: (id, token) {
                            context.read<PusherController>().initPusher(
                                  channelName: 'private-user.$id',
                                  userId: id,
                                  token: token,
                                );
                          },
                          onFirstTime: () => NamedNavigatorImpl.push(CreateNewAccountScreen.routeName),
                          mobile: _mobileEC.text.removeZero(),
                          password: _passwordEC.text,
                          onSuccess: (register, mobileVerifiedAt) {
                            if (register == 0 && mobileVerifiedAt != null) {
                              NamedNavigatorImpl.push(BottomNavigationBarScreen.routeName);
                            } else {
                              NamedNavigatorImpl.push(BottomNavigationBarScreen.routeName);
                            }
                          },
                        );
                  }
                },
                radius: 25,
                text: 'next'.tr,
              ),
              20.sbH,
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('doYouHaveAnAccount'.tr, style: AppTextStyle.text16MS()),
                  TextButton(
                    onPressed: () => NamedNavigatorImpl.push(LoginScreen.routeName),
                    child: Text('signIn'.tr, style: AppTextStyle.text16BM()),
                  ),
                ],
              ),
              20.sbH,
              const SocialLoginRowWidget(),
              const SizedBox(height: 25),
            ],
          ),
        ),
      ),
    );
  }
}
