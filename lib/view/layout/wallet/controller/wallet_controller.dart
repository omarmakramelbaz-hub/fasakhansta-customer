import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../../helpers/networking/api_helper.dart';
import '../../../../helpers/networking/urls.dart';
import '../../../../helpers/utils/common_methods.dart';
import '../../../../helpers/utils/utils.dart';
import '../model/wallet_model.dart';

class WalletController extends ChangeNotifier {
  final chargeWalletFormKey = GlobalKey<FormState>();
  final chargeAmountEc = TextEditingController();
  final chargeAmountFocusNode = FocusNode();

  void updateWallet({required WalletModel transaction}) {
    getWallet();
    notifyListeners();
  }

  void initialWallet() {
    _walletResponse = ApiResponse(state: ResponseState.sleep, data: null);
    _wallet = null;
    notifyListeners();
  }

  ApiResponse _walletResponse = ApiResponse(state: ResponseState.sleep, data: null);
  ApiResponse get walletResponse => _walletResponse;
  WalletResponse? _wallet;
  WalletResponse? get wallet => _wallet;

  Future<void> getWallet() async {
    _walletResponse = ApiResponse(state: ResponseState.loading, data: null);
    _wallet = null;
    notifyListeners();
    _walletResponse = await ApiHelper.instance.get(Urls.wallet);
    notifyListeners();
    if (_walletResponse.state == ResponseState.complete) {
      _wallet = WalletResponse.fromJson(_walletResponse.data['data']);
      notifyListeners();
    }
  }

  String? _selectedPayment;
  String? get selectedPayment => _selectedPayment;
  void setSelectedPayment(String value) {
    _selectedPayment = value;
    notifyListeners();
  }

  //=============>  charging wallet  <================
  Future<void> chargingWallet({required dynamic amount, required Function(String link) onSuccess}) async {
    Utils.loading();
    FormData body = FormData.fromMap({'amount': amount, 'payment_method': _selectedPayment});
    final response = await ApiHelper.instance.post(Urls.chargingWallet, body: body);
    Utils.loadingOff();
    if (response.state == ResponseState.complete) {
      // CommonMethods.showToast(message: response.data['message']);
      onSuccess.call(response.data['data']['link']);
    } else {
      CommonMethods.showError(message: response.data['message'], apiResponse: response);
    }
  }

  Future<void> checkMonyTransfer({
    required String mobile,
    required num amount,
    required String accountType,
    required VoidCallback onSuccess,
  }) async {
    Utils.loading();
    FormData body = FormData.fromMap({'mobile': mobile, 'amount': amount, 'account_type': accountType});
    final response = await ApiHelper.instance.post(Urls.checkMonyTransfer, body: body);
    Utils.loadingOff();
    if (response.state == ResponseState.complete) {
      onSuccess.call();
      //  CommonMethods.showToast(message: response.data['message']);
    } else {
      Utils.loadingOff();
      CommonMethods.showError(message: response.data['message'], apiResponse: response);
    }
  }

  Future<void> chargingMonyTransfer({
    required String mobile,
    required num amount,
    required String accountType,
    required VoidCallback onSuccess,
  }) async {
    //  NavigatorMethods.loading();
    FormData body = FormData.fromMap({'mobile': mobile, 'amount': amount, 'account_type': accountType});
    final response = await ApiHelper.instance.post(Urls.transferWallet, body: body);
    Utils.loadingOff();
    if (response.state == ResponseState.complete) {
      CommonMethods.showToast(message: response.data['message']);
      onSuccess.call();
    } else {
      CommonMethods.showError(message: response.data['message'], apiResponse: response);
    }
  }
}
