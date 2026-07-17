import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mma_flutter/common/component/app_image_with_text.dart';
import 'package:mma_flutter/common/component/input/auth_text_form_field.dart';
import 'package:mma_flutter/common/component/input/input_vaiidator.dart';
import 'package:mma_flutter/common/const/colors.dart';
import 'package:mma_flutter/common/firebase/provider/fcm_token_provider.dart';
import 'package:mma_flutter/common/layout/default_layout.dart';
import 'package:mma_flutter/common/screen/splash_screen.dart';
import 'package:mma_flutter/user/component/basic_button.dart';
import 'package:mma_flutter/user/model/join_request.dart';
import 'package:mma_flutter/user/model/user_model.dart';
import 'package:mma_flutter/user/provider/user_provider.dart';

class EndJoinScreen extends ConsumerStatefulWidget {
  final String email;

  const EndJoinScreen({required this.email, super.key});

  @override
  ConsumerState<EndJoinScreen> createState() => _EndJoinScreenState();
}

class _EndJoinScreenState extends ConsumerState<EndJoinScreen> {
  final _formKey = GlobalKey<FormState>();
  bool? isNicknameDup;
  String nickname = '';
  String password = '';
  String passwordConfirm = '';

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(userProvider);

    return DefaultLayout(
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Center(
                child: SizedBox(
                  width: 310.w,
                  child: Column(
                    children: [
                      AppImageWithText(text: '회원가입'),
                      SizedBox(height: 37.h),
                      _inputLabel(label: '닉네임'),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            SizedBox(height: 5.h),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 220.w,
                                      child: AuthTextFormField(
                                        onChanged: (val) {
                                          setState(() {
                                            nickname = val;
                                            isNicknameDup = null;
                                          });
                                        },
                                        hintText: '닉네임을 입력해주세요',
                                        borderSideWidth: 2.w,
                                        borderRadiusSize: 8.r,
                                        borderSideColor: _nicknameBorderColor(),
                                      ),
                                    ),
                                    SizedBox(width: 6.w),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        fixedSize: Size(75.w, 34.h),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8.r,
                                          ),
                                        ),
                                        backgroundColor:
                                            isNicknameDup == null
                                                ? BLUE_COLOR
                                                : isNicknameDup == false
                                                ? GREY_COLOR
                                                : null,
                                        padding: EdgeInsets.zero,
                                      ),
                                      onPressed:
                                          nickname.isEmpty ||
                                                  nickname.length < 2 || nickname.length > 10
                                              ? null
                                              : () async {
                                                final dup = await ref
                                                    .read(userProvider.notifier)
                                                    .checkDupNickname(nickname);
                                                setState(() {
                                                  isNicknameDup = dup;
                                                });
                                              },
                                      child: Text(
                                        '중복 확인',
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          color: Color(0xffffffff),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                // 메시지 영역 (항상 고정 높이로 잡으면 버튼 위치도 안 밀림)
                                SizedBox(
                                  height: 20.h, // 메시지 영역 높이 고정
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: _renderNicknameMessage(),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12.h),
                            _inputLabel(label: '비밀번호 입력'),
                            SizedBox(height: 5.h),
                            AuthTextFormField(
                              onChanged: (val) {
                                setState(() {
                                  password = val;
                                });
                                _formKey.currentState!.validate();
                              },
                              hintText: '6자 이상 입력해주세요',
                              borderSideWidth: 2.w,
                              borderRadiusSize: 8.r,
                              validator: InputValidator.validator('비밀번호'),
                            ),
                            SizedBox(height: 12.h),
                            _inputLabel(label: '비밀번호 확인'),
                            SizedBox(height: 5.h),
                            AuthTextFormField(
                              onChanged: (val) {
                                setState(() {
                                  passwordConfirm = val;
                                });
                                _formKey.currentState!.validate();
                              },
                              hintText: '비밀번호를 다시 입력해주세요',
                              borderSideWidth: 2.w,
                              borderRadiusSize: 8.r,
                              validator:
                                  (String? value) => _validatePasswordConfirm(
                                    password,
                                    passwordConfirm,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 50.h),
              child: BasicButton(
                bgColor: BLUE_COLOR,
                onPressed:
                    state is UserModelJoining ||
                            (_validatePasswordConfirm(
                                  password,
                                  passwordConfirm,
                                ) !=
                                null) ||
                            nickname.length < 2 ||
                            (isNicknameDup ?? true) ||
                            password.length < 6
                        ? null
                        : () async {
                          // 가입 성공 시 auth 상태 변경으로 홈으로 리다이렉트되므로,
                          // await 전에 messenger를 잡아둬야 스낵바를 안전하게 띄울 수 있음
                          final messenger = ScaffoldMessenger.of(context);
                          await ref
                              .read(userProvider.notifier)
                              .join(
                                request: JoinRequest(
                                  email: widget.email,
                                  nickname: nickname,
                                  password: password,
                                ),
                              );
                          await ref
                              .read(userProvider.notifier)
                              .login(email: widget.email, password: password);
                          // join/login은 실패 시 예외 대신 에러 상태로 바뀌므로,
                          // 실제 로그인 성공(에러 상태 아님)일 때만 환영 메시지를 띄움
                          if (ref.read(userProvider) is! UserLoginErrorErrorModel) {
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text('$nickname님, 회원가입이 완료되었습니다. 환영합니다!'),
                              ),
                            );
                          }
                        },
                text: '회원가입 완료',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color? _nicknameBorderColor() {
    if (nickname.isEmpty) return null;
    if (nickname.length < 2 || (isNicknameDup ?? false)) return RED_COLOR;
    if (isNicknameDup == null) return null;
    return BLUE_COLOR;
  }

  Widget _inputLabel({required String label}) {
    return Container(
      alignment: Alignment.topLeft,
      child: Text(
        label,
        style: TextStyle(color: Color(0xff8c8c8c), fontSize: 12.sp),
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

  Text _renderNicknameMessage() {
    bool isError = true;
    String message = '';
    if (nickname.isNotEmpty) {
      if (nickname.trim().length < 2 || nickname.trim().length > 10) {
        message = '닉네임의 최소 길이는 2, 최대 길이는 10입니다.';
      }
      if (isNicknameDup != null) {
        if (!isNicknameDup!) {
          isError = false;
          message = '사용 가능한 닉네임입니다.';
        } else {
          message = '이미 사용중인 닉네임입니다.';
        }
      }
    }
    return Text(
      message,
      style: TextStyle(
        fontSize: 12.sp,
        color: isError ? RED_COLOR : BLUE_COLOR,
      ),
    );
  }
}
