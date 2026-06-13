import 'dart:async';
import 'dart:developer';
import 'dart:math' hide log;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:mma_flutter/common/component/point_with_icon.dart';
import 'package:mma_flutter/common/const/colors.dart';
import 'package:mma_flutter/common/provider/interstitial_ad_provider.dart';
import 'package:mma_flutter/game/model/game_args.dart';
import 'package:mma_flutter/game/provider/game_provider.dart';
import 'package:mma_flutter/main.dart';

class GameEndScreen extends ConsumerStatefulWidget {
  static String get routeName => 'game_end';

  final bool isNormal;
  final GameType gameType;

  const GameEndScreen({
    required this.isNormal,
    required this.gameType,
    super.key,
  });

  @override
  ConsumerState<GameEndScreen> createState() => _GameEndScreenState();
}

class _GameEndScreenState extends ConsumerState<GameEndScreen> {
  late int _rand;
  bool _error = false;
  bool _loading = true;
  bool _adShown = false;
  late int correctCnt;
  int displayPoint = 0; // 화면에 보여줄 값
  Timer? _rollingTimer;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _rand = Random().nextInt(3);
    correctCnt =
        await ref
            .read(
              gameProvider(
                GameArgs(isNormal: widget.isNormal, type: widget.gameType),
              ).notifier,
            )
            .getCorrectCount();
    if (correctCnt == -1) {
      setState(() {
        _error = true;
      });
    }
    setState(() {
      _loading = false;
    });
    _startRolling(); // 랜덤 롤링 시작
  }

  @override
  void dispose() {
    _rollingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: false),
      body: SafeArea(
        child: Column(
        children: [
          Expanded(
            child: Center(
              child: Column(
                children: [
                  SizedBox(height: 80.h),
                  SizedBox(
                    height: 88.h,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Image.asset('asset/img/component/black.png'),
                        Text(
                          '보상',
                          style: context.text.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 24.sp,
                            color: WHITE_COLOR,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 46.h),
                    child: Container(
                      height: 52.h,
                      width: 284.w,
                      decoration: BoxDecoration(
                        border: Border.all(color: BLUE_COLOR, width: 2.w),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Center(
                        child:
                            !_error
                                ? PointWithIcon(
                                  point: displayPoint,
                                  distance: 20.w,
                                  iconSize: 24,
                                  fontSize: 30.sp,
                                )
                                : Text('오류 발생'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 0.h, 16.w, 20.h),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                fixedSize: Size(370.w, 35.h),
                disabledBackgroundColor: GREY_COLOR,
                backgroundColor: BLUE_COLOR,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadiusGeometry.circular(8.r),
                ),
              ),
              onPressed:
                  _loading || !_adShown
                      ? null
                      : () {
                        context.go('/?tab=2');
                      },
              child: Text(
                '종료',
                style: context.text.bodyMedium?.copyWith(fontSize: 15.sp),
              ),
            ),
          ),
        ],
        ),
      ),
    );
  }

  void _startRolling() {
    final random = Random();
    int elapsedMs = 0;

    _rollingTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      elapsedMs += 50;
      if (elapsedMs < 700) {
        setState(() {
          displayPoint = random.nextInt(200) + 1;
        });
      }

      if (elapsedMs >= 700) {
        // 0.7초 후 실제 값으로 고정
        setState(() {
          displayPoint = correctCnt * (widget.isNormal ? 5 : 10);
        });
      }

      if (elapsedMs >= 800) {
        timer.cancel();
        if (_rand % 3 == 0) {
          log('show ad');
          ref
              .read(interstitialAdProvider.notifier)
              .show(
                onComplete: () {
                  if (mounted) {
                    setState(() {
                      _adShown = true;
                    });
                  }
                },
              );
        } else {
          setState(() {
            _adShown = true;
          });
        }
        return;
      }
    });
  }
}
