import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mma_flutter/common/component/retry_loading/custom_circular_progess_indicator.dart';
import 'package:mma_flutter/common/const/colors.dart';
import 'package:mma_flutter/common/const/data.dart';
import 'package:mma_flutter/common/firebase/provider/fcm_token_provider.dart';
import 'package:mma_flutter/common/screen/web_view_screen.dart';
import 'package:mma_flutter/main.dart';
import 'package:mma_flutter/user/component/basic_button.dart';
import 'package:mma_flutter/user/enumtype/login_platform.dart';
import 'package:mma_flutter/user/model/social_login_request.dart';
import 'package:mma_flutter/user/provider/user_provider.dart';
import 'package:mma_flutter/user/service/apple_login_service.dart';
import 'package:mma_flutter/user/service/google_login_service.dart';
import 'package:mma_flutter/user/service/kakao_login_service.dart';
import 'package:mma_flutter/user/service/social_login_service.dart';
import 'package:naver_login_sdk/naver_login_sdk.dart';

class SocialLoginButtons extends ConsumerStatefulWidget {
  const SocialLoginButtons({super.key});

  @override
  ConsumerState<SocialLoginButtons> createState() => _SocialLoginButtonsState();
}

class _SocialLoginButtonsState extends ConsumerState<SocialLoginButtons> {
  bool _isAgreed = false;
  bool _isLoading = false;

  void _checkAgreementAndRun(Future<void> Function() action) async {
    if (!_isAgreed) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('개인정보처리방침에 동의해주세요')));
      return;
    }
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      await action();
    } on SocialLoginException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } on Exception catch (e) {
      log('social login exception: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('로그인 실패')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fcmTokenAsync = ref.watch(fcmTokenFutureProvider);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 20.w,
              height: 20.w,
              child: Checkbox(
                value: _isAgreed,
                onChanged:
                    _isLoading
                        ? null
                        : (val) => setState(() => _isAgreed = val ?? false),
                activeColor: context.colors.onSurface,
                side: BorderSide(color: GREY_COLOR, width: 1.5),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              '개인정보처리방침에 동의합니다 ',
              style: TextStyle(fontSize: 12.sp, color: LIGHT_GREY_COLOR),
            ),
            GestureDetector(
              onTap:
                  () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder:
                          (_) => const WebViewScreen(
                            url: PRIVACY_POLICY_URL,
                            title: '개인정보처리방침',
                          ),
                    ),
                  ),
              child: Text(
                '[보기]',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: BLUE_COLOR,
                  decoration: TextDecoration.underline,
                  decorationColor: BLUE_COLOR,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        if (_isLoading)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 24.h),
            child: const CustomCircularProgressIndicator(),
          )
        else ...[
          _socialLoginButton(
            color: Color(0xffFEE500),
            socialLoginIconImage: SvgPicture.asset(
              'asset/img/social/btn_kakao.svg',
              width: 24.w,
              height: 24.h,
            ),
            buttonText: '카카오로 시작하기',
            onPressed:
                () => _checkAgreementAndRun(() async {
                  await ref
                      .read(userProvider.notifier)
                      .socialLogin(
                        request: await ref
                            .read(kakaoLoginServiceProvider)
                            .login(fcmToken: fcmTokenAsync.value),
                      );
                }),
          ),
          const SizedBox(height: 12),
          _naverLoginButton(ref: ref, token: fcmTokenAsync.value),
          const SizedBox(height: 12),
          _socialLoginButton(
            color: Color(0xffFFFFFF),
            socialLoginIconImage: SvgPicture.asset(
              'asset/img/social/google_logo.svg',
              width: 22.w,
              height: 22.h,
            ),
            buttonText: '구글로 시작하기',
            onPressed:
                () => _checkAgreementAndRun(() async {
                  final fcmToken = await ref.read(fcmTokenProvider).getToken();
                  await ref
                      .read(userProvider.notifier)
                      .socialLogin(
                        request: await ref
                            .read(googleLoginServiceProvider)
                            .login(fcmToken: fcmToken),
                      );
                }),
          ),
          if (Platform.isIOS) ...[
            const SizedBox(height: 12),
            _socialLoginButton(
              color: Color(0xffffffff),
              socialLoginIconImage: Image.asset(
                'asset/img/social/apple_logo.png',
                width: 22.w,
                height: 22.h
              ),
              buttonText: 'Apple로 시작하기',
              onPressed:
                  () => _checkAgreementAndRun(() async {
                    final fcmToken =
                        await ref.read(fcmTokenProvider).getToken();
                    await ref
                        .read(userProvider.notifier)
                        .socialLogin(
                          request: await ref
                              .read(appleLoginServiceProvider)
                              .login(fcmToken: fcmToken),
                        );
                  }),
            ),
          ],
        ],
      ],
    );
  }

  Widget _naverLoginButton({required WidgetRef ref, required String? token}) {
    final userNotifier = ref.read(userProvider.notifier);

    return _socialLoginButton(
      color: Color(0xffffffff),
      socialLoginIconImage: Image.asset(
        'asset/img/social/naver_logo.png',
        width: 24.w,
        height: 24.h,
      ),
      buttonText: '네이버로 시작하기',
      onPressed:
          () => _checkAgreementAndRun(() async {
            NaverLoginSDK.authenticate(
              callback: OAuthLoginCallback(
                onSuccess: () async {
                  final accessToken = await NaverLoginSDK.getAccessToken();
                  NaverLoginSDK.profile(
                    callback: ProfileCallback(
                      onSuccess: (resultCode, message, response) {
                        final profile = NaverLoginProfile.fromJson(
                          response: response,
                        );
                        userNotifier.socialLogin(
                          request: SocialLoginRequest(
                            domain: LoginPlatform.naver.name.toUpperCase(),
                            accessToken: accessToken,
                            email: profile.email!,
                            socialId: profile.id!,
                            fcmToken: token,
                          ),
                        );
                      },
                    ),
                  );
                },
                onError: (errorCode, message) {
                  userNotifier.setStateNull();
                },
                onFailure: (httpStatus, message) {
                  userNotifier.setStateNull();
                },
              ),
            );
          }),
    );
  }

  Widget _socialLoginButton({
    required Color color,
    required Widget socialLoginIconImage,
    required String buttonText,
    required VoidCallback onPressed,
  }) {
    return BasicButton(
      bgColor: color,
      onPressed: onPressed,
      text: buttonText,
      socialLoginIconImage: socialLoginIconImage,
    );
  }
}
