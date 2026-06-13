import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mma_flutter/app_status/provider/server_state_provider.dart';
import 'package:mma_flutter/common/const/data.dart';
import 'package:mma_flutter/common/provider/secure_storage_provider.dart';
import 'package:mma_flutter/user/provider/user_provider.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 10),
    ),
  );
  final storage = ref.watch(secureStorageProvider);
  dio.interceptors.add(CustomInterceptor(ref: ref, storage: storage));
  return dio;
});

class CustomInterceptor extends Interceptor {
  final FlutterSecureStorage storage;
  final Ref ref;

  CustomInterceptor({required this.ref, required this.storage});

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    log('[REQ] [${options.method}] ${options.uri}');
    if (options.headers['accessToken'] == 'true') {
      options.headers.remove('accessToken');
      final accessToken = await storage.read(key: ACCESS_TOKEN_KEY);
      if (accessToken != null) {
        options.headers.addAll({'Authorization': 'Bearer $accessToken'});
      }
    }
    if (options.headers['refreshToken'] == 'true') {
      options.headers.remove('refreshToken');
      final refreshToken = await storage.read(key: REFRESH_TOKEN_KEY);
      if (refreshToken != null) {
        options.headers.addAll({'Refresh': refreshToken});
      }
    }
    return super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    log('[ERR] [${err.requestOptions.method}] ${err.requestOptions.uri}');

    // 서버 점검 중 (nginx fallback: 502/503 → {"maintenance": true})
    final data = err.response?.data;
    if (data is Map && data['maintenance'] == true) {
      ref.read(serverStateProvider.notifier).state = ServerState.maintenance;
      return handler.reject(err);
    }

    // 서버 타임아웃 (클라이언트 측 or nginx 504 → {"timeout": true})
    final isNginxTimeout = err.response?.statusCode == 504 &&
        data is Map &&
        data['timeout'] == true;
    final isClientTimeout =
        err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout;
    // /app-status 타임아웃은 SplashScreen의 RetryButton이 처리
    if (isNginxTimeout || isClientTimeout) {
      ref.read(serverStateProvider.notifier).state = ServerState.timeout;
      return handler.reject(err);
    }

    // 401 에러가 발생했을 때 토큰 재발급을 받는 요청을 한다.
    // 토큰이 재발급되면, 다시 새로운 토큰으로 원래 하려던 요청을 한다.
    final refreshToken = await storage.read(key: REFRESH_TOKEN_KEY);
    if (refreshToken == null) {
      // 예외 발생
      return handler.reject(err);
    }
    final isStatus401 = err.response?.statusCode == 401;
    final isPathReissue = err.requestOptions.path == '/reissue';
    final options = err.requestOptions;
    // reissue 요청이 아닌데, 401이다? -> 빼박 accessToken 만료된 것임
    if (isStatus401 && !isPathReissue) {
      log('accesstoken is invalid!');
      final dio = Dio();
      try {
        final resp = await dio.post(
          '$baseUrl/reissue',
          options: Options(headers: {'Refresh': refreshToken}),
        );
        final newAccessToken = resp.data['accessToken'];
        final newRefreshToken = resp.data['refreshToken'];
        await storage.write(key: ACCESS_TOKEN_KEY, value: newAccessToken);
        await storage.write(key: REFRESH_TOKEN_KEY, value: newRefreshToken);
        options.headers.addAll({'Authorization': 'Bearer $newAccessToken'});
      } on DioException catch (e) {
        // refresh 마저 만료되었을 때 => 서버에서 refresh 검증 못 하므로,
        // 아예 서버에 로그아웃 요청을 하지 않고 프론트에서 자체 로그아웃
        ref.read(userProvider.notifier).logout(withRefresh: false);
        return handler.reject(e);
      }
      try{
        // reissue 성공 -> 원래 요청 재시도
        final response = await dio.fetch(
          options,
        ); // 새롭게 발급받은 accessToken 으로 요청 재전송
        return handler.resolve(response);
      } on DioException catch (e){
        return handler.reject(e);
      }
    }
    return handler.reject(err);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    log(
      '[RES] [${response.requestOptions.method}] ${response.requestOptions.uri}',
    );
    super.onResponse(response, handler);
  }
}
