import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:mma_flutter/common/component/input/input_vaiidator.dart';
import 'package:mma_flutter/common/component/retry_loading/custom_circular_progess_indicator.dart';
import 'package:mma_flutter/common/const/colors.dart';
import 'package:mma_flutter/common/const/style.dart';
import 'package:mma_flutter/main.dart';
import 'package:mma_flutter/setting/account/change_password_screen.dart';
import 'package:mma_flutter/user/model/user_model.dart';
import 'package:mma_flutter/user/provider/user_provider.dart';

class VerifyPasswordScreen extends ConsumerStatefulWidget {
  static String get routeName => 'verify_password';

  const VerifyPasswordScreen({super.key});

  @override
  ConsumerState<VerifyPasswordScreen> createState() =>
      _VerifyPasswordScreenState();
}

class _VerifyPasswordScreenState extends ConsumerState<VerifyPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  bool passwordVisible = false;
  bool buttonEnabled = false;
  String password = '';

  @override
  Widget build(BuildContext context) {
    final userState = ref.read(userProvider);
    if(userState is! UserModel)return CustomCircularProgressIndicator();

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          '비밀번호 확인',
          style: context.text.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Container(
        color: context.colors.surface,
        child: Form(
          key: _formKey,
          child: Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width / 1.1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      top: 8.h,
                      bottom: 16.h,
                      left: 10.w,
                    ),
                    child: Text(
                      '소중한 정보 보호를 위해,\n비밀번호를 다시 한 번 입력해 주세요.',
                      style: defaultTextStyle.copyWith(fontSize: 13.sp),
                    ),
                  ),
                  TextField(
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.only(
                        left: 16.w,
                        bottom: 10.h,
                        top: 10.h,
                      ),
                      hintText: userState.email,
                      hintStyle: context.text.bodyMedium?.copyWith(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: GREY_COLOR, width: 0.7.w),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      focusColor: Colors.transparent,
                    ),
                    enabled: false,
                  ),
                  SizedBox(height: 12.h),
                  TextFormField(
                    obscureText: !passwordVisible,
                    style: context.text.bodyMedium,
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.only(
                        left: 16.w,
                        bottom: 10.h,
                        top: 10.h,
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: context.colors.onSurface,
                          width: 0.7.w,
                        ),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: context.colors.onSurface,
                          width: 1.5.w,
                        ),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
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
                      suffixIconConstraints: BoxConstraints(
                        maxHeight: 30.h
                      ),
                      hintText: '비밀번호를 입력하세요',
                      hintStyle: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    cursorColor: context.colors.onSurface,
                    validator: InputValidator.validator('비밀번호'),
                    onChanged: (value) {
                      setState(() {
                        password = value;
                        if (_formKey.currentState!.validate()) {
                          buttonEnabled = true;
                        } else {
                          buttonEnabled = false;
                        }
                      });
                    },
                  ),
                  SizedBox(height: 12.h),
                  SizedBox(
                    height: 34.h,
                    width: 336.w,
                    child: OutlinedButton(
                      onPressed:
                          !buttonEnabled
                              ? null
                              : () async {
                                final res = await ref
                                    .read(userProvider.notifier)
                                    .checkPassword(password);
                                if (res) {
                                  context.goNamed(
                                    ChangePasswordScreen.routeName,
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('비밀번호가 올바르지 않습니다.')),
                                  );
                                }
                              },
                      style: OutlinedButton.styleFrom(
                        backgroundColor:
                            buttonEnabled ? BLUE_COLOR : GREY_COLOR,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadiusGeometry.circular(8.r),
                        ),
                      ),
                      child: Text(
                        '확인',
                        style: defaultTextStyle.copyWith(fontSize: 14.sp),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
