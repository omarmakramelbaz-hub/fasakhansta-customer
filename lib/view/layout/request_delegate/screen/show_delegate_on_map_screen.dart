import 'dart:async';

import 'package:defer_pointer/defer_pointer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../helpers/extensions/extensions.dart';
import '../../../../helpers/routes/app_routers_import.dart';
import '../../../../helpers/theme/app_colors.dart';
import '../../../../helpers/theme/app_text_style.dart';
import '../../../../helpers/translation/all_translation.dart';
import '../../../../helpers/utils/common_methods.dart';
import '../../../custom_widgets/buttons/custom_button.dart';
import '../../../custom_widgets/custom_form_field/custom_form_field.dart';
import '../../../custom_widgets/validation/validation_mixin.dart';
import '../../bottom_navigation/bottom_navigation_bar_screen.dart';
import '../controller/request_delegate_controller.dart';
import '../model/accepted_delegate_model.dart';
import '../widget/custom_google_maps_widget.dart';
import '../widget/delegate_offer_widget.dart';

class ShowDelegateOnMapArgs {
  final num kmPrice;
  final num shippingPercentage;
  final num distance;
  final num fee;
  final int? orderId;

  ShowDelegateOnMapArgs({
    required this.kmPrice,
    required this.shippingPercentage,
    required this.distance,
    required this.fee,
    this.orderId,
  });
}

class ShowDelegateOnMapScreen extends StatefulWidget {
  static const String routeName = 'ShowDelegateOnMapScreen';

  const ShowDelegateOnMapScreen({super.key, required this.args});

  final ShowDelegateOnMapArgs args;

  @override
  State<ShowDelegateOnMapScreen> createState() => _ShowDelegateOnMapScreenState();
}

class _ShowDelegateOnMapScreenState extends State<ShowDelegateOnMapScreen> with ValidationMixin {
  final TextEditingController _feeEC = TextEditingController();
  final FocusNode focusNode = FocusNode();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late RequestDelegateController requestDelegateController;
  Timer? _checkDelegateTimer;
  Timer? _fiveMinuteTimer;
  List<Delegates>? acceptedDelegates;

