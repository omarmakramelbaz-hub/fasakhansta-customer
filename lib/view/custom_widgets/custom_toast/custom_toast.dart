import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../helpers/images/app_images.dart';
import '../../../helpers/theme/app_colors.dart';

enum ToastType { success, error, offline, warning, help }

class CustomToast extends StatelessWidget {
  final ToastType type;
  final String? title;
  final String? icon;
  final String message;
  final Color? backgroundColor;
  final Color? textColor;

  const CustomToast({
    super.key,
    required this.type,
    this.title,
    required this.message,
    this.backgroundColor,
    this.textColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    if (type == ToastType.success && backgroundColor == null) {
      return _buildBrandedSuccess();
    }

    return Container(
      width: double.infinity,
      height: 100,
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: backgroundColor ?? _backgroundColor(),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Center(
            child: CircleAvatar(
              radius: 37.5,
              backgroundColor: Colors.white60,
              child: SvgPicture.asset(
                icon ?? _icons(),
                height: 50,
                width: 50,
                colorFilter: ColorFilter.mode(
                  backgroundColor ?? _backgroundColor(),
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (title != null) ...{
                  Text(
                    title!,
                    style: TextStyle(
                      color: textColor ?? Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                  ),
                  const SizedBox(height: 8),
                },
                Text(
                  message,
                  style: TextStyle(
                    color: textColor ?? Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.justify,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrandedSuccess() {
    final isLoginSuccess = message.contains('الدخول') ||
        message.toLowerCase().contains('login') ||
        message.toLowerCase().contains('signed in');

    final successTitle = title?.trim().isNotEmpty == true
        ? title!.trim()
        : isLoginSuccess
            ? 'تم الدخول بنجاح'
            : message;

    final successSubtitle = isLoginSuccess
        ? 'أهلاً بك، تم تسجيل دخولك إلى حسابك بنجاح'
        : (title?.trim().isNotEmpty == true ? message : null);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF7EF),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFFFD2AE),
            width: 1,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x16000000),
              blurRadius: 18,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0D000000),
                    blurRadius: 10,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: SizedBox(
                  width: 30,
                  height: 30,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.mainAppColor,
                            width: 2.4,
                          ),
                        ),
                        child: Icon(
                          Icons.check_rounded,
                          color: AppColors.mainAppColor,
                          size: 21,
                        ),
                      ),
                      Positioned(
                        top: -1,
                        right: 1,
                        child: Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            color: Color(0xFF28B96B),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    successTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF202328),
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                    ),
                  ),
                  if (successSubtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      successSubtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF858B94),
                        fontSize: 10.5,
                        fontWeight: FontWeight.w500,
                        height: 1.15,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _backgroundColor() {
    switch (type) {
      case ToastType.success:
        return const Color(0xff1FC170);
      case ToastType.error:
        return const Color(0xffff3333);
      case ToastType.offline:
        return const Color(0xFF616161);
      case ToastType.warning:
        return const Color(0xffFFCC00);
      case ToastType.help:
        return const Color(0xff0091EA);
    }
  }

  String _icons() {
    switch (type) {
      case ToastType.success:
        return AppImages.success;
      case ToastType.error:
        return AppImages.error;
      case ToastType.offline:
        return AppImages.offlineIcon;
      case ToastType.warning:
        return AppImages.warning;
      case ToastType.help:
        return AppImages.help;
    }
  }
}
