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
