import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:mma_flutter/common/component/input/auth_text_form_field.dart';
import 'package:mma_flutter/common/component/custom_alert_dialog.dart';
import 'package:mma_flutter/common/component/input/input_vaiidator.dart';
import 'package:mma_flutter/common/const/colors.dart';
import 'package:mma_flutter/main.dart';
import 'package:mma_flutter/setting/setting_selection_screen.dart';
import 'package:mma_flutter/user/component/basic_button.dart';
import 'package:mma_flutter/user/model/password_reset_request.dart';
import 'package:mma_flutter/user/provider/user_provider.dart';
import 'package:mma_flutter/user/screen/login_screen.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  static String get routeName => 'change_password';

  final String? resetToken;
  final String? email;

  const ChangePasswordScreen({this.resetToken, this.email, super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  String password = '';
  String passwordConfirm = '';
  bool passwordVisible = false;
  bool passwordConfirmVisible = false;
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          '비밀번호 변경',
          style: context.text.bodyMedium,
        ),
      ),
      body: Container(
        color: context.colors.surface,
        child: Form(
          key: formKey,
          child: Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width / 1.12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 6.h, bottom: 2.h, left: 6.w),
                    child: Text(
                      '새로운 비밀번호를 입력해 주세요',
                      style: context.text.bodySmall,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 6.w, bottom: 16.h),
                    child: Text(
                      '*안전한 계정 사용을 위해 비밀번호는 주기적으로 변경해 주세요',
                      style: context.text.bodyMedium?.copyWith(
                        fontSize: 12.sp,
                        color: Color(0xffb3b3b3),
                      ),
                    ),
                  ),
                  AuthTextFormField(
                    onChanged: (val) {
                      setState(() {
                        password = val;
                      });
                      formKey.currentState!.validate();
                    },
                    hintText: '비밀번호를 입력하세요',
                    borderSideWidth: 2.w,
                    borderRadiusSize: 8.r,
                    validator: InputValidator.validator('비밀번호'),
                    suffixIcon: IconButton(
                      iconSize: 16.sp,
                      icon: Icon(
                        passwordVisible
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          passwordVisible = !passwordVisible;
                        });
                      },
                    ),
                    obscureText: !passwordVisible,
                    suffixConstraints: BoxConstraints(maxHeight: 30.h),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    child: AuthTextFormField(
                      onChanged: (val) {
                        setState(() {
                          passwordConfirm = val;
                        });
                        formKey.currentState!.validate();
                      },
                      hintText: '비밀번호를 다시 입력하세요',
                      borderSideWidth: 2.w,
                      borderRadiusSize: 8.r,
                      validator:
                          (String? value) => _validatePasswordConfirm(
                            password,
                            passwordConfirm,
                          ),
                      obscureText: !passwordConfirmVisible,
                      suffixIcon: IconButton(
                        icon: Icon(
                          size: 16.sp,
                          passwordConfirmVisible
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () {
                          setState(() {
                            passwordConfirmVisible = !passwordConfirmVisible;
                          });
                        },
                      ),
                      suffixConstraints: BoxConstraints(maxHeight: 30.h),
                    ),
                  ),
                  BasicButton(
                    bgColor: BLUE_COLOR,
                    onPressed:
                        _validatePasswordConfirm(password, passwordConfirm) !=
                                null
                            ? null
                            : () async {
                              final bool res;
                              if (widget.resetToken != null) {
                                res = await ref
                                    .read(userProvider.notifier)
                                    .resetPassword(
                                      request: PasswordResetRequest(
                                        email: widget.email!,
                                        password: password,
                                        resetToken: widget.resetToken!,
                                      ),
                                    );
                              } else {
                                res = await ref
                                    .read(userProvider.notifier)
                                    .changePassword(password);
                              }
                              if (res) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '비밀번호를 성공적으로 변경했습니다.${widget.resetToken != null ? '변경된 비밀번호로 다시 로그인해주세요.' : ''}',
                                    ),
                                  ),
                                );
                                if (widget.resetToken != null) {
                                  context.pushReplacementNamed(
                                    LoginScreen.routeName,
                                  );
                                } else {
                                  context.goNamed(
                                    SettingSelectionScreen.routeName,
                                  );
                                }
                              } else {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return CustomAlertDialog(
                                      contentMsg: '비밀번호 변경 중 오류 발생',
                                    );
                                  },
                                );
                              }
                            },
                    text: '확인',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String? _validatePasswordConfirm(String password, String passwordConfirm) {
    if (passwordConfirm.isEmpty) {
      return '비밀번호 확인칸을 입력하세요';
    } else if (password != passwordConfirm) {
      return '입력한 비밀번호가 서로 다릅니다.';
    } else {
      return null;
    }
  }
}
