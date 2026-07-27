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
import 'contract_delivery_screen.dart';

class RegisterAsDeliveryScreen extends StatefulWidget {
  static const String routeName = 'RegisterAsDeliveryScreen';

  const RegisterAsDeliveryScreen({super.key});

  @override
  State<RegisterAsDeliveryScreen> createState() => _RegisterAsDeliveryScreenState();
}

class _RegisterAsDeliveryScreenState extends State<RegisterAsDeliveryScreen> with ValidationMixin {
  final _formKey = GlobalKey<FormState>();

  final _nameQuadrilateralEc = TextEditingController();
  final _nationalIdEc = TextEditingController();
  final _drivingLicenseNumberEc = TextEditingController();
  final _workAreaEc = TextEditingController();
  final _phoneNumberOneEc = TextEditingController();
  final _phoneNumberTwoEc = TextEditingController();
  final _vodafoneCashNumber = TextEditingController();
  final _emailEc = TextEditingController();

  File? _nationalIdImage;
  File? _drivingLicenseImage;
  Country? _country;

  // FocusNodes
  final _nameQuadrilateralFocusNode = FocusNode();
  final _nationalIdFocusNode = FocusNode();
  final _drivingLicenseFocusNode = FocusNode();
  final _workAreaFocusNode = FocusNode();
  final _phoneNumberOneFocusNode = FocusNode();
  final _phoneNumberTwoFocusNode = FocusNode();
  final _vodafoneCashFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();

  @override
  void initState() {
    _country = CountryParser.parsePhoneCode('20');
    super.initState();
  }

