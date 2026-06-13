import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:mma_flutter/common/const/colors.dart';
import 'package:mma_flutter/common/const/data.dart';
import 'package:mma_flutter/common/provider/interstitial_ad_provider.dart';
import 'package:mma_flutter/game/model/game_args.dart';
import 'package:mma_flutter/game/provider/game_provider.dart';
import 'package:mma_flutter/game/screen/game_screen.dart';
import 'package:mma_flutter/main.dart';

class GameDescriptionScreen extends ConsumerStatefulWidget {
  static String get routeName => 'game_desc';

  final GameType gameType;

  const GameDescriptionScreen({required this.gameType, super.key});

  @override
  ConsumerState<GameDescriptionScreen> createState() =>
      _GameDescriptionScreenState();
}

class _GameDescriptionScreenState extends ConsumerState<GameDescriptionScreen> {
  bool? isEasySelected;
  bool startPressed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50.h),
        child: AppBar(),
      ),
      body: Container(
        color: context.colors.surface,
        width: double.infinity,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 37.h),
              child: SvgPicture.asset(
                'asset/img/logo/fight_week_white.svg',
                height: 57.h,
                width: 64.w,
              ),
            ),
            SizedBox(
              height: 500.h,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    top: 20.h,
                    child: Container(
                      width: 329.w,
                      height: 450.h,
                      decoration: BoxDecoration(
                        color: context.colors.surface,
                        borderRadius: BorderRadius.circular(8.r),
                        border: BoxBorder.all(color: BLUE_COLOR, width: 2.w),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    '난이도',
                                    style: context.text.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16.sp,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _renderLevelButtonWithDescription(label: 'EASY'),
                              _renderLevelButtonWithDescription(label: 'HARD'),
                            ],
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              disabledBackgroundColor: context.colors.box,
                              fixedSize: Size(288.w, 35.h),
                              backgroundColor: BLUE_COLOR,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadiusGeometry.circular(
                                  8.r,
                                ),
                              ),
                            ),
                            onPressed:
                                isEasySelected == null || startPressed
                                    ? null
                                    : () async {
                                      setState(() {
                                        startPressed = true;
                                        ref.read(interstitialAdProvider.notifier).load();
                                      });
                                      await ref
                                          .read(gameRepositoryProvider)
                                          .updateAttemptCount(isSubtract: true);
                                      // 안정성 위해 기존 gameProvider 삭제
                                      ref.invalidate(gameProvider);
                                      ref.invalidate(gameAttemptCountProvider);
                                      // ref.invalidate(gameAttemptCountProvider);
                                      context.goNamed(
                                        GameScreen.routeName,
                                        pathParameters: {'seq': '1'},
                                        queryParameters: {
                                          'isNormal':
                                              '${isEasySelected! ? true : false}',
                                          'gameType':
                                              widget.gameType.name,
                                        },
                                      );
                                    },
                            child: Center(
                              child: Text(
                                '시작하기',
                                style: context.text.bodyMedium,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0.h,
                    child: Container(
                      height: 44.h,
                      width: 180.w,
                      decoration: BoxDecoration(
                        color: BLUE_COLOR,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Center(
                        child: Text(
                          widget.gameType.description,
                          style: context.text.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 15.sp,
                          ),
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
    );
  }

  Widget _renderLevelButtonWithDescription({required String label}) {
    final isEasy = label == 'EASY' ? true : false;
    return SizedBox(
      width: 130.w,
      child: Column(
        children: [
          SizedBox(
            height: 106.h,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  isEasySelected = isEasy ? true : false;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: context.colors.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadiusGeometry.circular(8.0),
                  side: BorderSide(
                    color:
                        isEasySelected != null &&
                                (isEasy && isEasySelected! ||
                                    !isEasy && !isEasySelected!)
                            ? BLUE_COLOR
                            : GREY_COLOR,
                    width: 2.w,
                  ),
                ),
              ),
              child: Center(
                child: Text(
                  '$label\nMODE',
                  style: context.text.bodyMedium!,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            label == 'EASY' ? easyGameDescription : hardGameDescription,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
