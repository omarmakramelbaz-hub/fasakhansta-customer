import 'dart:async';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

import '../../view/custom_widgets/custom_toast/custom_toast.dart';
import '../networking/api_helper.dart';
import '../routes/app_routers_import.dart';
import '../theme/app_colors.dart';
import '../translation/all_translation.dart';

class CommonMethods {
  static void showAlertDialog({String? title, required String message}) {
    showCupertinoDialog(
      context: NamedNavigatorImpl.navigatorState.currentContext!,
      builder: (context) => CupertinoAlertDialog(
        title: title != null
            ? Text(
                title,
                style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w700),
              )
            : null,
        content: Text(
          message,
          style: const TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.w500),
        ),
        actions: [
          CupertinoDialogAction(
            child: Text(
              'ok'.tr,
              style: const TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.w700),
            ),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );
  }

  static void showChooseDialog(
    BuildContext context, {
    String? title,
    required String message,
    required VoidCallback onPressed,
  }) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: title != null
            ? Text(
                title,
                style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w700),
              )
            : null,
        content: Text(
          message,
          style: const TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.w500),
        ),
        actions: [
          CupertinoDialogAction(
            child: Text(
              'no'.tr,
              style: TextStyle(color: AppColors.darkTextColor, fontSize: 16, fontWeight: FontWeight.w700),
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          CupertinoDialogAction(
            onPressed: onPressed,
            child: Text(
              'yes'.tr,
              style: TextStyle(color: AppColors.darkTextColor, fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  static void showToast({
    required String message,
    String? title,
    String? icon,
    ToastType type = ToastType.success,
    Color? backgroundColor,
    Color? textColor,
    int seconds = 3,
  }) {
    final isAddToCartSuccess = type == ToastType.success && message.contains('إضاف') && message.contains('السلة');
    if (isAddToCartSuccess) {
      showCartSuccess(message: message, seconds: seconds);
      return;
    }

    BotToast.showCustomText(
      duration: Duration(seconds: seconds),
      toastBuilder: (cancelFunc) => SizedBox(
        height: 80,
        child: CustomToast(
          type: type,
          title: title,
          message: message,
          backgroundColor: backgroundColor,
          icon: icon,
          textColor: textColor,
        ),
      ),
    );
  }

  static void showCartSuccess({required String message, int seconds = 3}) {
    BotToast.showCustomText(
      duration: Duration(seconds: seconds),
      toastBuilder: (cancelFunc) => Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 14),
          padding: const EdgeInsets.fromLTRB(12, 12, 14, 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFDCEFE3)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x22000000),
                blurRadius: 20,
                offset: Offset(0, 7),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: Color(0xFFE7F7ED),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Color(0xFF16A45B),
                  size: 30,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'تمت الإضافة إلى السلة',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Color(0xFF163A26),
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      message,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF7B827E),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        cancelFunc();
                        NamedNavigatorImpl.push('CartScreen');
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5FBF7),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFBFDAC9)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.shopping_cart_outlined, size: 17, color: Color(0xFF168B50)),
                            SizedBox(width: 5),
                            Text(
                              'عرض السلة',
                              style: TextStyle(
                                color: Color(0xFF168B50),
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: cancelFunc,
                child: const Padding(
                  padding: EdgeInsets.all(6),
                  child: Icon(Icons.close_rounded, size: 20, color: Color(0xFF9A9A9A)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static void showError({
    ApiResponse? apiResponse,
    required String message,
    String? title,
    String? icon,
    Color? backgroundColor,
    Color? textColor,
    int seconds = 3,
    VoidCallback? onTap,
  }) {
    BotToast.showCustomText(
      duration: Duration(seconds: seconds),
      toastBuilder: (context) => SizedBox(
        height: 80,
        child: CustomToast(
          title: title,
          message: message,
          type: apiResponse?.state == ResponseState.offline ? ToastType.offline : ToastType.error,
          backgroundColor: backgroundColor,
          icon: icon,
          textColor: textColor,
        ),
      ),
    );
  }

  // static void showSuccess({
  //   required String message,
  //   String? title,
  //   String? icon,
  //   Color? backgroundColor,
  //   Color? textColor,
  //   int seconds = 3,
  // }) {
  //   BotToast.showCustomText(
  //     duration: Duration(seconds: seconds),
  //     toastBuilder: (cancelFunc) => SizedBox(
  //       height: 80,
  //       child: CustomToast(
  //         type: ToastType.success,
  //         title: title,
  //         message: message,
  //         backgroundColor: backgroundColor,
  //         icon: icon,
  //         textColor: textColor,
  //       ),
  //     ),
  //   );
  // }

  static Future<bool> hasConnection() async {
    bool result = await InternetConnection().hasInternetAccess;

    if (!result) {
      final completer = Completer<bool>();
      final subscription = InternetConnection().onStatusChange.listen((status) {
        if (status == InternetStatus.connected) {
          completer.complete(true);
        }
      });

      Future.delayed(const Duration(seconds: 5), () {
        if (!completer.isCompleted) {
          completer.complete(false);
        }
        subscription.cancel();
      });

      result = await completer.future;
    }

    return result;
  }
}
