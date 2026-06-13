import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mma_flutter/common/const/colors.dart';
import 'package:mma_flutter/common/const/style.dart';
import 'package:mma_flutter/main.dart';
import 'package:mma_flutter/user/provider/user_provider.dart';

class NicknameEditComponent extends ConsumerStatefulWidget {
  final String nickname;

  const NicknameEditComponent({required this.nickname, super.key});

  @override
  ConsumerState<NicknameEditComponent> createState() =>
      _NicknameEditComponentState();
}

class _NicknameEditComponentState extends ConsumerState<NicknameEditComponent> {
  bool editing = false;
  final textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40.h,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          !editing
              ? Text(
                widget.nickname,
                style: context.text.bodyMedium?.copyWith(fontSize: 20.sp),
              )
              : SizedBox(
                width: 100.w,
                child: TextField(
                  cursorColor: WHITE_COLOR,
                  style: context.text.bodyMedium,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.only(left: 8.w),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: BLUE_COLOR),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  controller: textController,
                  onSubmitted: (value) async {
                    if (textController.text.length < 2 ||
                        textController.text.length > 10) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('닉네임의 최소 길이는 2, 최대 길이는 10입니다.')),
                      );
                    } else {
                      if(await ref.read(userProvider.notifier)
                          .checkDupNickname(textController.text.trim())){
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('이미 사용중인 닉네임입니다')),
                        );
                      }else {
                        final res = await ref
                            .read(userProvider.notifier)
                            .updateNickname(
                            textController.text);
                        if (!res) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('닉네임은 최대 1주일에 1회 변경 가능합니다')),
                          );
                        }else{
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('닉네임 변경 완료')),
                          );
                        }
                      }
                    }
                    setState(() {
                      editing = false;
                    });
                  },
                ),
              ),
          SizedBox(width: 8.w),
          if(!editing)
          GestureDetector(
            onTap: () {
              setState(() {
                editing = true;
              });
            },
            child: Padding(
              padding: EdgeInsets.only(top: 4.h),
              child: SvgPicture.asset(
                    'asset/img/icon/edit.svg',
                height: 20.h,
                width: 20.w,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
