import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:provider/provider.dart';

import '../../../../helpers/hive/hive_methods.dart';
import '../../../../helpers/images/app_images.dart';
import '../../../../helpers/networking/api_helper.dart';
import '../../../../helpers/networking/urls.dart';
import '../../../../helpers/notification_helper/notification_helper.dart';
import '../../../../helpers/pusher_service/pusher_controller.dart';
import '../../../../helpers/routes/app_routers_import.dart';
import '../../../../helpers/theme/app_colors.dart';
import '../../../../helpers/theme/app_text_style.dart';
import '../../../../helpers/utils/common_methods.dart';
import '../../../../helpers/utils/utils.dart';
import '../../../custom_widgets/custom_toast/custom_toast.dart';
import '../../bottom_navigation/bottom_navigation_bar_screen.dart';
import '../controller/auth_controller.dart';
import 'create_new_account_screen.dart';
import 'social_auth_phone_screen.dart';

class SocialBtn extends StatelessWidget {
  final String image;
  final String label;
  final VoidCallback onTap;

  const SocialBtn({
    super.key,
    required this.image,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: Ink(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: const Color(0xFFE4E7EB)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0D000000),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 30,
                  height: 30,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAFAFA),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Image.asset(
                    image,
                    width: 22,
                    height: 22,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(width: 7),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyle.text12BS().copyWith(
                      color: const Color(0xFF30343A),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SocialLoginRowWidget extends StatelessWidget {
  const SocialLoginRowWidget({super.key});

  void _onAuthSuccess(
    BuildContext context,
    int register,
    String? mobileVerifiedAt,
  ) {
    HiveMethods.updateIsVisitor(false);
    if (register == 0 && mobileVerifiedAt != null) {
      NamedNavigatorImpl.push(
        BottomNavigationBarScreen.routeName,
        replace: true,
      );
    } else {
      NamedNavigatorImpl.push(
        BottomNavigationBarScreen.routeName,
        clean: true,
      );
    }
  }

  void _initPusher(BuildContext context, int id, String token) {
    context.read<PusherController>().initPusher(
          channelName: 'private-user.$id',
          userId: id,
          token: token,
        );
  }

  String _responseMessage(
    dynamic data, {
    required String fallback,
  }) {
    if (data is Map) {
      final message = data['message'];
      if (message != null && message.toString().trim().isNotEmpty) {
        return message.toString().trim();
      }

      final error = data['error'];
      if (error != null && error.toString().trim().isNotEmpty) {
        return error.toString().trim();
      }

      final errors = data['errors'];
      if (errors is Map) {
        for (final value in errors.values) {
          if (value is List && value.isNotEmpty) {
            final first = value.first.toString().trim();
            if (first.isNotEmpty) return first;
          }
          final text = value?.toString().trim() ?? '';
          if (text.isNotEmpty) return text;
        }
      }
    }

    final text = data?.toString().trim() ?? '';
    if (text.isNotEmpty && text != '{}' && text != 'null') {
      return text;
    }
    return fallback;
  }

  int? _toInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '');
  }

  Future<Map<String, dynamic>> _facebookProfile(LoginResult result) async {
    try {
      // Use the package default profile fields first. This is the most stable
      // route on Web and already requests name, email and picture.
      return await FacebookAuth.instance.getUserData();
    } catch (error) {
      log('Facebook getUserData failed, trying Graph fallback: $error');

      final token = result.accessToken?.tokenString;
      if (token == null || token.isEmpty) rethrow;

      final graphResponse = await Dio().get(
        'https://graph.facebook.com/v21.0/me',
        queryParameters: {
          'fields': 'id,name,email,picture.width(200)',
          'access_token': token,
        },
        options: Options(
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (graphResponse.statusCode == 200 && graphResponse.data is Map) {
        return Map<String, dynamic>.from(graphResponse.data as Map);
      }

      throw Exception(
        _responseMessage(
          graphResponse.data,
          fallback: 'تعذر قراءة بيانات حساب Facebook.',
        ),
      );
    }
  }

  Future<void> _signInWithFacebook(BuildContext context) async {
    try {
      if (kIsWeb && !FacebookAuth.i.isWebSdkInitialized) {
        CommonMethods.showToast(
          message: 'Facebook login is not configured on this build.',
          type: ToastType.error,
        );
        return;
      }

      final result = await FacebookAuth.instance.login(
        permissions: const ['email', 'public_profile'],
      );

      if (result.status == LoginStatus.cancelled) return;
      if (result.status != LoginStatus.success) {
        CommonMethods.showToast(
          message: (result.message?.trim().isNotEmpty ?? false)
              ? result.message!.trim()
              : 'تعذر تسجيل الدخول باستخدام Facebook.',
          type: ToastType.error,
        );
        return;
      }

      final profile = await _facebookProfile(result);
      final tokenData = result.accessToken?.toJson() ?? const <String, dynamic>{};
      final facebookId =
          (profile['id'] ?? tokenData['userId'] ?? tokenData['user_id'])
              ?.toString()
              .trim();
      final name = profile['name']?.toString().trim() ?? '';
      final email = profile['email']?.toString().trim() ?? '';
      final picture = profile['picture'] is Map
          ? (profile['picture']['data'] is Map
              ? profile['picture']['data']['url']?.toString()
              : null)
          : null;

      if (facebookId == null || facebookId.isEmpty || name.isEmpty) {
        CommonMethods.showToast(
          message:
              'Facebook لم يرجع بيانات الحساب المطلوبة. تأكد من السماح بالاسم والبريد الإلكتروني.',
          type: ToastType.error,
        );
        return;
      }

      Utils.loading();

      final body = FormData.fromMap({
        'name': name,
        'email': email,
        'facebook_uuid': facebookId,
        'image_path': picture,
        'provider': 'facebook',
        'fcm_id': FirebaseNotifications.fcmToken ?? '',
      });

      final response = await ApiHelper.instance.post(
        Urls.loginWithFacebook,
        body: body,
      );
      Utils.loadingOff();

      if (response.state != ResponseState.complete) {
        CommonMethods.showError(
          message: _responseMessage(
            response.data,
            fallback: 'تعذر إكمال تسجيل الدخول بحساب Facebook.',
          ),
          apiResponse: response,
        );
        return;
      }

      if (response.data is! Map || response.data['data'] is! Map) {
        CommonMethods.showError(
          message: 'استجابة تسجيل الدخول من السيرفر غير صالحة.',
          apiResponse: response,
        );
        return;
      }

      final data = response.data['data'] as Map;
      if (data['user_data'] is! Map) {
        CommonMethods.showError(
          message: _responseMessage(
            response.data,
            fallback: 'لم يتم استلام بيانات المستخدم من السيرفر.',
          ),
          apiResponse: response,
        );
        return;
      }

      final userData = data['user_data'] as Map;
      final token = userData['token']?.toString() ?? '';
      final id = _toInt(userData['id']);
      final register = _toInt(data['register']) ?? 1;
      final mobileVerifiedAt = userData['mobile_verified_at']?.toString();
      final mobile = userData['mobile']?.toString().trim() ?? '';
      final serverEmail = userData['email']?.toString().trim() ?? '';

      if (token.isNotEmpty) {
        HiveMethods.updateToken(token);
      }
      if (register == 0 && mobileVerifiedAt != null && id != null) {
        HiveMethods.updateUserId(id);
      }
      if (id != null && token.isNotEmpty) {
        _initPusher(context, id, token);
      }

      HiveMethods.updateIsVisitor(false);

      if (token.isNotEmpty) {
        await context.read<AuthController>().getProfile();
      }

      CommonMethods.showToast(
        message: _responseMessage(
          response.data,
          fallback: 'تم تسجيل الدخول بنجاح.',
        ),
      );

      if (mobile.isEmpty) {
        NamedNavigatorImpl.push(
          SocialAuthPhoneScreen.routeName,
          arguments: {
            'provider': 'facebook',
            'provider_uuid': facebookId,
            'name': name,
            'email': email,
          },
        );
      } else if (register == 0 && serverEmail.isNotEmpty) {
        _onAuthSuccess(context, register, mobileVerifiedAt);
      } else {
        NamedNavigatorImpl.push(CreateNewAccountScreen.routeName);
      }
    } catch (error, stackTrace) {
      Utils.loadingOff();
      log(
        'Facebook Sign In Error: $error',
        stackTrace: stackTrace,
      );
      CommonMethods.showToast(
        message: error.toString().trim().isNotEmpty
            ? 'Facebook: ${error.toString()}'
            : 'تعذر تسجيل الدخول باستخدام Facebook.',
        type: ToastType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final showAppleLogin =
        !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEEF0F3)),
      ),
      child: Row(
        children: [
          if (showAppleLogin) ...[
            SocialBtn(
              image: AppImages.appleLoginIcon,
              label: 'Apple',
              onTap: () {
                context.read<AuthController>().signInWithApple(
                      onSuccess: (register, mobileVerifiedAt) =>
                          _onAuthSuccess(
                        context,
                        register,
                        mobileVerifiedAt,
                      ),
                      onFirstTime: () => NamedNavigatorImpl.push(
                        CreateNewAccountScreen.routeName,
                      ),
                      onHaveIdANDToken: (id, token) =>
                          _initPusher(context, id, token),
                    );
              },
            ),
            const SizedBox(width: 8),
          ],
          SocialBtn(
            image: AppImages.googleIcon,
            label: 'Google',
            onTap: () {
              context.read<AuthController>().signInWithGoogle(
                    onSuccess: (register, mobileVerifiedAt) =>
                        _onAuthSuccess(
                      context,
                      register,
                      mobileVerifiedAt,
                    ),
                    onFirstTime: () => NamedNavigatorImpl.push(
                      CreateNewAccountScreen.routeName,
                    ),
                    onHaveIdANDToken: (id, token) =>
                        _initPusher(context, id, token),
                  );
            },
          ),
          const SizedBox(width: 8),
          SocialBtn(
            image: AppImages.facebookIcon,
            label: 'Facebook',
            onTap: () => _signInWithFacebook(context),
          ),
        ],
      ),
    );
  }
}
