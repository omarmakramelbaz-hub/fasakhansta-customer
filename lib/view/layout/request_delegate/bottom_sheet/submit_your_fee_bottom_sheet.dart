import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../helpers/extensions/extensions.dart';
import '../../../../helpers/routes/app_routers_import.dart';
import '../../../../helpers/theme/app_text_style.dart';
import '../../../../helpers/translation/all_translation.dart';
import '../../../custom_widgets/buttons/custom_button.dart';
import '../../../custom_widgets/custom_form_field/custom_form_field.dart';
import '../../../custom_widgets/global_widgets/dark_app_bottom_sheet.dart';
import '../controller/request_delegate_controller.dart';
import '../widget/payment_methoud_widget.dart';

class SubmitYourFeeBottomSheet extends StatefulWidget {
  const SubmitYourFeeBottomSheet({
    super.key,
    required this.requestDelegateController,
    required this.kmPrice,
    required this.shippingPercentage,
    required this.distance,
  });
  final RequestDelegateController requestDelegateController;
  final num kmPrice;
  final num shippingPercentage;
  final num distance;

  @override
  State<SubmitYourFeeBottomSheet> createState() => _SubmitYourFeeBottomSheetState();
}

class _SubmitYourFeeBottomSheetState extends State<SubmitYourFeeBottomSheet> {
  final TextEditingController _feeEC = TextEditingController();
  final FocusNode focusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();

  late final double _referenceFare;
  late final double _minimumFare;

  @override
  void initState() {
    super.initState();

    _feeEC.text = widget.requestDelegateController.priceEC.text;

    final currentFare =
        double.tryParse(widget.requestDelegateController.priceEC.text.trim()) ?? 0;
    final storedCalculatedFare = widget.distance.toDouble();

    // Use the strongest available reference so reopening the sheet cannot
    // repeatedly reduce an already discounted fare.
    _referenceFare = math.max(currentFare, storedCalculatedFare);
    _minimumFare = (_referenceFare * .90).ceilToDouble();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<RequestDelegateController>();
      }
    });
  }

  String? _validateFare(String? value) {
    final inputValue = double.tryParse((value ?? '').trim());

    if (inputValue == null) {
      return 'enterAmount'.tr;
    }

    if (_referenceFare > 0 && inputValue < _minimumFare) {
      return 'minimumAmountToDeliver'
          .tr
          .replaceAll('{}', _minimumFare.toStringAsFixed(0));
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: DarkAppBottomSheet(
        isDark: true,
        title: 'providePrice'.tr,
        showBorder: true,
        children: [
          CustomFormField(
            controller: _feeEC,
            hintText: 'egyptianPound'.tr,
            formFieldBorder: FormFieldBorder.underLine,
            textStyle: AppTextStyle.text14MW(),
            keyboardType: TextInputType.number,
            unFocusColor: Colors.transparent,
            focusNode: focusNode,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: _validateFare,
            suffixIcon: Text(
              'egyptianPound'.tr,
              style: AppTextStyle.text14MW().copyWith(fontSize: 16),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: 15.sbH,
          ),
          const ChoosePaymentMethodWidget(),
          15.sbH,
          CustomButton(
            text: 'confirmOrder'.tr,
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                widget.requestDelegateController.setPriceEC(_feeEC.text);
                widget.requestDelegateController.setActualPrice(_feeEC.text);
                NamedNavigatorImpl.pop();
              }
            },
          ),
          15.sbH,
        ],
      ),
    );
  }
}
