import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mma_flutter/user/model/email_verification_code_request.dart';
import 'package:mma_flutter/user/model/password_reset_token_model.dart';
import 'package:mma_flutter/user/model/verify_code_request.dart';
import 'package:mma_flutter/user/repository/smtp_repository.dart';

enum SmtpStatus { none, loading, verified, incorrectCode, unknownError }

final smtpProvider = StateNotifierProvider<SmtpStateNotifier, SmtpStatus>((
  ref,
) {
  final smtpRepository = ref.read(smtpRepositoryProvider);
  return SmtpStateNotifier(smtpRepository: smtpRepository);
});

class SmtpStateNotifier extends StateNotifier<SmtpStatus> {
  final SmtpRepository smtpRepository;

  SmtpStateNotifier({required this.smtpRepository}) : super(SmtpStatus.none);

  Future<EmailVerificationSendResult?> sendVerificationCode({
    required String email,
    required bool isJoin,
  }) async {
    try {
      state = SmtpStatus.loading;
      final res = await smtpRepository.sendEmailVerificationCode(
        request: EmailVerificationCodeRequest(email: email, isJoin: isJoin),
      );
      state = SmtpStatus.none;
      return EmailVerificationSendResult.fromResponse(res);
    } catch (e) {
      return null;
    }
  }

  Future<String?> getResetToken(VerifyCodeRequest request) async {
    try {
      final res = await smtpRepository.getResetToken(request: request);
      state = SmtpStatus.verified;
      return res.resetToken;
    } on DioException catch (e) {
      if ((e.response?.statusCode!) == 400) {
        state = SmtpStatus.incorrectCode;
      }else{
        state = SmtpStatus.unknownError;
      }
      return null;
    }
  }

  Future<void> verifyCode(VerifyCodeRequest request) async {
    try {
      await smtpRepository.verifyCode(request: request);
      state = SmtpStatus.verified;
    } on DioException catch (e) {
      /// 이메일로 전송된 코드와 화면에 입력한 코드가 일치하지 않을 때 (400 error)
      if ((e.response?.statusCode!) == 400) {
        state = SmtpStatus.incorrectCode;
      }else{
        state = SmtpStatus.unknownError;
      }
    }
  }
}