  @override
  void initState() {
    requestDelegateController = context.read<RequestDelegateController>();
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RequestDelegateController>().initialAcceptedDelegate();
      _fetchAcceptedDelegates();
      _feeEC.text = requestDelegateController.priceEC.text;
      _startCheckingAcceptedDelegate();
      _startFiveMinuteTimer();
    });
  }

  Future<void> _fetchAcceptedDelegates() async {
    try {
      await context.read<RequestDelegateController>().getAcceptedDelegate(delegateOrderId: widget.args.orderId).then((
        _,
      ) {
        if (mounted) {
          setState(() {
            acceptedDelegates = requestDelegateController.acceptedDelegate?.delegates ?? [];
          });
        }
        if (widget.args.orderId != null || widget.args.orderId != 0) {
          final order = requestDelegateController.acceptedDelegate!.order;
          requestDelegateController.setFromLat(order?.fromLat.toString() ?? '0.0');
          requestDelegateController.setFromLan(order?.fromLng.toString() ?? '0.0');
          requestDelegateController.setToLat(order?.toLat.toString() ?? '0.0');
          requestDelegateController.setToLan(order?.toLng.toString() ?? '0.0');
          _feeEC.text = requestDelegateController.acceptedDelegate!.order!.actualPrice.toString();
          requestDelegateController.calculateDeliveryPrice(kmPrice: widget.args.kmPrice);
        }
      });
    } catch (e) {
      // CommonMethods.showError(message: "Error fetching delegates: $e");
    }
  }

  void _startCheckingAcceptedDelegate() {
    _checkDelegateTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      try {
        await _checkAcceptedDelegate();
        if (mounted) {
          setState(() {
            acceptedDelegates = requestDelegateController.acceptedDelegate?.delegates ?? [];
          });
        }
      } catch (e) {
        // CommonMethods.showError(message: "Error checking delegates: $e");
      }
    });
  }

  void _startFiveMinuteTimer() {
    _fiveMinuteTimer = Timer(const Duration(minutes: 5), () {
      CommonMethods.showError(message: 'noDelegateAvailable'.tr);
      _cancelTimersAndOrder();
      requestDelegateController.cancelOrder(
        orderId: widget.args.orderId!,
        onSuccess: () {
          requestDelegateController.setFee('0.0');
          NamedNavigatorImpl.push(clean: true, BottomNavigationBarScreen.routeName);
        },
      );
    });
  }

  //   Future<void> getAcceptedDelegate({int? delegateOrderId}) async {
  //   // Fetch data and update `acceptedDelegate`
  //   final result = await fetchAcceptedDelegateData(delegateOrderId);
  //   if (result != null) {
  //     acceptedDelegate = result;
  //     notifyListeners(); // Ensure that the UI listens to changes
  //   }
  // }

  Future<void> _checkAcceptedDelegate() async {
    try {
      await requestDelegateController.getAcceptedDelegate(delegateOrderId: widget.args.orderId);
      if (requestDelegateController.acceptedDelegate?.delegates?.isNotEmpty == true) {
        setState(() {
          acceptedDelegates = requestDelegateController.acceptedDelegate?.delegates ?? [];
        });
      }
    } catch (e) {
      // CommonMethods.showError(message: "Error checking delegates: $e");
    }
  }

  void _resetFiveMinuteTimer() {
    _fiveMinuteTimer?.cancel();
    _fiveMinuteTimer = Timer(const Duration(minutes: 5), () {
      CommonMethods.showError(message: 'noDelegateAvailable'.tr);
      _cancelTimersAndOrder();
      requestDelegateController.cancelOrder(
        orderId: widget.args.orderId!,
        onSuccess: () {
          requestDelegateController.setFee('0.0');
          NamedNavigatorImpl.push(clean: true, BottomNavigationBarScreen.routeName);
        },
      );
    });
  }

  void _resetCheckDelegateTimer() {
    _checkDelegateTimer?.cancel();
    _checkDelegateTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      try {
        await _checkAcceptedDelegate();
        setState(() {
          if (mounted) {
            acceptedDelegates = requestDelegateController.acceptedDelegate?.delegates ?? [];
          }
        });
      } catch (e) {
        if (mounted) {
          // CommonMethods.showError(message: "Error checking delegates: $e");
        }
      }
    });
  }

  void _cancelTimersAndOrder() {
    _checkDelegateTimer?.cancel();
    _fiveMinuteTimer?.cancel();
    requestDelegateController.setFee('0.0');
    // requestDelegateController.cancelOrder(
    //     orderId: widget.args.orderId!,
    //     onSuccess: () {
    //       NavigatorMethods.pop(context);
    //     });
  }

  @override
  void dispose() {
    _checkDelegateTimer?.cancel();
    _fiveMinuteTimer?.cancel();
    _feeEC.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        if (didPop) {
          _cancelTimersAndOrder();
          _checkDelegateTimer?.cancel();
          _fiveMinuteTimer?.cancel();
          requestDelegateController.setDistance(0.0);
          requestDelegateController.setFee('0.0');

          // requestDelegateController.reset();
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Form(
          key: _formKey,
          child: DeferredPointerHandler(
            child: Stack(
              children: [
                CustomGoogleMapsWidget(
                  showCircle: true,
                  addressLat: double.tryParse('${requestDelegateController.acceptedDelegate?.order?.fromLat}') ??
                      double.tryParse('${requestDelegateController.fromLat}') ??
                      0.0,
                  addressLan: double.tryParse('${requestDelegateController.acceptedDelegate?.order?.fromLng}') ??
                      double.tryParse('${requestDelegateController.fromLan}') ??
                      0.0,
                ),
                Positioned.fill(
                  top: 20,
                  left: 0,
                  right: 0,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        ...List.generate(
                          acceptedDelegates?.length ?? 0,
                          (index) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: DeferPointer(
                              child: DelegateOfferWidget(
                                onReject: () {
                                  setState(() {
                                    acceptedDelegates?.removeWhere((i) => i.id == acceptedDelegates?[index].id);
                                  });
                                },
                                order: requestDelegateController.acceptedDelegate?.order,
                                acceptedDelegateModel: acceptedDelegates?[index],
                                cancelReCall: () {
                                  _cancelTimersAndOrder();
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  left: 0,
                  // child: ApiResponseWidget(
                  //   apiResponse:
                  //       requestDelegateController.acceptedDelegateApiResponse,
                  //   onReload: () =>
                  //       requestDelegateController.getAcceptedDelegate(),
                  //   isEmpty: requestDelegateController.acceptedDelegate == null,
                  //   loadingWidget: CustomShimmer(
                  //     height: context.height * 0.32,
                  //     width: context.width,
                  //     shimmerColor: AppColor.lightDarkColor,
                  //     radius: 25,
                  //   ),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.blackColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Center(child: Text('providePrice'.tr, style: AppTextStyle.text14MW())),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  if (((requestDelegateController.acceptedDelegate?.order?.actualPrice)! -
                                          (int.parse(_feeEC.text))) <
                                      (requestDelegateController.acceptedDelegate?.order?.userBalance)!) {
                                    setState(() {
                                      int currentValue = int.parse(_feeEC.text);
                                      currentValue += 1;
                                      _feeEC.text = currentValue.toString();
                                    });
                                  } else {
                                    CommonMethods.showError(message: 'notEnoughBalance'.tr);
                                  }
                                },
                                child: Card(
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(12)),
                                  ),
                                  color: AppColors.mainAppColor,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                                    child: Text('1+', style: AppTextStyle.text14MW().copyWith(fontSize: 25)),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  children: [
                                    20.sbH,
                                    Padding(
                                      padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
                                      child: CustomFormField(
                                        controller: _feeEC,
                                        hintText: 'egyptianPound'.tr,
                                        formFieldBorder: FormFieldBorder.underLine,
                                        textStyle: AppTextStyle.text14MW(),
                                        keyboardType: TextInputType.number,
                                        unFocusColor: Colors.transparent,
                                        focusNode: focusNode,
                                        otherSideTitle: 'egyptianPound'.tr,
                                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                        validator: (v) => validateFeeInShowDelegate(
                                          paymentType: requestDelegateController.acceptedDelegate?.order?.paymentType,
                                          actualPrice:
                                              requestDelegateController.acceptedDelegate?.order?.actualPrice ?? 0,
                                          userBalance:
                                              requestDelegateController.acceptedDelegate?.order?.userBalance ?? 0,
                                          value: _feeEC.text,
                                          distance: requestDelegateController.acceptedDelegate?.order?.expectedPrice ??
                                              requestDelegateController.distance ??
                                              0,
                                          percentage: widget.args.shippingPercentage,
                                          kmPrice: widget.args.kmPrice,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    int currentValue = int.tryParse(_feeEC.text) ?? 0;
                                    num actualPrice =
                                        requestDelegateController.acceptedDelegate!.order!.actualPrice ?? 0;
                                    if (currentValue > 0 && currentValue > actualPrice) {
                                      currentValue -= 1;
                                    }
                                    _feeEC.text = currentValue.toString();
                                  });
                                },
                                child: Card(
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(12)),
                                  ),
                                  color: requestDelegateController.acceptedDelegate?.order?.actualPrice ==
                                          int.tryParse(_feeEC.text)
                                      ? AppColors.darkGreyColor
                                      : AppColors.mainAppColor,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                                    child: Text('1-', style: AppTextStyle.text14MW().copyWith(fontSize: 25)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                            child: 15.sbH,
                          ),
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: CustomButton(
                                  text: 'riseUpFee'.tr,
                                  onPressed: () async {
                                    if (_formKey.currentState!.validate()) {
                                      await requestDelegateController.riseActualPrice(
                                        newPrice: int.parse(_feeEC.text),
                                        onSuccess: () async {
                                          requestDelegateController.setPriceEC(_feeEC.text);
                                          requestDelegateController.setActualPrice(_feeEC.text);

                                          // Reset the timers to start fresh
                                          _resetFiveMinuteTimer();
                                          _resetCheckDelegateTimer();

                                          // Refresh accepted delegates data
                                          await _fetchAcceptedDelegates();
                                        },
                                      );
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                flex: 1,
                                child: Consumer<RequestDelegateController>(
                                  builder: (context, requestDelegateController, _) {
                                    return CustomButton(
                                      text: 'cancelOrder'.tr,
                                      gradient: LinearGradient(
                                        colors: [AppColors.darkGreyColor, AppColors.darkGreyColor],
                                      ),
                                      onPressed: () {
                                        _cancelTimersAndOrder();
                                        requestDelegateController.cancelOrder(
                                          orderId: widget.args.orderId!,
                                          onSuccess: () =>
                                              NamedNavigatorImpl.push(clean: true, BottomNavigationBarScreen.routeName),
                                        );
                                      },
                                      style: AppTextStyle.text16BW(),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                          15.sbH,
                        ],
                      ),
                    ),
                  ),
                  // ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
