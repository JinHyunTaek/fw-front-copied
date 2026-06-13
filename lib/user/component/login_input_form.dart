import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mma_flutter/common/component/input/auth_text_form_field.dart';
import 'package:mma_flutter/common/component/input/input_vaiidator.dart';
import 'package:mma_flutter/common/const/colors.dart';
import 'package:mma_flutter/common/firebase/provider/fcm_token_provider.dart';
import 'package:mma_flutter/user/provider/user_provider.dart';

class LoginInputForm extends ConsumerStatefulWidget {
  const LoginInputForm({super.key});

  @override
  ConsumerState<LoginInputForm> createState() => _LoginInputFormState();
}

class _LoginInputFormState extends ConsumerState<LoginInputForm> {
  bool passwordVisible = false;
  final _formKey = GlobalKey<FormState>();
  final _emailKey = GlobalKey<FormFieldState>();
  final _passwordKey = GlobalKey<FormFieldState>();
  String email = '';
  String password = '';
  bool _emailValid = false;
  bool _passwordValid = false;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          SizedBox(height: 26.h),
          AuthTextFormField(
            formFieldKey: _emailKey,
            onChanged: (val) {
              setState(() {
                email = val;
                _emailValid = _emailKey.currentState?.validate() ?? false;
              });
            },
            hintText: '이메일을 입력하세요',
            validator: InputValidator.validator('이메일'),
            borderRadiusSize: 8.r,
            borderSideWidth: 2.w,
          ),
          SizedBox(height: 11.h),
          AuthTextFormField(
            formFieldKey: _passwordKey,
            onChanged: (val) {
              setState(() {
                password = val;
                _passwordValid = _passwordKey.currentState?.validate() ?? false;
              });
            },
            hintText: '비밀번호를 입력하세요',
            validator: InputValidator.validator('비밀번호'),
            borderRadiusSize: 8.r,
            borderSideWidth: 2.w,
            obscureText: !passwordVisible,
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
            suffixConstraints: BoxConstraints(maxHeight: 30.h),
          ),
          SizedBox(height: 40.h),
          SizedBox(
            width: 302.w,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                minimumSize: Size(270.w, 30.h),
                backgroundColor: BLUE_COLOR,
                disabledBackgroundColor: GREY_COLOR,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadiusGeometry.circular(8.r),
                ),
              ),
              onPressed:
                  !_emailValid || !_passwordValid
                      ? null
                      : () async {
                        if (!_formKey.currentState!.validate()) return;
                        ref
                            .read(userProvider.notifier)
                            .login(email: email, password: password);
                      },
              child: Text(
                '로그인',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: WHITE_COLOR,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
