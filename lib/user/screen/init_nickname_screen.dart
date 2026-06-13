import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mma_flutter/common/const/colors.dart';
import 'package:mma_flutter/common/const/style.dart';
import 'package:mma_flutter/common/layout/default_layout.dart';
import 'package:mma_flutter/main.dart';
import 'package:mma_flutter/user/provider/user_provider.dart';

class InitNicknameScreen extends ConsumerStatefulWidget {
  static String get routeName => 'init_nickname';

  const InitNicknameScreen({super.key});

  @override
  ConsumerState<InitNicknameScreen> createState() => _InitNicknameScreenState();
}

class _InitNicknameScreenState extends ConsumerState<InitNicknameScreen> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _showNicknameDialog();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: SizedBox.shrink());
  }

  void _showNicknameDialog() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        String? errorText;
        return StatefulBuilder(
          builder: (context, setState) {
            return PopScope(
              canPop: false,
              child: AlertDialog(
                backgroundColor: context.colors.box,
                title: const Text(
                  '닉네임 설정',
                  style: TextStyle(color: Colors.white),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),

                        fillColor: Color(0xFF2C2C2C),
                        hintText: '닉네임을 입력하세요',
                        hintStyle: TextStyle(
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                    if (errorText != null)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          errorText!,
                          style: TextStyle(color: Colors.red, fontSize: 12.sp),
                        ),
                      ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () async {
                      final nickname = _controller.text.trim();
                      if (nickname.length < 2 || nickname.length > 10) {
                        setState(() {
                          errorText = '닉네임은 최소 2글자, 최대 10글자입니다.';
                        });
                        return;
                      }
                      try {
                        final isDup = await ref
                            .read(userProvider.notifier)
                            .checkDupNickname(nickname);
                        if (!isDup) {
                          final res = await ref
                              .read(userProvider.notifier)
                              .updateNickname(nickname);
                          if(res) {
                            Navigator.of(context).pop();
                          }else{
                            setState(() {
                              errorText = '알 수 없는 오류가 발생했습니다. 다시 시도해주세요.';
                            });
                          }
                        } else {
                          setState(() {
                            errorText = '이미 사용 중인 닉네임입니다';
                          });
                        }
                      } catch (e) {
                        setState(() {
                          errorText = '오류가 발생했습니다. 다시 시도해주세요';
                        });
                      }
                    },
                    child: Text('확인',style: context.text.bodyMedium,),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
