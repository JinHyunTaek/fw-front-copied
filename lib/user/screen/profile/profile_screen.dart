import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:mma_flutter/common/component/retry_loading/custom_circular_progess_indicator.dart';
import 'package:mma_flutter/common/const/colors.dart';
import 'package:mma_flutter/common/const/data.dart';
import 'package:mma_flutter/common/utils/fight_utils.dart';
import 'package:mma_flutter/main.dart';
import 'package:mma_flutter/user/model/user_model.dart';
import 'package:mma_flutter/user/model/user_profile_model.dart';
import 'package:mma_flutter/user/provider/user_profile_provider.dart';
import 'package:mma_flutter/user/provider/user_provider.dart';
import 'package:mma_flutter/user/screen/profile/footer.dart';
import 'package:mma_flutter/user/screen/profile/nickname_edit_compoment.dart';
import 'package:mma_flutter/user/screen/profile/profile_image_upload_component.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userProvider);
    if (userState is! UserModel) {
      return CustomCircularProgressIndicator();
    }
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(top: 25.h, bottom: 18.h),
          child: ProfileImageUploadComponent(
            user: userState,
          ),
        ),
        NicknameEditComponent(nickname: userState.nickname!),
        Padding(
          padding: EdgeInsets.only(top: 18.h, bottom: 40.h),
          child: _renderBetRecordWithBelt(
            context,
            earnedBetSucceedPoint: userState.earnedBetSucceedPoint,
          ),
        ),
        _renderBeltSequence(context, point: userState.earnedBetSucceedPoint),
        Expanded(child: Footer()),
      ],
    );
  }

  Widget _renderBetRecordWithBelt(
    BuildContext context, {
    required int earnedBetSucceedPoint,
  }) {
    return Container(
      width: 362.w,
      height: 92.h,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Colors.red, Colors.blue]),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: context.colors.onSurface,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          children: [
            Padding(
              padding: EdgeInsets.only(left: 20.w),
              child: beltByPoint(point: earnedBetSucceedPoint),
            ),
            SizedBox(width: 18.w),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      CustomFightUtils.beltNameByPoint(
                        point: earnedBetSucceedPoint,
                      ),
                      style: TextStyle(
                        color: context.colors.surface,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    GestureDetector(
                      onTap: () => _showBeltInfoDialog(context),
                      child: Icon(
                        Icons.help_outline_sharp,
                        color: context.colors.surface.withValues(alpha: 0.7),
                        size: 17.sp,
                      ),
                    ), 
                  ],
                ),
                SizedBox(height: 6.h),
                Consumer(
                  builder: (context, ref, _) {
                    final profileAsync = ref.watch(userProfileProvider);
                    return profileAsync.maybeWhen(
                      data:
                          (profile) => Text(
                            _betRecord(betRecord: profile.userBetRecord),
                            style: TextStyle(
                              color: context.colors.surface,
                              fontSize: 12.sp,
                            ),
                          ),
                      orElse: () => const SizedBox.shrink(),
                    );
                  },
                ),
              ],
            ),
            Expanded(child: SizedBox()),
            Padding(
              padding: EdgeInsets.only(right: 12.w),
              child: Text(
                '${NumberFormat('#,###').format(earnedBetSucceedPoint)} EXP',
                style: context.text.bodyMedium!.copyWith(
                  fontSize: 14.sp,
                  color: context.colors.surface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _renderBeltSequence(BuildContext context, {required int point}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _renderBeltWithName(
          context,
          beltName: '화이트 벨트',
          engBeltName: 'white',
          isUnlocked: true,
        ),
        _renderBeltWithName(
          context,
          beltName: '블루 벨트',
          engBeltName: 'blue',
          isUnlocked: point >= 10000,
        ),
        _renderBeltWithName(
          context,
          beltName: '퍼플 벨트',
          engBeltName: 'purple',
          isUnlocked: point >= 20000,
        ),
        _renderBeltWithName(
          context,
          beltName: '브라운 벨트',
          engBeltName: 'brown',
          isUnlocked: point >= 50000,
        ),
        _renderBeltWithName(
          context,
          beltName: '블랙 벨트',
          engBeltName: 'black',
          isUnlocked: point >= 100000,
        ),
      ],
    );
  }

  Widget _renderBeltWithName(
    BuildContext context, {
    required String beltName,
    required String engBeltName,
    required bool isUnlocked,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 34.w,
          height: 34.h,
          child: isUnlocked
              ? _renderBelt(engBeltName)
              : Stack(
                  children: [
                    _renderBelt(engBeltName),
                    Positioned.fill(
                      child: Align(
                        alignment: Alignment.center,
                        child: SvgPicture.asset(
                          'asset/img/icon/belt/lock.svg',
                          height: 15.h,
                          width: 15.w,
                        ),
                      ),
                    ),
                  ],
                ),
        ),
        SizedBox(height: 8.h),
        Text(
          beltName,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isUnlocked ? context.colors.onSurface : GREY_COLOR,
            fontSize: 12.sp,
          ),
        ),
      ],
    );
  }

  Widget _renderBelt(String engBeltName){
    return Image.asset(
      'asset/img/icon/belt/${engBeltName}_belt.png',
      width: 34.w,
      height: 34.h,
    );
  }

  String _betRecord({required UserBetRecordModel betRecord}) {
    return '${betRecord.win}승 ${betRecord.loss}패(예측 전적)';
  }

  void _showBeltInfoDialog(BuildContext context) {
    const belts = [
      ('white', '화이트 벨트', '0 EXP ~'),
      ('blue', '블루 벨트', '10,000 EXP ~'),
      ('purple', '퍼플 벨트', '20,000 EXP ~'),
      ('brown', '브라운 벨트', '50,000 EXP ~'),
      ('black', '블랙 벨트', '100,000 EXP ~'),
    ];

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: belts.map((belt) {
        final (eng, kor, exp) = belt;
        return SizedBox(
          height: 43.h,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 90.w,
                child: Text(exp, style: context.text.bodySmall?.copyWith(fontSize: 12.sp)),
              ),
              Padding(
                padding: EdgeInsets.only(left: 14.w, right: 8.w),
                child: _renderBelt(eng),
              ),
              Text(kor, style: context.text.bodyMedium?.copyWith(fontSize: 13.sp)),
            ],
          ),
        );
      }).toList(),
    );

    if (Platform.isIOS) {
      showCupertinoDialog(
        context: context,
        builder: (_) => CupertinoAlertDialog(
          title: const Text('점수(EXP) 기준 벨트'),
          content: Padding(
            padding: EdgeInsets.only(top: 12.h),
            child: content,
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('닫기'),
            ),
          ],
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
        backgroundColor: context.colors.box,
        title: Text(
          '점수(EXP) 기준 벨트',
          style: context.text.bodyMedium?.copyWith(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: content,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              '닫기',
              style: context.text.bodySmall?.copyWith(fontSize: 13.sp),
            ),
          ),
        ],
      ),
    );
  }
}
