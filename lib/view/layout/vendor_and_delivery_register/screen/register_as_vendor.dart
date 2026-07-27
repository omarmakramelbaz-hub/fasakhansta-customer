import 'dart:developer';
import 'dart:io';

import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
import '../../../custom_widgets/global_widgets/custom_image_container.dart';
import '../../../custom_widgets/validation/validation_mixin.dart';
import '../../bottom_navigation/bottom_navigation_bar_screen.dart';
import '../controller/vendor_and_delivery_controller.dart';
import 'contract_vendor_screen.dart';

class RegisterAsVendorScreen extends StatefulWidget {
  static const String routeName = 'RegisterAsVendorScreen';

  const RegisterAsVendorScreen({super.key});

  @override
  State<RegisterAsVendorScreen> createState() => _RegisterAsVendorScreenState();
}

class _RegisterAsVendorScreenState extends State<RegisterAsVendorScreen> with ValidationMixin {
  final _formKey = GlobalKey<FormState>();

  // Text Editing Controllers
  final _merchantNameEc = TextEditingController();
  final _ownerNameEc = TextEditingController();
  final _branchesCountEc = TextEditingController();
  final _nationalIdEc = TextEditingController();
  final _taxIdEc = TextEditingController();
  final _commercialRegistrationEc = TextEditingController();
  final _phoneNumberOneEc = TextEditingController();
  final _phoneNumberTwoEc = TextEditingController();
  final _vodafoneCashNumber = TextEditingController();
  final _emailEc = TextEditingController();

  // FocusNodes
  final _merchantNameFocus = FocusNode();
  final _ownerNameFocus = FocusNode();
  final _branchesCountFocus = FocusNode();
  final _nationalIdFocus = FocusNode();
  final _taxIdFocus = FocusNode();
  final _commercialRegistrationFocus = FocusNode();
  final _phoneNumberOneFocus = FocusNode();
  final _phoneNumberTwoFocus = FocusNode();
  final _vodafoneCashFocus = FocusNode();
  final _emailFocus = FocusNode();

  File? _idImage;
  File? _taxImage;
  File? _commercialRegistrationImage;
  Country? _country;

  @override
  void initState() {
    _country = CountryParser.parsePhoneCode('20');
    super.initState();
  }

