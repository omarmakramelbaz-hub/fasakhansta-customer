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
import '../../../custom_widgets/buttons/custom_button.dart';
import '../../../custom_widgets/custom_app_bar/custom_app_bar.dart';
import '../../../custom_widgets/custom_form_field/custom_form_field.dart';
import '../../../custom_widgets/custom_image/custom_image.dart';
import '../../../custom_widgets/validation/validation_mixin.dart';
import '../../bottom_navigation/bottom_navigation_bar_screen.dart';
import '../controller/auth_controller.dart';

class SocialAuthPhoneScreen extends StatefulWidget {
  static const routeName = 'SocialAuthPhoneScreen';

  final Map<String, dynamic> socialAuthData;

  const SocialAuthPhoneScreen({super.key, required this.socialAuthData});

  @override
  State<SocialAuthPhoneScreen> createState() => _SocialAuthPhoneScreenState();
}

class _SocialAuthPhoneScreenState extends State<SocialAuthPhoneScreen> with ValidationMixin {
  final _formKey = GlobalKey<FormState>();
  final _mobileEC = TextEditingController();
  Country? _country;

  @override
  void initState() {
    _country = CountryParser.parsePhoneCode('20');
    super.initState();
  }

  @override
  void dispose() {
    _mobileEC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Scaffold(
        appBar: CustomAppBar(
          centerTitle: false,
          title: const CustomImage(
            path: AppImages.appLogo,
            type: ImageType.asset,
            height: 55,
            radius: 12,
          ),
          appBarColor: AppColors.whiteColor,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 25),
              Text('completeYourProfile'.tr, style: AppTextStyle.text20BS()),
              18.sbH,
              Text(
                'pleaseEnterYourPhoneNumberToCompleteRegistration'.tr,
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
              const SizedBox(height: 90),
              CustomButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    context.read<AuthController>().completeSocialAuth(
                          socialAuthData: widget.socialAuthData,
                          mobile: _mobileEC.text.removeZero(),
                          countryCode: _country?.phoneCode ?? '20',
                          onSuccess: (register, mobileVerifiedAt) {
                            if (register == 0 && mobileVerifiedAt != null) {
                              HiveMethods.updateIsVisitor(false);
                              NamedNavigatorImpl.push(
                                BottomNavigationBarScreen.routeName,
                                replace: true,
                              );
                            } else {
                              HiveMethods.updateIsVisitor(false);
                              NamedNavigatorImpl.push(
                                BottomNavigationBarScreen.routeName,
                                clean: true,
                              );
                            }
                          },
                          onHaveIdANDToken: (id, token) {
                            context.read<PusherController>().initPusher(
                                  channelName: 'private-user.$id',
                                  userId: id,
                                  token: token,
                                );
                          },
                        );
                  }
                },
                radius: 25,
                text: 'continue'.tr,
                style: AppTextStyle.text18BW(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
