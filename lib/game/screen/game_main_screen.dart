import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:mma_flutter/common/component/retry_loading/custom_circular_progess_indicator.dart';
import 'package:mma_flutter/common/component/point_with_icon.dart';
import 'package:mma_flutter/common/component/retry_loading/retry_button.dart';
import 'package:mma_flutter/common/const/colors.dart';
import 'package:mma_flutter/common/service/rewarded_ad_manager.dart';
import 'package:mma_flutter/game/model/game_args.dart';
import 'package:mma_flutter/game/provider/game_provider.dart';
import 'package:mma_flutter/game/screen/game_description_screen.dart';
import 'package:mma_flutter/main.dart';
import 'package:mma_flutter/user/model/user_model.dart';
import 'package:mma_flutter/user/provider/user_provider.dart';

class GameMainScreen extends ConsumerWidget {
  static String get routeName => 'game_main';

  const GameMainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);

    if (user is! UserModel) {
      return SizedBox.shrink();
    }

    final ram = ref.watch(rewardedAdProvider);
    final attempt = ref.watch(gameAttemptCountProvider);

    return attempt.when(
      data:
          (data) => SingleChildScrollView(
            physics:
                Platform.isIOS
                    ? const BouncingScrollPhysics()
                    : const ClampingScrollPhysics(),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height / 14,
                    bottom: MediaQuery.of(context).size.height / 10,
                  ),
                  child: SvgPicture.asset(
                    context.isDark
                        ? 'asset/img/logo/fight_week_white.svg'
                        : 'asset/img/logo/fight_week_black.svg',
                    height: 64.h,
                    width: 57.w,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 7.h),
                  child: _renderQuizButton(
                    context,
                    text: GameType.name.description,
                    attemptCount: data.count,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 7.h),
                  child: _renderQuizButton(
                    context,
                    text: GameType.fight.description,
                    attemptCount: data.count,
                  ),
                ),
                SizedBox(height: 42.h),
                _renderBorderContainer(
                  context,
                  label: '내 포인트',
                  child: PointWithIcon(point: user.point),
                ),
                _renderBorderContainer(
                  context,
                  label: '오늘 남은 게임 횟수',
                  child: Text('${data.count}', style: context.text.bodyMedium),
                ),
                ram.isAdReady && data.adCount > 0
                    ? GestureDetector(
                      onTap: () {
                        ram.showRewardedAd((rewardedItem) async {
                          await ref
                              .read(gameRepositoryProvider)
                              .updateAttemptCount(isSubtract: false);
                          ref.invalidate(gameAttemptCountProvider);
                        });
                      },
                      child: Text(
                        '광고 보고 게임 한 판 더 하기',
                        style: context.text.bodyMedium?.copyWith(
                          color: BLUE_COLOR,
                          fontSize: 15.sp,
                        ),
                      ),
                    )
                    : SizedBox(height: 21.h),
              ],
            ),
          ),
      loading: () => CustomCircularProgressIndicator(),
      error:
          (e, s) => RetryButton(
            onRetry: () => ref.invalidate(gameAttemptCountProvider),
          ),
    );
  }

  Widget _renderQuizButton(
    BuildContext context, {
    required String text,
    required int attemptCount,
  }) {
    return SizedBox(
      width: 370.w,
      child: ElevatedButton(
        onPressed:
            attemptCount <= 0
                ? null
                : () {
                  context.goNamed(
                    GameDescriptionScreen.routeName,
                    queryParameters: {
                      'gameType':
                          text == GameType.fight.description
                              ? GameType.fight.name
                              : GameType.name.name,
                    },
                  );
                },
        style: ElevatedButton.styleFrom(
          disabledBackgroundColor: GREY_COLOR,
          backgroundColor: BLUE_COLOR,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadiusGeometry.circular(8.r),
          ),
        ),
        child: Center(
          child: Text(
            text,
            style: context.text.bodyMedium?.copyWith(fontSize: 15.sp),
          ),
        ),
      ),
    );
  }

  Widget _renderBorderContainer(
    BuildContext context, {
    required String label,
    required Widget child,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: context.text.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 15.sp,
          ),
        ),
        SizedBox(height: 16.h),
        Container(
          height: 36.h,
          width: 226.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.r),
            border: BoxBorder.all(color: BLUE_COLOR, width: 2.w),
          ),
          child: Center(child: child),
        ),
        SizedBox(height: 20.h),
      ],
    );
  }
}
