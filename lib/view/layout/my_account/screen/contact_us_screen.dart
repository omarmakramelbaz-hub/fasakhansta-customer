import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../helpers/extensions/extensions.dart';
import '../../../../helpers/theme/app_colors.dart';
import '../../../../helpers/theme/app_text_style.dart';
import '../../../../helpers/translation/all_translation.dart';
import '../../../custom_widgets/api_response_widget/api_response_widget.dart';
import '../../../custom_widgets/buttons/custom_button.dart';
import '../../../custom_widgets/custom_form_field/custom_form_field.dart';
import '../../../custom_widgets/page_container/page_container.dart';
import '../../../custom_widgets/validation/validation_mixin.dart';
import '../account_app_bar/account_app_bar.dart';
import '../controller/my_account_controller.dart';
import '../widgets/mobile_and_email_contact_us_widget.dart';

class ContactUsScreen extends StatefulWidget {
  static const String routeName = 'ContactUsScreen';
  const ContactUsScreen({super.key});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> with ValidationMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameEc = TextEditingController();
  final _emailEc = TextEditingController();
  final _messages = TextEditingController();
  @override
  dispose() {
    _nameEc.dispose();
    _emailEc.dispose();
    _messages.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (BuildContext context) {
        return MyAccountController()
          ..initialSetting()
          ..getSetting();
      },
      child: Consumer<MyAccountController>(
        builder: (context, myAccountController, _) {
          return Form(
            key: _formKey,
            child: Scaffold(
              body: PageContainer(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      30.sbH,
                      CustomAccountAppBar(title: 'contactUs'.tr),
                      const SizedBox(height: 22),
                      ApiResponseWidget(
                        apiResponse: myAccountController.settingResponse,
                        onReload: myAccountController.getSetting,
                        isEmpty: myAccountController.setting == null,
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
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                                child: Text(
                                  myAccountController.setting?.contactText ?? '',
                                  textAlign: TextAlign.justify,
                                  style: AppTextStyle.text16RS(),
                                ),
                              ),
                              const SizedBox(height: 6),
                              MobileAndEmailContactUsWidget(
                                myAccountController: myAccountController,
                                mobile: myAccountController.setting?.mobile ?? '',
                                email: myAccountController.setting?.email ?? '',
                                adminId: myAccountController.setting?.adminId.toString() ?? '1',
                              ),
                              30.sbH,
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: Column(
                                  children: [
                                    CustomFormField(
                                      controller: _nameEc,
                                      validator: validateEmptyField,
                                      title: 'name'.tr,
                                    ),
                                    const SizedBox(height: 24),
                                    CustomFormField(
                                      controller: _emailEc,
                                      validator: validateEmptyField,
                                      title: 'email'.tr,
                                      keyboardType: TextInputType.emailAddress,
                                    ),
                                    const SizedBox(height: 24),
                                    CustomFormField(
                                      controller: _messages,
                                      validator: validateEmptyField,
                                      maxLines: 5,
                                      title: 'theMessage'.tr,
                                    ),
                                    const SizedBox(height: 24),
                                    CustomButton(
                                      onPressed: () {
                                        if (_formKey.currentState!.validate()) {
                                          context.read<MyAccountController>().storeContact(
                                                name: _nameEc.text,
                                                email: _emailEc.text,
                                                message: _messages.text,
                                                onSuccess: () {
                                                  Navigator.pop(context);
                                                },
                                              );
                                        }
                                      },
                                      text: 'send'.tr,
                                    ),
                                    30.sbH,
                                  ],
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
            ),
          );
        },
      ),
    );
  }
}
