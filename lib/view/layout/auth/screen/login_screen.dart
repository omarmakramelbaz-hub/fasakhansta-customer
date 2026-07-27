import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../helpers/extension/string_extension.dart';
import '../../../../helpers/extensions/extensions.dart';
import '../../../../helpers/hive/hive_methods.dart';
import '../../../../helpers/images/app_images.dart';
import '../../../../helpers/pusher_service/pusher_controller.dart';
import '../../../../helpers/routes/app_routers_import.dart';
import '../../../../helpers/theme/app_colors.dart';
import '../../../../helpers/theme/app_text_style.dart';
import '../../../../helpers/translation/all_translation.dart';
import '../../../../helpers/translation/main_app_bloc.dart';
import 'social_login_row_widget.dart';
import '../../../custom_widgets/buttons/custom_button.dart';
import '../../../custom_widgets/custom_app_bar/custom_app_bar.dart';
import '../../../custom_widgets/custom_form_field/custom_form_field.dart';
import '../../../custom_widgets/custom_image/custom_image.dart';
import '../../../custom_widgets/validation/validation_mixin.dart';
import '../../bottom_navigation/bottom_navigation_bar_screen.dart';
import '../controller/auth_controller.dart';
import 'check_mobile_has_account.dart';
import 'create_new_account_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = 'LoginScreen';
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with ValidationMixin {
  final _formKey = GlobalKey<FormState>();
  final _mobileEC = TextEditingController();
  final _passwordEC = TextEditingController();
  Country? _country;

  @override
  void initState() {
    _country = CountryParser.parsePhoneCode('20');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<String>(
        stream: mainAppBloc.langStream,
        builder: (context, lang) {
          return Form(
            key: _formKey,
            child: Scaffold(
              appBar: CustomAppBar(
                centerTitle: false,
                title: const CustomImage(path: AppImages.appLogo, type: ImageType.asset, height: 55, radius: 12),
                appBarColor: AppColors.whiteColor,
                showLang: true,
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 25),
                    Row(
                      children: [
                        Text('welcomeBackAgain'.tr, style: AppTextStyle.text20BS()),
                        8.sbW,
                      ],
                    ),
                    18.sbH,
                    Text('welcomeToYouPleaseEnterYourAccountDetails'.tr, style: AppTextStyle.text18RDG()),
                    30.sbH,
                    CustomFormField(
                      validator: (v) => validatePhone(v, country: _country),
                      controller: _mobileEC,
                      keyboardType: TextInputType.number,
                      country: _country,
                      title: 'mobileNumber'.tr,
                    ),
                    30.sbH,
                    CustomFormField(
                      validator: validatePassword,
                      controller: _passwordEC,
                      title: 'password'.tr,
                      isPassword: true,
                    ),
                    Align(
                      alignment: context.languageCode == 'en' ? Alignment.topRight : Alignment.topLeft,
                      child: TextButton(
                        onPressed: () {
                          NamedNavigatorImpl.push(CheckMobileHasAccount.routeName);
                        },
                        child: Text('didYouForgetPassword'.tr),
                      ),
                    ),
                    const SizedBox(height: 15),
                    const SocialLoginRowWidget(),
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
                                onFirstTime: () {
                                  NamedNavigatorImpl.push(CreateNewAccountScreen.routeName);
                                },
                                mobile: _mobileEC.text.removeZero(),
                                password: _passwordEC.text,
                                onSuccess: (register, mobileVerifiedAt) {
                                  if (register == 0 && mobileVerifiedAt != null) {
                                    HiveMethods.updateIsVisitor(false);
                                    NamedNavigatorImpl.push(BottomNavigationBarScreen.routeName, replace: true);
                                  } else {
                                    HiveMethods.updateIsVisitor(false);
                                    NamedNavigatorImpl.push(BottomNavigationBarScreen.routeName, clean: true);
                                  }
                                },
                              );
                        }
                      },
                      radius: 25,
                      text: 'login'.tr,
                      style: AppTextStyle.text18BW(),
                    ),
                    30.sbH,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('youDontHaveAnAccount'.tr, style: AppTextStyle.text16MS()),
                        TextButton(
                          onPressed: () {
                            NamedNavigatorImpl.push(RegisterScreen.routeName);
                          },
                          child: Text('createAnAccount'.tr, style: AppTextStyle.text16BM()),
                        ),
                      ],
                    ),
                    10.sbH,
                    Center(
                      child: TextButton(
                        onPressed: () {
                          HiveMethods.deleteToken();
                          HiveMethods.updateIsVisitor(true);
                          NamedNavigatorImpl.push(BottomNavigationBarScreen.routeName);
                        },
                        child: Text(
                          'loginAsGuest'.tr,
                          style: const TextStyle(
                            decoration: TextDecoration.underline,
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }
}