  @override
  void dispose() {
    // Dispose Controllers and FocusNodes
    _merchantNameEc.dispose();
    _ownerNameEc.dispose();
    _branchesCountEc.dispose();
    _nationalIdEc.dispose();
    _taxIdEc.dispose();
    _commercialRegistrationEc.dispose();
    _phoneNumberOneEc.dispose();
    _phoneNumberTwoEc.dispose();
    _vodafoneCashNumber.dispose();
    _emailEc.dispose();

    _merchantNameFocus.dispose();
    _ownerNameFocus.dispose();
    _branchesCountFocus.dispose();
    _nationalIdFocus.dispose();
    _taxIdFocus.dispose();
    _commercialRegistrationFocus.dispose();
    _phoneNumberOneFocus.dispose();
    _phoneNumberTwoFocus.dispose();
    _vodafoneCashFocus.dispose();
    _emailFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isChecked = false;
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) => setState(() {}),
      child: Scaffold(
        appBar: CustomAppBar(
          title: const CustomImage(path: AppImages.appLogo, type: ImageType.asset, height: 55, radius: 12),
          appBarColor: AppColors.whiteColor,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: AppColors.blackColor),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 21),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 25),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text('startAsMerchant'.tr, style: AppTextStyle.text20BS()),
                  ),
                  const SizedBox(height: 23),
                  CustomFormField(
                    controller: _merchantNameEc,
                    focusNode: _merchantNameFocus,
                    title: 'merchantName'.tr,
                    validator: validateName,
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).requestFocus(_ownerNameFocus);
                    },
                  ),
                  const SizedBox(height: 23),
                  CustomFormField(
                    controller: _ownerNameEc,
                    focusNode: _ownerNameFocus,
                    title: 'ownerName'.tr,
                    validator: validateName,
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).requestFocus(_branchesCountFocus);
                    },
                  ),
                  const SizedBox(height: 23),
                  CustomFormField(
                    controller: _branchesCountEc,
                    focusNode: _branchesCountFocus,
                    title: 'branchesCount'.tr,
                    validator: validateEmptyField,
                    keyboardType: TextInputType.number,
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).requestFocus(_nationalIdFocus);
                    },
                  ),
                  const SizedBox(height: 23),
                  CustomFormField(
                    controller: _nationalIdEc,
                    focusNode: _nationalIdFocus,
                    title: 'nationalId'.tr,
                    validator: validateNationalId,
                    keyboardType: TextInputType.number,
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).requestFocus(_taxIdFocus);
                    },
                  ),
                  const SizedBox(height: 23),
                  CustomFormField(
                    controller: _taxIdEc,
                    focusNode: _taxIdFocus,
                    title: 'taxNumber'.tr,
                    validator: validateEmptyField,
                    keyboardType: TextInputType.number,
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).requestFocus(_commercialRegistrationFocus);
                    },
                  ),
                  const SizedBox(height: 23),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('nationalIdImage'.tr, style: AppTextStyle.text16RS()),
                      const SizedBox(width: 1),
                      Text('taxNumberImage'.tr, style: AppTextStyle.text16RS()),
                      const SizedBox(width: 1),
                    ],
                  ),
                  15.sbH,
                  //========================== images (nationalIdImage, taxNumberImage ) ===========================
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomImageContainer(image: _idImage, onSuccess: (v) => setState(() => _idImage = v)),
                      CustomImageContainer(image: _taxImage, onSuccess: (v) => setState(() => _taxImage = v)),
                    ],
                  ),
                  const SizedBox(height: 23),
                  CustomFormField(
                    controller: _commercialRegistrationEc,
                    focusNode: _commercialRegistrationFocus,
                    title: 'commercialRegistrationNumber'.tr,
                    validator: validateEmptyField,
                    keyboardType: TextInputType.number,
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).requestFocus(_phoneNumberOneFocus);
                    },
                  ),
                  const SizedBox(height: 23),
                  Text('commercialRegistrationImage'.tr, style: AppTextStyle.text16RS()),
                  15.sbH,
                  CustomImageContainer(
                    image: _commercialRegistrationImage,
                    onSuccess: (v) {
                      setState(() {
                        _commercialRegistrationImage = v;
                      });
                    },
                  ),
                  const SizedBox(height: 23),
                  CustomFormField(
                    validator: (v) => validatePhone(v, country: _country),
                    controller: _phoneNumberOneEc,
                    focusNode: _phoneNumberOneFocus,
                    title: 'firstPhoneNumber'.tr,
                    keyboardType: TextInputType.phone,
                    country: _country,
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).requestFocus(_phoneNumberTwoFocus);
                    },
                  ),
                  const SizedBox(height: 23),
                  CustomFormField(
                    // //  validator: (v) => validatePhone(v, country: _country),
                    controller: _phoneNumberTwoEc,
                    focusNode: _phoneNumberTwoFocus,
                    title: 'secondPhoneNumber'.tr,
                    keyboardType: TextInputType.phone,
                    country: _country,
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).requestFocus(_vodafoneCashFocus);
                    },
                  ),
                  const SizedBox(height: 23),
                  CustomFormField(
                    validator: (v) => validateVCash(v, country: _country),
                    controller: _vodafoneCashNumber,
                    focusNode: _vodafoneCashFocus,
                    title: 'vodafonCashNumber'.tr,
                    keyboardType: TextInputType.number,
                    country: _country,
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).requestFocus(_emailFocus);
                    },
                  ),
                  const SizedBox(height: 23),
                  CustomFormField(
                    validator: validateEmail,
                    controller: _emailEc,
                    focusNode: _emailFocus,
                    title: 'email'.tr,
                    keyboardType: TextInputType.emailAddress,
                    onFieldSubmitted: (_) {
                      // Unfocus the field or submit the form
                      FocusScope.of(context).unfocus();
                    },
                  ),
                  const SizedBox(height: 23),
                  ChangeNotifierProvider(
                    create: (context) => VendorAndDeliveryController(),
                    child: Builder(
                      builder: (context) {
                        return CustomButton(
                          text: 'next'.tr,
                          onPressed: () {
                            if (_idImage == null || _taxImage == null || _commercialRegistrationImage == null) {
                              CommonMethods.showError(message: 'youMustAddAllImages'.tr);
                            }
                            log(isChecked.toString());
                            if (_formKey.currentState!.validate() &&
                                _idImage != null &&
                                _taxImage != null &&
                                _commercialRegistrationImage != null) {
                              NamedNavigatorImpl.push(
                                ContractVendorScreen.routeName,
                                arguments: ContractVendorArgs(
                                  vendorName: _merchantNameEc.text,
                                  vendorOwnerName: _ownerNameEc.text,
                                  vendorNational: _nationalIdEc.text,
                                  vendorCommercialRegistrationNo: _commercialRegistrationEc.text,
                                  vendorTaxNo: _taxIdEc.text,
                                  vendorMobile: _phoneNumberOneEc.text,
                                  vendorEmail: _emailEc.text,
                                  vendorVodafoneCash: _vodafoneCashNumber.text,
                                  onConfirm: () {
                                    context.read<VendorAndDeliveryController>().vendorRegister(
                                          fullName: _merchantNameEc.text,
                                          ownerName: _ownerNameEc.text,
                                          branchesNo: int.tryParse(_branchesCountEc.text.toString())!,
                                          nationalId: int.tryParse(_nationalIdEc.text.toString())!,
                                          commercialRegistrationNo: _commercialRegistrationEc.text,
                                          nationalIdImage: _idImage!,
                                          commercialRegistrationNoImage: _commercialRegistrationImage!,
                                          taxNo: _taxIdEc.text,
                                          taxNoImage: _taxImage!,
                                          estMobile: _phoneNumberOneEc.text,
                                          sndMobile: _phoneNumberTwoEc.text,
                                          vodafoneCashMobile: _vodafoneCashNumber.text,
                                          email: _emailEc.text,
                                          onSuccess: () {
                                            NamedNavigatorImpl.push(
                                              clean: true,
                                              BottomNavigationBarScreen.routeName,
                                            );
                                          },
                                        );
                                  },
                                ),
                              );
                            }
                          },
                        );
                      },
                    ),
                  ),
                  30.sbH,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
