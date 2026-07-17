import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mma_flutter/common/component/fighter_image.dart';
import 'package:mma_flutter/common/component/retry_loading/custom_circular_progess_indicator.dart';
import 'package:mma_flutter/common/component/retry_loading/retry_button.dart';
import 'package:mma_flutter/common/const/colors.dart';
import 'package:mma_flutter/common/screen/home_splash_screen.dart';
import 'package:mma_flutter/common/utils/date_utils.dart';
import 'package:mma_flutter/common/utils/fight_utils.dart';
import 'package:mma_flutter/home/component/home_promotion_banner.dart';
import 'package:mma_flutter/home/component/user_punished_dialog.dart';
import 'package:mma_flutter/home/provider/home_future_provider.dart';
import 'package:mma_flutter/main.dart';
import 'package:mma_flutter/stream/stream_main_view.dart';
import 'package:mma_flutter/user/model/user_model.dart';
import 'package:mma_flutter/user/provider/user_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  bool _shownPunishDialog = false;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final data = ref.watch(homeFutureProvider);
    final userState = ref.watch(userProvider);

    return data.when(
      error:
          (error, stackTrace) =>
              RetryButton(onRetry: () => ref.invalidate(homeFutureProvider)),
      loading: () => Center(child: HomeSplashScreen(isUserStateLoading: false)),
      data: (data) {
        final user = ref.read(userProvider);

        if (data == null) {
          return Center(
            child: Text('아직 차후 경기 일정이 없습니다.', style: context.text.bodyMedium),
          );
        }
        if (user is! UserModel) {
          return CustomCircularProgressIndicator();
        }
        if (!_shownPunishDialog && user.reportedReason != null) {
          _shownPunishDialog = true;

          WidgetsBinding.instance.addPostFrameCallback((_) {
            showDialog(
              context: context,
              builder: (context) {
                return UserPunishedDialog(
                  reason: user.reportedReason!,
                  restrictEndAt: user.restrictEndAt!,
                );
              },
            );
          });
        }

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors:
                  context.isDark
                      ? const [
                        Color(0xFF0F0F10),
                        Color(0xFF151516),
                        Color(0xFF1F2022),
                        Color(0xFF161618),
                        Color(0xFF0F0F10),
                      ]
                      : const [
                        Color(0xFFFFFAF8),
                        Color(0xFFFAF5F3),
                        Color(0xFFF0EBE8),
                        Color(0xFFF5F0ED),
                        Color(0xFFFFFAF8),
                      ],
              stops: const [0.0, 0.049, 0.180, 0.603, 0.739],
            ),
          ),
          child: SingleChildScrollView(
            physics:
                Platform.isIOS
                    ? const BouncingScrollPhysics()
                    : const ClampingScrollPhysics(),
            child: Column(
              children: [
                SizedBox(
                  height: 500.h,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (data.activePromotions.homePromotions.isNotEmpty)
                        Positioned(
                          top: 6.h,
                          child: HomePromotionBanner(
                            homePromotionModel: data.activePromotions.homePromotions.first,
                          ),
                        ),
                      Positioned(
                        top: 57.h,
                        left: 0,
                        right: 0,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Image.asset(
                              'asset/img/component/black_home.png',
                              height: 169.h,
                              width: double.infinity,
                            ),
                            Positioned(
                              top: 64.h,
                              child: Text(
                                CustomFightUtils.extractLastName(
                                  data.winnerName,
                                ),
                                style: TextStyle(
                                  color: context.colors.onSurface,
                                  fontSize: 65.sp,
                                  fontFamily: 'Dalmation',
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 36.h,
                              child: Text(
                                '${CustomFightUtils.fightWeightClassMap[data.fightWeight] ?? '-'} ${data.title ? '타이틀전' : '매치'}',
                                style: context.text.bodyMedium?.copyWith(
                                  fontSize: 16.sp,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 219.h,
                        child: Text(
                          'VS',
                          style: TextStyle(
                            color: context.colors.onSurface,
                            fontSize: 35.sp,
                            fontWeight: FontWeight.w400,
                            fontFamily: 'dalmation',
                          ),
                        ),
                      ),
                      Positioned(
                        top: 218.h,
                        left: 0,
                        right: 0,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Image.asset(
                              'asset/img/component/black_home.png',
                              height: 169.h,
                              width: double.infinity,
                            ),
                            Text(
                              CustomFightUtils.extractLastName(data.loserName),
                              style: TextStyle(
                                color: context.colors.onSurface,
                                fontSize: 65.sp,
                                fontFamily: 'Dalmation',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 215.h,
                        left: 0,
                        right: 0,
                        child: Row(
                          children: [
                            Expanded(
                              child: ClipRect(
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: _renderImageWithOpacity(context,imgUrl: data.winnerBodyUrl),
                                ),
                              ),
                            ),
                            Expanded(
                              child: ClipRect(
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Transform(
                                    alignment: Alignment.center,
                                    transform:
                                        Matrix4.identity()
                                          ..scaleByDouble(-1.0, 1.0, 1.0, 1.0),
                                    child: _renderImageWithOpacity(context,imgUrl: data.loserBodyUrl),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _renderName(
                          name: CustomFightUtils.extractLastName(
                            data.winnerKoreanName ?? data.winnerName,
                          ),
                          borderColor: RED_COLOR,
                        ),
                        _renderName(
                          name: CustomFightUtils.extractLastName(
                            data.loserKoreanName ?? data.loserName,
                          ),
                          borderColor: BLUE_COLOR,
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 26.h, bottom: 11.h),
                      child:
                          data.mainCardDateTimeInfo != null
                              ? Text(
                                '${CustomDateUtils.formatDateWithYear(data.mainCardDateTimeInfo!.date)} '
                                '| KST ${CustomDateUtils.formatDurationToHHMM(data.mainCardDateTimeInfo!.time)}',
                                style: context.text.bodySmall?.copyWith(
                                  fontSize: 12.sp,
                                  letterSpacing: 3.0,
                                ),
                                textAlign: TextAlign.center,
                              )
                              : SizedBox(height: 12.h),
                    ),
                    Container(
                      width: 230.w,
                      height: 37.h,
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.red, Colors.blue], // 빨 -> 파
                        ),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: ElevatedButton(
                        onPressed:
                            userState is! UserModel
                                ? null
                                : () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) {
                                        // 홈 배너의 핵심 유도 = 경기 예측 → PICK 탭(인덱스 2)으로 진입
                                        return StreamMainView(
                                          user: userState,
                                          initialTabIndex: 2,
                                        );
                                      },
                                    ),
                                  );
                                },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: context.colors.surface, // 내부 배경
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                        child: Text(
                          "경기 예측하러 가기",
                          style: context.text.bodyMedium!.copyWith(
                            color: context.colors.onSurface,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  _renderName({required String name, required Color borderColor}) {
    return Container(
      constraints: BoxConstraints(minHeight: 24.h, minWidth: 163.w),
      padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 10.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: borderColor, width: 2.w),
        color: context.colors.surface,
      ),
      child: Text(
        name,
        style: context.text.bodyMedium?.copyWith(
          overflow: TextOverflow.ellipsis,
          fontWeight: FontWeight.w600,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _renderImageWithOpacity(BuildContext context,{required String? imgUrl}) {
    return Container(
      foregroundDecoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.center,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            context.colors.surface.withValues(alpha: 0.6),
          ],
        ),
      ),
      child: FighterImage.body(
        imageUrl: imgUrl,
        height: 360.h,
        width: 246.w,
      ),
    );
  }
}
