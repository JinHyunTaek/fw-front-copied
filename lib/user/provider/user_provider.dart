import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mma_flutter/common/const/data.dart';
import 'package:mma_flutter/common/firebase/analytics.dart';
import 'package:mma_flutter/common/firebase/provider/fcm_token_provider.dart';
import 'package:mma_flutter/common/provider/secure_storage_provider.dart';
import 'package:mma_flutter/game/provider/game_provider.dart';
import 'package:mma_flutter/stream/bet/provider/bet_card_provider.dart';
import 'package:mma_flutter/stream/bet/provider/bet_history_provider.dart';
import 'package:mma_flutter/user/model/join_request.dart';
import 'package:mma_flutter/user/model/login_request.dart';
import 'package:mma_flutter/user/model/password_reset_request.dart';
import 'package:mma_flutter/user/model/social_login_request.dart';
import 'package:mma_flutter/user/model/user_model.dart';
import 'package:mma_flutter/user/model/withdrawal_request.dart';
import 'package:mma_flutter/user/repository/auth_repository.dart';
import 'package:mma_flutter/user/repository/user_repository.dart';

final userProvider = StateNotifierProvider<UserStateNotifier, UserModelBase?>((
  ref,
) {
  final authRepository = ref.read(authRepositoryProvider);
  final userRepository = ref.read(userRepositoryProvider);
  final storage = ref.read(secureStorageProvider);
  final tokenProvider = ref.read(fcmTokenProvider);

  return UserStateNotifier(
    ref: ref,
    fcmToken: tokenProvider,
    authRepository: authRepository,
    userRepository: userRepository,
    storage: storage,
  );
});

class UserStateNotifier extends StateNotifier<UserModelBase?> {
  final Ref _ref;
  final AuthRepository authRepository;
  final UserRepository userRepository;
  final FlutterSecureStorage storage;
  final FcmTokenProvider fcmToken;

  UserStateNotifier({
    required Ref ref,
    required this.authRepository,
    required this.userRepository,
    required this.storage,
    required this.fcmToken,
  }) : _ref = ref,
       super(UserModelLoading());

  void _resetProviders() {
    _ref.invalidate(gameProvider);
    _ref.invalidate(betHistoryProvider);
    _ref.invalidate(betCardProvider);
    _ref.read(selectedBetHistoryEventIdProvider.notifier).state = null;
  }

  void setStateNull() {
    state = null;
  }

  Future<bool> checkDupNickname(String nickname) {
    return userRepository.checkDuplicatedNickname(
      nickname: {'nickname': nickname},
    );
  }

  Future<bool> checkPassword(String password) {
    return userRepository.checkPassword(password: {'password': password});
  }

  Future<bool> checkIsSocial() {
    return userRepository.checkIsSocial();
  }

  Future<bool> resetPassword({required PasswordResetRequest request}) async {
    try {
      await userRepository.resetPassword(request: request);
      return true;
    } on Exception {
      return false;
    }
  }

  Future<bool> changePassword(String password) async {
    try {
      await userRepository.changePassword(password: {'password': password});
      return true;
    } on Exception {
      return false;
    }
  }

  Future<bool> updateNickname(String nickname) async {
    final nicknameToUpdate = nickname.trim();
    try {
      await userRepository.updateNickname(
        nickname: {'nickname': nicknameToUpdate},
      );
    } on DioException {
      return false;
    }
    final user = state;
    if (user is! UserModel) return false;
    state = copyWith(prev: user, newNickname: nicknameToUpdate);
    return true;
  }

  Future<String> uploadProfileImg({
    required FormData imgData,
    required UserModel user,
  }) async {
    try{
      final res = await userRepository.uploadProfileImage(image: imgData);
      state = copyWith(prev: user, profileImgUrl: res);
      return res;
    } on DioException {
      return '';
    }
  }

  void updatePoint(int point) async {
    final user = state;
    if (user is! UserModel) return;
    state = copyWith(prev: user, point: point);
  }

  Future<void> getMe() async {
    final refreshToken = await storage.read(key: REFRESH_TOKEN_KEY);
    final accessToken = await storage.read(key: ACCESS_TOKEN_KEY);
    if (refreshToken == null || accessToken == null) {
      log('either refresh or access is null');
      state = null;
      return;
    }
    try {
      final resp = await userRepository.getMe();
      if (resp == null) {
        state = null;
        return;
      }
      if (resp.nickname == null) {
        state = UserModelNicknameSetting(
          point: resp.point,
          id: resp.id,
          email: resp.email,
          earnedBetSucceedPoint: resp.earnedBetSucceedPoint,
          profileImgUrl: resp.profileImgUrl,
          reportedReason: resp.reportedReason,
          restrictEndAt: resp.restrictEndAt,
        );
      } else {
        state = resp;
      }
    } on Exception {
      storage.delete(key: ACCESS_TOKEN_KEY);
      storage.delete(key: REFRESH_TOKEN_KEY);
      state = null;
    }
  }

  Future<void> login({required String email, required String password}) async {
    try {
      final fcmToken = await this.fcmToken.getToken();
      state = UserModelLoadingToHome();
      final resp = await authRepository.login(
        request: LoginRequest(
          email: email,
          password: password,
          fcmToken: fcmToken,
        ),
      );
      await storage.write(key: ACCESS_TOKEN_KEY, value: resp.accessToken);
      await storage.write(key: REFRESH_TOKEN_KEY, value: resp.refreshToken);
      final userResp = await userRepository.getMe();
      if (userResp == null) {
        state = UserLoginErrorErrorModel(
          message: UserModelErrorMessage.LOGIN_FAILURE_USER_NULL.message,
        );
      } else {
        state = userResp;
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        state = UserLoginErrorErrorModel(
          message: UserModelErrorMessage.LOGIN_FAILURE_401.message,
        );
      }
    } on Exception {
      state = UserLoginErrorErrorModel(
        message: UserModelErrorMessage.UNKNOWN.message,
      );
    }
  }

