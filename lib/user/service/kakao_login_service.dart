import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:mma_flutter/user/enumtype/login_platform.dart';
import 'package:mma_flutter/user/model/social_login_request.dart';
import 'package:mma_flutter/user/service/social_login_service.dart';

final kakaoLoginServiceProvider = Provider<SocialLoginService>(
  (ref) => KakaoLoginService(),
);

class KakaoLoginService implements SocialLoginService {
  @override
  Future<SocialLoginRequest> login({required String? fcmToken}) async {
    bool isInstalled = await isKakaoTalkInstalled();
    log('kakao installed=$isInstalled');

    OAuthToken token;
    if (isInstalled) {
      try {
        token = await UserApi.instance.loginWithKakaoTalk();
      } on KakaoAuthException catch (e) {
        log('KakaoAuthException: ${e.error} / ${e.message}');
        if (e.error == AuthErrorCause.accessDenied) {
          throw const SocialLoginCancelledException();
        }
        throw SocialLoginException(message: '카카오 로그인 실패');
      } on KakaoClientException catch (e) {
        log('KakaoClientException: ${e.reason} / ${e.message}');
        if (e.reason == ClientErrorCause.cancelled) {
          throw const SocialLoginCancelledException();
        }
        log(e.toString());
        throw SocialLoginException(message: '카카오 로그인 실패');
      } on Exception catch (e) {
        log('kakao loginWithKakaoTalk unknown error: $e');
        rethrow;
      }
    } else {
      token = await tryWithKakaoAccount();
    }

    try {
      final User user = await UserApi.instance.me();
      log('kakao me() success, email=${user.kakaoAccount?.email}');
      final email = user.kakaoAccount?.email;
      if (email == null) {
        throw SocialLoginException(message: '카카오 계정의 이메일 제공에 동의해주세요');
      }
      return SocialLoginRequest(
        domain: LoginPlatform.kakao.name.toUpperCase(),
        accessToken: token.accessToken,
        email: email,
        socialId: user.id.toString(),
        fcmToken: fcmToken,
      );
    } on SocialLoginException {
      rethrow;
    } on Exception catch (e) {
      log('kakao me() error: $e');
      rethrow;
    }
  }

  Future<OAuthToken> tryWithKakaoAccount() async {
    try {
      return await UserApi.instance.loginWithKakaoAccount();
    } on PlatformException catch (e) {
      if (e.code == 'UserCancelled') {
        throw const SocialLoginCancelledException();
      }
      log(e.toString());
      throw SocialLoginException(message: '카카오 로그인 실패');
    }
  }
}
