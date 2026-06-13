import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mma_flutter/common/component/retry_loading/custom_circular_progess_indicator.dart';
import 'package:mma_flutter/common/const/colors.dart';
import 'package:mma_flutter/common/const/style.dart';
import 'package:mma_flutter/main.dart';
import 'package:mma_flutter/setting/account/const/data.dart';
import 'package:mma_flutter/user/model/user_model.dart';
import 'package:mma_flutter/user/model/withdrawal_request.dart';
import 'package:mma_flutter/user/provider/user_provider.dart';

class AccountDeletionScreen extends ConsumerStatefulWidget {
  static String get routeName => 'account_delete';

  const AccountDeletionScreen({super.key});

  @override
  ConsumerState<AccountDeletionScreen> createState() =>
      _AccountDeleteScreenState();
}

class _AccountDeleteScreenState extends ConsumerState<AccountDeletionScreen> {
  WithdrawalCategory? category;
  bool _withdrawing = false;
  String description = '';

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userProvider);
    if (userState is! UserModel) {
      return CustomCircularProgressIndicator();
    }

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            '회원탈퇴',
            style: context.text.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: Container(
          color: context.colors.surface,
          child: Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width / 1.12,
              child: SizedBox.expand(
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 6.h, bottom: 22.h),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '${userState.nickname}님과 이별인가요? 너무 아쉬워요',
                            style: context.text.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      Text(
                        '파이트위크를 아껴주셔서 감사드립니다.\n'
                        '고객님이 느끼셨던 점을 공유해주시면 더욱 즐거운 서비스를 제공할 수 있도록 하겠습니다.',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: LIGHT_GREY_COLOR,
                        ),
                        textAlign: TextAlign.start,
                      ),
                      SizedBox(height: 23.h),
                      ..._renderWithdrawalCategories(),
                      SizedBox(
                        width: 360.w,
                        child: TextField(
                          maxLines: 3,
                          style: context.text.bodyMedium,
                          cursorColor: context.colors.onSurface,
                          decoration: InputDecoration(
                            hintText: '탈퇴 사유를 적어주시면, 서비스 개선에 중요한 자료가 됩니다.',
                            hintStyle: TextStyle(
                              color: Color(0xffb3b3b3),
                              fontSize: 12.sp,
                              letterSpacing: 0,
                            ),
                            hoverColor: WHITE_COLOR,
                            focusColor: WHITE_COLOR,
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 8.h,
                              horizontal: 8.w,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xffb3b3b3)),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: BLUE_COLOR),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {
                              description = value;
                            });
                          },
                        ),
                      ),
                      SizedBox(height: 40.h),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: GREY_COLOR,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadiusGeometry.circular(
                                    8.r,
                                  ),
                                ),
                              ),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text(
                                '취소',
                                style: defaultTextStyle.copyWith(
                                  fontSize: 12.sp,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: ElevatedButton(
                              onPressed:
                                  category == null ||
                                          (category ==
                                                  WithdrawalCategory.other &&
                                              description.isEmpty)
                                      ? null
                                      : () {
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            Future<void> onConfirm() async {
                                              setState(() {
                                                _withdrawing = true;
                                              });
                                              await ref
                                                  .read(userProvider.notifier)
                                                  .delete(
                                                    request: WithdrawalRequest(
                                                      category: category!,
                                                      description: description,
                                                    ),
                                                  );
                                              if (mounted) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      '탈퇴가 완료되었습니다. 그동안 파이트위크를 이용해주셔서 감사합니다.',
                                                    ),
                                                  ),
                                                );
                                              }
                                            }

                                            if (Platform.isIOS) {
                                              return CupertinoAlertDialog(
                                                title: Text('회원탈퇴'),
                                                content: Text(
                                                  '탈퇴 시 회원님의 포인트 및 모든 활동 정보가 삭제되고, 7일동안 재가입이 불가합니다.\n탈퇴하시겠습니까?',
                                                ),
                                                actions: [
                                                  CupertinoDialogAction(
                                                    onPressed: _withdrawing ? null : () => Navigator.of(context).pop(),
                                                    child: Text('취소'),
                                                  ),
                                                  CupertinoDialogAction(
                                                    isDestructiveAction: true,
                                                    onPressed: _withdrawing ? null : onConfirm,
                                                    child: Text('탈퇴'),
                                                  ),
                                                ],
                                              );
                                            }

                                            return SimpleDialog(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadiusGeometry.circular(
                                                      8.r,
                                                    ),
                                              ),
                                              title: Center(
                                                child: Text(
                                                  '탈퇴 시 회원님의 포인트 및 모든 활동 정보가\n삭제되고, 7일동안 재가입이 불가합니다.\n'
                                                  '탈퇴하시겠습니까?\n',
                                                  style: defaultTextStyle
                                                      .copyWith(
                                                        fontSize: 13.sp,
                                                      ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                              backgroundColor: DARK_GREY_COLOR,
                                              children: [
                                                Row(
                                                  children: [
                                                    _renderAskingWithdrawalButton(
                                                      onPressed:
                                                          _withdrawing
                                                              ? null
                                                              : () =>
                                                                  Navigator.of(
                                                                    context,
                                                                  ).pop(),
                                                      label: '취소',
                                                      bgColor: BLACK_COLOR,
                                                      right: false,
                                                    ),
                                                    SizedBox(width: 12.w),
                                                    _renderAskingWithdrawalButton(
                                                      onPressed:
                                                          _withdrawing
                                                              ? null
                                                              : onConfirm,
                                                      label: '확인',
                                                      bgColor: BLUE_COLOR,
                                                      right: true,
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: BLUE_COLOR,
                                disabledBackgroundColor: GREY_COLOR,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadiusGeometry.circular(
                                    8.r,
                                  ),
                                ),
                              ),
                              child: Text(
                                '탈퇴하기',
                                style: defaultTextStyle.copyWith(
                                  fontSize: 12.sp,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _renderWithdrawalCategories() {
    return WithdrawalCategory.values
        .map(
          (e) => InkWell(
            onTap: () {
              setState(() {
                category = e;
              });
            },
            child: Padding(
              padding: EdgeInsets.only(bottom: 18.h),
              child: Row(
                children: [
                  Icon(
                    category == e
                        ? Icons.check_circle_outline
                        : Icons.radio_button_unchecked,
                    color: category == e ? BLUE_COLOR : Color(0xffb3b3b3),
                    size: 22.sp,
                  ),
                  SizedBox(width: 8.w),
                  Text(e.korean, style: context.text.bodySmall),
                ],
              ),
            ),
          ),
        )
        .toList();
  }

  Widget _renderAskingWithdrawalButton({
    required VoidCallback? onPressed,
    required String label,
    required Color bgColor,
    required bool right,
  }) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.only(
          right: right ? 20.w : 0.w,
          left: !right ? 20.w : 0.w,
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.zero,
            backgroundColor: bgColor,
            disabledBackgroundColor: GREY_COLOR,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadiusGeometry.circular(8.r),
            ),
          ),
          onPressed: onPressed,
          child: Text(label, style: defaultTextStyle.copyWith(fontSize: 12.sp)),
        ),
      ),
    );
  }
}
