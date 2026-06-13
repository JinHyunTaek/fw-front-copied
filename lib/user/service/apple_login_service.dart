import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:mma_flutter/user/enumtype/login_platform.dart';
import 'package:mma_flutter/user/model/social_login_request.dart';
import 'package:mma_flutter/user/service/social_login_service.dart';

final appleLoginServiceProvider = Provider<SocialLoginService>(
  (ref) => AppleLoginService(),
);

class AppleLoginService implements SocialLoginService {
  static const _storage = FlutterSecureStorage();

  @override
  Future<SocialLoginRequest> login({required String? fcmToken}) async {
    final AuthorizationCredentialAppleID credential;
    try {
      credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        throw const SocialLoginCancelledException();
      }
      log('apple auth error: ${e.code} / ${e.message}');
      throw const SocialLoginException(message: '애플 로그인 실패');
    }

    final userIdentifier = credential.userIdentifier;
    if (userIdentifier == null) {
      throw const SocialLoginException(message: '애플 로그인 실패');
    }

    final identityToken = credential.identityToken;
    if (identityToken == null) {
      throw const SocialLoginException(message: '애플 로그인 실패');
    }

    String? email = credential.email;
    if (email != null && email.isNotEmpty) {
      await _storage.write(key: 'apple_email_$userIdentifier', value: email);
    } else {
      email = await _storage.read(key: 'apple_email_$userIdentifier');
    }

    if (email == null || email.isEmpty) {
      log('apple login: email is null. userIdentifier=$userIdentifier');
      throw const SocialLoginException(
        message: '이메일 정보를 가져올 수 없습니다.\n설정 > Apple ID > 로그인 및 보안 > Apple로 로그인 >\n파이트위크 중단 후 다시 시도해주세요.',
      );
    }

    return SocialLoginRequest(
      domain: LoginPlatform.apple.name.toUpperCase(),
      accessToken: identityToken,
      email: email,
      socialId: userIdentifier,
      fcmToken: fcmToken,
    );
  }
}
