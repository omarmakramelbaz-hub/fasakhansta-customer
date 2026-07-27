import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../../helpers/extensions/extensions.dart';
import '../../../../helpers/images/app_images.dart';
import '../../../../helpers/theme/app_colors.dart';
import '../../../../helpers/theme/app_text_style.dart';
import '../../../../helpers/translation/all_translation.dart';
import '../../../custom_widgets/buttons/custom_button.dart';
import '../../../custom_widgets/custom_form_field/custom_form_field.dart';
import '../../../custom_widgets/validation/validation_mixin.dart';
import '../../auth/controller/auth_controller.dart';
import '../controller/my_account_controller.dart';

class ChangePhoneNumberBottomSheet extends StatefulWidget {
  const ChangePhoneNumberBottomSheet({super.key});

  @override
  State<ChangePhoneNumberBottomSheet> createState() => _MenuBottomSheetWidgetState();
}

class _MenuBottomSheetWidgetState extends State<ChangePhoneNumberBottomSheet> with ValidationMixin {
  final _formKey = GlobalKey<FormState>();
  final _phoneNumberEc = TextEditingController();
  final _passwordEC = TextEditingController();
  Country? _country;

  @override
  void initState() {
    _country = CountryParser.parsePhoneCode('20');
    _phoneNumberEc.text = context.read<AuthController>().profile?.mobile ?? '';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, top: 20),
      child: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.whiteColor,
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(36), topRight: Radius.circular(36)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 33, vertical: 20),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('changePhoneNumber'.tr, style: AppTextStyle.text16MS()),
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
                  Divider(thickness: 1, color: AppColors.borderColor),
                  20.sbH,
                  CustomFormField(
                    validator: (v) => validatePhone(v, country: _country),
                    controller: _phoneNumberEc,
                    keyboardType: TextInputType.number,
                    country: _country,
                    title: 'mobileNumber'.tr,
                  ),
                  20.sbH,
                  CustomFormField(
                    //  validator: validatePassword,
                    controller: _passwordEC,
                    title: 'password'.tr,
                  ),
                  20.sbH,
                  ChangeNotifierProvider(
                    create: (context) => MyAccountController(),
                    child: Consumer<MyAccountController>(
                      builder: (context, myAccountController, _) {
                        return CustomButton(
                          gradient:
                              LinearGradient(colors: [AppColors.gridOneButtonColor, AppColors.gridTwoButtonColor]),
                          text: 'save'.tr,
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              myAccountController.changePhoneNumber(
                                phoneNumber: _phoneNumberEc.text,
                                password: _passwordEC.text,
                                onSuccess: () {
                                  context.read<AuthController>().getProfile();
                                  Navigator.pop(context);
                                },
                              );
                            }
                          },
                        );
                      },
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