  @override
  void dispose() {
    // Dispose controllers
    _nameQuadrilateralEc.dispose();
    _nationalIdEc.dispose();
    _drivingLicenseNumberEc.dispose();
    _workAreaEc.dispose();
    _phoneNumberOneEc.dispose();
    _phoneNumberTwoEc.dispose();
    _vodafoneCashNumber.dispose();
    _emailEc.dispose();

    // Dispose FocusNodes
    _nameQuadrilateralFocusNode.dispose();
    _nationalIdFocusNode.dispose();
    _drivingLicenseFocusNode.dispose();
    _workAreaFocusNode.dispose();
    _phoneNumberOneFocusNode.dispose();
    _phoneNumberTwoFocusNode.dispose();
    _vodafoneCashFocusNode.dispose();
    _emailFocusNode.dispose();

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
                children: <Widget>[
                  const SizedBox(height: 25),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text('startAsDeliveryMan'.tr, style: AppTextStyle.text20BS()),
                  ),
                  const SizedBox(height: 23),
                  CustomFormField(
                    controller: _nameQuadrilateralEc,
                    title: 'nameQuadrilateral'.tr,
                    validator: validateNameFourthly,
                    focusNode: _nameQuadrilateralFocusNode,
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).requestFocus(_nationalIdFocusNode);
                    },
                  ),
                  const SizedBox(height: 23),
                  CustomFormField(
                    controller: _nationalIdEc,
                    title: 'nationalId'.tr,
                    validator: validateNationalId,
                    keyboardType: TextInputType.number,
                    focusNode: _nationalIdFocusNode,
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).requestFocus(_drivingLicenseFocusNode);
                    },
                  ),
                  const SizedBox(height: 23),
                  CustomFormField(
                    controller: _drivingLicenseNumberEc,
                    title: 'drivingLicenseNumber'.tr,
                    validator: validateEmptyField,
                    keyboardType: TextInputType.number,
                    focusNode: _drivingLicenseFocusNode,
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).requestFocus(_workAreaFocusNode);
                    },
                  ),

                  const SizedBox(height: 23),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('nationalIdImage'.tr, style: AppTextStyle.text16RS()),
                      const SizedBox(width: 1),
                      Text('drivingLicense'.tr, style: AppTextStyle.text16RS()),
                      const SizedBox(width: 1),
                    ],
                  ),
                  15.sbH,
                  //========================== images (nationalIdImage, taxNumberImage ) ===========================
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomImageContainer(
                        image: _nationalIdImage,
                        onSuccess: (v) => setState(() => _nationalIdImage = v),
                      ),
                      CustomImageContainer(
                        image: _drivingLicenseImage,
                        onSuccess: (v) => setState(() => _drivingLicenseImage = v),
                      ),
                    ],
                  ),
                  const SizedBox(height: 23),
                  CustomFormField(
                    controller: _workAreaEc,
                    title: 'workArea'.tr,
                    validator: validateEmptyField,
                    focusNode: _workAreaFocusNode,
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).requestFocus(_phoneNumberOneFocusNode);
                    },
                  ),
                  const SizedBox(height: 23),
                  CustomFormField(
                    validator: (v) => validatePhone(v, country: _country),
                    controller: _phoneNumberOneEc,
                    title: 'firstPhoneNumber'.tr,
                    keyboardType: TextInputType.phone,
                    country: _country,
                    focusNode: _phoneNumberOneFocusNode,
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).requestFocus(_phoneNumberTwoFocusNode);
                    },
                  ),
                  const SizedBox(height: 23),
                  CustomFormField(
                    //    validator: (v) => validatePhone(v, country: _country),
                    controller: _phoneNumberTwoEc,
                    title: 'secondPhoneNumber'.tr,
                    keyboardType: TextInputType.phone,
                    country: _country,
                    focusNode: _phoneNumberTwoFocusNode,
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).requestFocus(_vodafoneCashFocusNode);
                    },
                  ),
                  const SizedBox(height: 23),
                  CustomFormField(
                    validator: (v) => validateVCash(v, country: _country),
                    controller: _vodafoneCashNumber,
                    title: 'vodafonCashNumber'.tr,
                    keyboardType: TextInputType.phone,
                    country: _country,
                    focusNode: _vodafoneCashFocusNode,
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).requestFocus(_emailFocusNode);
                    },
                  ),
                  const SizedBox(height: 23),
                  CustomFormField(
                    validator: validateEmptyField,
                    controller: _emailEc,
                    title: 'email'.tr,
                    keyboardType: TextInputType.emailAddress,
                    focusNode: _emailFocusNode,
                    onFieldSubmitted: (_) {},
                  ),
                  const SizedBox(height: 23),
                  ChangeNotifierProvider(
                    create: (context) => VendorAndDeliveryController(),
                    child: Builder(
                      builder: (context) {
                        return CustomButton(
                          text: 'next'.tr,
                          onPressed: () {
                            if (_nationalIdImage == null || _drivingLicenseImage == null) {
                              CommonMethods.showError(message: 'youMustAddAllImages'.tr);
                            }
                            log(isChecked.toString());
                            if (_formKey.currentState!.validate() &&
                                _nationalIdImage != null &&
                                _drivingLicenseImage != null) {
                              NamedNavigatorImpl.push(
                                ContractDeliveryScreen.routeName,
                                arguments: ContractDeliveryArgs(
                                  name: _nameQuadrilateralEc.text,
                                  nationalId: _nationalIdEc.text.toString(),
                                  drivingLicenseNo: _drivingLicenseNumberEc.text,
                                  email: _emailEc.text,
                                  mobile: _phoneNumberOneEc.text,
                                  vodafoneCash: _vodafoneCashNumber.text,
                                  onConfirm: () {
                                    context.read<VendorAndDeliveryController>().deliveryRegister(
                                          fullName: _nameQuadrilateralEc.text,
                                          drivingLicenseImage: _drivingLicenseImage!,
                                          nationalId: int.tryParse(_nationalIdEc.text.toString())!,
                                          drivingLicenseNo: _drivingLicenseNumberEc.text,
                                          nationalIdImage: _nationalIdImage!,
                                          workArea: _workAreaEc.text,
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
