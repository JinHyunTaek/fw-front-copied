import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mma_flutter/common/component/app_image_with_text.dart';
import 'package:mma_flutter/common/component/input/auth_text_form_field.dart';
import 'package:mma_flutter/common/component/retry_loading/custom_circular_progess_indicator.dart';
import 'package:mma_flutter/common/component/input/input_vaiidator.dart';
import 'package:mma_flutter/common/const/colors.dart';
import 'package:mma_flutter/common/layout/default_layout.dart';
import 'package:mma_flutter/common/const/data.dart';
import 'package:mma_flutter/common/screen/web_view_screen.dart';
import 'package:mma_flutter/main.dart';
import 'package:mma_flutter/user/model/email_verification_code_request.dart';
import 'package:mma_flutter/user/provider/smtp_provider.dart';
import 'package:mma_flutter/user/repository/smtp_repository.dart';
import 'package:mma_flutter/user/screen/join/join_code_verification_screen.dart';

class EmailVerificationScreen extends ConsumerStatefulWidget {
  final bool isJoin;

  static String get routeName => '/email-verification';

  const EmailVerificationScreen({required this.isJoin, super.key});

  @override
  ConsumerState<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState
    extends ConsumerState<EmailVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  String email = '';
  bool _isAgreed = false;

  @override
  Widget build(BuildContext context) {
    final width = 336.w;
    final state = ref.watch(smtpProvider);

    return DefaultLayout(
      child: Center(
        child: SizedBox(
          width: width,
          child: Column(
            children: [
              AppImageWithText(text: widget.isJoin ? '회원가입' : '비밀번호 찾기'),
              SizedBox(height: 37.h),
              Container(
                alignment: Alignment.topLeft,
                child: Text(
                  '이메일 주소*',
                  style: TextStyle(color: Color(0xff8c8c8c), fontSize: 12.sp),
                ),
              ),
              SizedBox(height: 5.h),
              Form(
                key: _formKey,
                child: AuthTextFormField(
                  width: width,
                  onChanged: (val) {
                    /// 인증코드 전송 함수 활성화(backGround color)해야 하므로, setState 필요함
                    setState(() {
                      email = val;
                    });
                    _formKey.currentState!.validate();
                  },
                  hintText: '예) fightweek@example.com',
                  borderSideWidth: 2.w,
                  borderRadiusSize: 8.r,
                  validator: InputValidator.validator('이메일'),
                ),
              ),
              SizedBox(height: 16.h),
              if (widget.isJoin)
                Row(
                  children: [
                    SizedBox(
                      width: 20.w,
                      height: 20.w,
                      child: Checkbox(
                        value: _isAgreed,
                        onChanged: (val) => setState(() => _isAgreed = val ?? false),
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
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const WebViewScreen(
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
              SizedBox(
                height: 34.h,
                width: 336.w,
                child: ElevatedButton(
                  onPressed:
                      (email.isEmpty ||
                              !(_formKey.currentState!.validate()) ||
                              state == SmtpStatus.loading ||
                              (widget.isJoin && !_isAgreed))
                          ? null
                          : () async {
                            if (_formKey.currentState!.validate()) {
                              final res = await ref
                                  .read(smtpProvider.notifier)
                                  .sendVerificationCode(
                                    email: email,
                                    isJoin: widget.isJoin,
                                  );
                              if (res == EmailVerificationSendResult.SUCCESS) {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder:
                                        (context) => JoinCodeVerificationScreen(
                                          email: email,
                                          isJoin: widget.isJoin,
                                        ),
                                  ),
                                );
                              } else {
                                /// unknown server error
                                if (res == null) {
                                  Navigator.of(context).pop();
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(res.message)),
                                  );
                                }
                              }
                            }
                          },
                  style: ElevatedButton.styleFrom(
                    side: BorderSide(
                      color:
                          !_isAgreed || email.isEmpty || !_formKey.currentState!.validate()
                              ? GREY_COLOR
                              : WHITE_COLOR,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadiusGeometry.circular(8.r),
                    ),
                    backgroundColor: DARK_GREY_COLOR,
                  ),
                  child:
                      state == SmtpStatus.loading
                          ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CustomCircularProgressIndicator()
                          )
                          : Text(
                            '인증메일 전송',
                            style: TextStyle(
                              color:
                                  email.isEmpty ||
                                          !_formKey.currentState!.validate()
                                      ? GREY_COLOR
                                      : WHITE_COLOR,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
