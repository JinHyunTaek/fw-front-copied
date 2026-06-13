import 'package:mma_flutter/user/model/social_login_request.dart';

abstract class SocialLoginService {
  Future<SocialLoginRequest> login({required String? fcmToken});
}

class SocialLoginException implements Exception {
  final String message;

  const SocialLoginException({required this.message});
}

class SocialLoginCancelledException implements Exception {
  const SocialLoginCancelledException();
}
