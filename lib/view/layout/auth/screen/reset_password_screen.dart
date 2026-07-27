import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../helpers/extensions/extensions.dart';
import '../../../../helpers/images/app_images.dart';
import '../../../../helpers/routes/app_routers_import.dart';
import '../../../../helpers/theme/app_colors.dart';
import '../../../../helpers/theme/app_text_style.dart';
import '../../../../helpers/translation/all_translation.dart';
import '../../../custom_widgets/buttons/custom_button.dart';
import '../../../custom_widgets/custom_app_bar/custom_app_bar.dart';
import '../../../custom_widgets/custom_form_field/custom_form_field.dart';
import '../../../custom_widgets/custom_image/custom_image.dart';
import '../../../custom_widgets/validation/validation_mixin.dart';
import '../controller/auth_controller.dart';
import 'login_screen.dart';

class ResetPasswordScreenArgs {
  final String mobile;
  final String email;
  ResetPasswordScreenArgs({required this.email, required this.mobile});
}

class ResetPasswordScreen extends StatefulWidget {
  static const routeName = 'ResetPasswordScreen';
  final ResetPasswordScreenArgs args;

  const ResetPasswordScreen({super.key, required this.args});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> with ValidationMixin {
  final _formKey = GlobalKey<FormState>();

  final _passwordEC = TextEditingController();
  final _confirmpasswordEC = TextEditingController();

  @override
  void dispose() {
    _confirmpasswordEC.dispose();
    _passwordEC.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Scaffold(
        appBar: CustomAppBar(
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
              Text('changePassword'.tr, style: AppTextStyle.text20BS()),
              30.sbH,
              CustomFormField(
                validator: validatePassword,
                controller: _passwordEC,
                title: 'password'.tr,
                isPassword: true,
              ),
              30.sbH,
              CustomFormField(
                validator: (value) => validateConfirmPassword(value, _passwordEC.text),
                controller: _confirmpasswordEC,
                title: 'confirmNewPassword'.tr,
                isPassword: true,
              ),
              const SizedBox(height: 90),
              CustomButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    context.read<AuthController>().resetPassword(
                          mobile: widget.args.mobile,
                          email: widget.args.email,
                          newPassword: _passwordEC.text,
                          confirmNewPassword: _confirmpasswordEC.text,
                          onSuccess: () {
                            NamedNavigatorImpl.push(LoginScreen.routeName, clean: true);
                          },
                        );
                  }
                },
                radius: 25,
                text: 'changePassword'.tr,
              ),
              20.sbH,
            ],
          ),
        ),
      ),
    );
  }
}
