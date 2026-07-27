import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../helpers/extensions/extensions.dart';
import '../../../../helpers/theme/app_colors.dart';
import '../../../../helpers/translation/all_translation.dart';
import '../../../custom_widgets/buttons/custom_button.dart';
import '../../../custom_widgets/custom_form_field/custom_form_field.dart';
import '../../../custom_widgets/global_widgets/app_bottom_sheet.dart';
import '../../../custom_widgets/validation/validation_mixin.dart';
import '../../auth/controller/auth_controller.dart';

class ChangePasswordBottomSheet extends StatefulWidget {
  const ChangePasswordBottomSheet({super.key});

  @override
  State<ChangePasswordBottomSheet> createState() => _MenuBottomSheetWidgetState();
}

class _MenuBottomSheetWidgetState extends State<ChangePasswordBottomSheet> with ValidationMixin {
  final _formKey = GlobalKey<FormState>();

  final _currentPasswordEC = TextEditingController();
  final _newPasswordEC = TextEditingController();
  final _passwordConfirmationEC = TextEditingController();

  final _currentPasswordFocusNode = FocusNode();
  final _newPasswordECFocusNode = FocusNode();
  final _passwordConfirmationECFocusNode = FocusNode();

  @override
  void dispose() {
    _currentPasswordEC.dispose();
    _newPasswordEC.dispose();
    _passwordConfirmationEC.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppBottomSheet(
      title: 'changePassword'.tr,
      children: [
        Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                20.sbH,
                CustomFormField(
                  validator: (v) => validateEmptyField(v),
                  controller: _currentPasswordEC,
                  title: 'password'.tr,
                  focusNode: _currentPasswordFocusNode,
                  onFieldSubmitted: (_) {
                    FocusScope.of(context).requestFocus(_newPasswordECFocusNode);
                  },
                ),
                20.sbH,
                CustomFormField(
                  controller: _newPasswordEC,
                  title: 'newPassword'.tr,
                  focusNode: _newPasswordECFocusNode,
                  onFieldSubmitted: (_) {
                    FocusScope.of(context).requestFocus(_currentPasswordFocusNode);
                  },
                ),
                20.sbH,
                CustomFormField(
                  controller: _passwordConfirmationEC,
                  title: 'confirmNewPassword'.tr,
                  focusNode: _passwordConfirmationECFocusNode,
                  onFieldSubmitted: (_) {
                    FocusScope.of(context).unfocus();
                  },
                ),
                20.sbH,
                ChangeNotifierProvider(
                  create: (context) => AuthController(),
                  child: Consumer<AuthController>(
                    builder: (context, authController, _) {
                      return CustomButton(
                        gradient: LinearGradient(colors: [AppColors.gridOneButtonColor, AppColors.gridTwoButtonColor]),
                        text: 'save'.tr,
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            authController.changePassword(
                              currentPassword: _currentPasswordEC.text,
                              newPassword: _newPasswordEC.text,
                              confirmPassword: _passwordConfirmationEC.text,
                              onSuccess: () {
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
      ],
    );
  }
}
