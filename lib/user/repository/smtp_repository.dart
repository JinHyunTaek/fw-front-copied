import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mma_flutter/common/const/data.dart';
import 'package:mma_flutter/common/provider/dio/dio_provider.dart';
import 'package:mma_flutter/user/model/email_verification_code_request.dart';
import 'package:mma_flutter/user/model/password_reset_token_model.dart';
import 'package:mma_flutter/user/model/verify_code_request.dart';
import 'package:retrofit/error_logger.dart';
import 'package:retrofit/http.dart';

part 'smtp_repository.g.dart';

final smtpRepositoryProvider = Provider<SmtpRepository>((ref) {
  final dio = ref.read(dioProvider);
  return SmtpRepository(dio, baseUrl: '$baseUrl/smtp');
});

// $baseUrl/smtp
@RestApi()
abstract class SmtpRepository {
  factory SmtpRepository(Dio dio, {String baseUrl}) = _SmtpRepository;

  @POST('/verification-code-transmission')
  Future<String> sendEmailVerificationCode({
    @Body() required EmailVerificationCodeRequest request,
  });

  @POST('/code-verification')
  Future<void> verifyCode({@Body() required VerifyCodeRequest request});

  @POST('/password-reset-token')
  Future<PasswordResetTokenModel> getResetToken({
    @Body() required VerifyCodeRequest request,
  });
}

enum EmailVerificationSendResult {
  SUCCESS(message: '성공'),
  EMAIL_ALREADY_EXISTS(message: '이미 가입된 계정입니다'),
  EMAIL_NOT_FOUND(message: '가입되지 않은 이메일 계정입니다'),
  SOCIAL_LOGIN_ACCOUNT(message: '소셜 로그인 플랫폼 사용자는 비밀번호 없이 로그인 해주세요');

  final String message;

  const EmailVerificationSendResult({required this.message});

  static EmailVerificationSendResult fromResponse(String raw) {
    final value = raw.replaceAll('"', '');
    return EmailVerificationSendResult.values.firstWhere(
          (e) => e.name == value,
    );
  }
}