  Future<void> socialLogin({required SocialLoginRequest request}) async {
    try {
      state = UserModelLoadingToHome();
      final resp = await authRepository.socialLogin(request: request);
      await storage.write(key: ACCESS_TOKEN_KEY, value: resp.accessToken);
      await storage.write(key: REFRESH_TOKEN_KEY, value: resp.refreshToken);
      UserModel? userResp = await userRepository.getMe();
      if (userResp == null) {
        state = UserLoginErrorErrorModel(message: '이메일 주소가 올바르지 않습니다.');
        return;
      }
      if (userResp.nickname == null) {
        // 닉네임 미설정 = 이번에 처음 생성된 소셜 계정 → 신규 가입으로 집계
        await Analytics.logSignUp(method: request.domain);
        state = UserModelNicknameSetting(
          point: userResp.point,
          id: userResp.id,
          email: userResp.email,
          earnedBetSucceedPoint: userResp.earnedBetSucceedPoint,
          profileImgUrl: userResp.profileImgUrl,
          reportedReason: userResp.reportedReason,
          restrictEndAt: userResp.restrictEndAt,
        );
      } else {
        state = userResp;
      }
    } on DioException catch (e) {
      final code = fromErrorCode(e.response?.data['errorCode']);
      if (code != null) {
        state = UserLoginErrorErrorModel(message: code.message);
      } else {
        state = UserLoginErrorErrorModel(
          message: UserModelErrorMessage.SOCIAL_LOGIN_FAILURE_500.message,
        );
      }
    } on Exception {
      state = UserLoginErrorErrorModel(
        message: UserModelErrorMessage.UNKNOWN.message,
      );
    }
  }

  Future<void> join({required JoinRequest request}) async {
    try {
      state = UserModelJoining();
      await userRepository.join(request: request);
      await Analytics.logSignUp(method: 'email');
    } on DioException catch (e) {
      final code = fromErrorCode(e.response?.data['errorCode']);
      if (code != null) {
        state = UserLoginErrorErrorModel(message: code.message);
      } else {
        state = UserLoginErrorErrorModel(
          message: UserModelErrorMessage.JOIN_FAILURE_500.message,
        );
      }
    } on Exception {
      state = UserLoginErrorErrorModel(
        message: UserModelErrorMessage.UNKNOWN.message,
      );
    }
  }

  Future<void> delete({required WithdrawalRequest request}) async {
    try {
      await userRepository.delete(request: request);
      state = null;
      await Future.wait([
        storage.delete(key: ACCESS_TOKEN_KEY),
        storage.delete(key: REFRESH_TOKEN_KEY),
      ]);
      _resetProviders();
    } on Exception {
      state = UserLoginErrorErrorModel(
        message: UserModelErrorMessage.UNKNOWN.message,
      );
    }
  }

  void logout({bool withRefresh = true}) async {
    state = null;
    if (withRefresh) {
      final refreshToken = await storage.read(key: REFRESH_TOKEN_KEY);
      if (refreshToken != null) {
        await authRepository.logout();
      }
    }
    await Future.wait([
      storage.delete(key: ACCESS_TOKEN_KEY),
      storage.delete(key: REFRESH_TOKEN_KEY),
    ]);
    _resetProviders();
  }

  UserModel copyWith({
    String? newNickname,
    int? point,
    String? profileImgUrl,
    required UserModel prev,
  }) {
    return UserModel(
      point: point ?? prev.point,
      nickname: newNickname ?? prev.nickname,
      profileImgUrl: profileImgUrl ?? prev.profileImgUrl,
      earnedBetSucceedPoint: prev.earnedBetSucceedPoint,
      id: prev.id,
      email: prev.email,
      reportedReason: prev.reportedReason,
      restrictEndAt: prev.restrictEndAt,
    );
  }

  UserModelErrorMessage? fromErrorCode(String? code) {
    for (final e in UserModelErrorMessage.values) {
      if (e.name == code) return e;
    }
    return null;
  }
}

enum UserModelErrorMessage {
  LOGIN_FAILURE_401('이메일 주소 혹은 비밀번호가 올바르지 않습니다.'),
  LOGIN_FAILURE_USER_NULL('이메일 주소 혹은 비밀번호가 올바르지 않습니다.'),
  // 400
  DUPLICATED_EMAIL_400('이미 사용 중인 이메일 계정입니다'),
  DUPLICATED_NICKNAME_400('이미 사용 중인 닉네임입니다'),
  // 403
  WITHDRAWN_USER_403('탈퇴한 사용자는 7일 동안 재가입이 불가합니다'),
  DUPLICATED_EMAIL_403('중복된 이메일 계정이 이미 존재합니다.\n다른 플랫폼으로 다시 로그인해주세요'),
  // 500
  LOGIN_FAILURE_500('로그인 실패'),
  SOCIAL_LOGIN_FAILURE_500('소셜 로그인 실패'),
  JOIN_FAILURE_500('회원가입 실패'),
  UNKNOWN('알 수 없는 오류 발생');

  final String message;

  const UserModelErrorMessage(this.message);
}
