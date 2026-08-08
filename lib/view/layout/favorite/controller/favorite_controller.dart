import 'package:flutter/material.dart';

import '../../../../helpers/networking/api_helper.dart';
import '../../../../helpers/networking/urls.dart';
import '../../../../helpers/utils/common_methods.dart';
import '../../../../helpers/utils/utils.dart';
import '../model/favorite_model.dart';

class FavoriteController extends ChangeNotifier {
  void initialFavorite() {
    _favoriteResponse = ApiResponse(state: ResponseState.sleep, data: null);
    _favorite = [];
    notifyListeners();
  }

  ApiResponse _favoriteResponse = ApiResponse(state: ResponseState.sleep, data: null);
  ApiResponse get favoriteResponse => _favoriteResponse;

  List<FavoriteModel> _favorite = [];
  List<FavoriteModel> get favorite => _favorite;

  Future<void> getFavorite() async {
    _favoriteResponse = ApiResponse(state: ResponseState.loading, data: null);
    _favorite = [];
    notifyListeners();

    _favoriteResponse = await ApiHelper.instance.get(Urls.productFavorite);

    if (_favoriteResponse.state == ResponseState.complete) {
      final data = _favoriteResponse.data['data'];
      if (data is Iterable) {
        _favorite = data.map((e) => FavoriteModel.fromJson(e)).toList();
      }
    }
    notifyListeners();
  }

  Future<void> addOrRemoveToWishlist({required int id, required VoidCallback onSuccess}) async {
    Utils.loading();
    final response = await ApiHelper.instance.post(Urls.toggleProductFavorite(id));
    Utils.loadingOff();

    if (response.state == ResponseState.complete) {
      CommonMethods.showToast(message: response.data['message']);
      _favorite.removeWhere((item) => item.id == id);
      onSuccess.call();
      notifyListeners();
    } else {
      CommonMethods.showError(message: response.data['message'], apiResponse: response);
    }
  }

  Future<void> addOrRemoveProductFavorite({required int id}) async {
    await addOrRemoveToWishlist(id: id, onSuccess: () {});
  }
}
