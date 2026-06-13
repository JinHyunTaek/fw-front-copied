import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:mma_flutter/common/component/octagon/octagon_painter.dart';
import 'package:mma_flutter/common/component/retry_loading/custom_circular_progess_indicator.dart';
import 'package:mma_flutter/common/component/retry_loading/retry_button.dart';
import 'package:mma_flutter/common/const/colors.dart';
import 'package:mma_flutter/common/model/base_state_model.dart';
import 'package:mma_flutter/game/component/question/text_question.dart';
import 'package:mma_flutter/game/component/selection/non_grid_selection.dart';
import 'package:mma_flutter/game/model/game_args.dart';
import 'package:mma_flutter/game/provider/game_provider.dart';
import 'package:mma_flutter/game/screen/game_end_screen.dart';
import 'package:mma_flutter/main.dart';

class GameScreen extends ConsumerStatefulWidget {
  static String get routeName => 'game';

  final int seq;
  final bool isNormal;
  final GameType gameType;

  const GameScreen({
    required this.seq,
    required this.isNormal,
    required this.gameType,
    super.key,
  });

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  int? selectedAnswerIdx;
  Timer? timer;
  int currentTimeSec = 15;
  bool showResult = false;

  /**
   * GoRouter는 GameScreen을 같은 라우트로 보고
   * 단지 path parameter (seq)만 바뀐 것으로 인식해서
   * 기존의 GameScreen 인스턴스를 재사용 (seq=1일 때만 initState 호출됨)
   */
  @override
  void initState() {
    log('init state');
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    selectedAnswerIdx = null;
    showResult = false;
    _startTimer();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = gameProvider(
      GameArgs(isNormal: widget.isNormal, type: widget.gameType),
    );
    final state = ref.watch(provider);

    if (state is StateError) {
      _pauseTimer();
      return _renderScaffold(
        body: RetryButton(onRetry: () => ref.invalidate(provider)),
        canPop: false,
      );
    }

    if (state is StateLoading) {
      _pauseTimer();
      return _renderScaffold(body: CustomCircularProgressIndicator());
    }

    _resumeTimer();

    return _renderScaffold(
      body: _renderBody(
        context,
        game: (state as StateData<GameState>).data!,
        notifier: ref.read(provider.notifier),
      ),
    );
  }

  _renderBody(
    BuildContext context, {
    required GameState game,
    required GameStateNotifier notifier,
  }) {
    return Container(
      color: context.colors.box,
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 16.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [..._renderQuizSeq(widget.seq)],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 30.h, bottom: 16.h),
                      child: Text(
                        'QUIZ ${widget.seq}',
                        style: context.text.bodyMedium?.copyWith(
                          fontSize: 18.sp,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    GameTextQuestion(
                      question: notifier.questions[widget.seq - 1],
                      isFightGame: game.type == GameType.fight,
                    ),
                    NonGridSelection(
                      selectedAnswerIdx: selectedAnswerIdx,
                      selections: game.selectionsList[widget.seq - 1],
                      showResult: showResult,
                      correctAnswer:
                          notifier.getCorrectAnswers()[widget.seq - 1],
                      onTap: (index) {
                        setState(() {
                          selectedAnswerIdx = index;
                        });
                      },
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 40.h, bottom: 8.h),
                      child: CustomPaint(
                        painter: OctagonPainter(
                          strokeColor: BLUE_COLOR,
                          isEasy: true,
                          num: currentTimeSec,
                        ),
                        size: Size(46.w, 46.h),
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
                    selectedAnswerIdx == null || showResult
                        ? null
                        : () {
                          notifier.selectAnswer(
                            widget.seq - 1,
                            game.selectionsList[widget.seq -
                                1][selectedAnswerIdx!],
                          );
                          showResultAndGoToNextScreen();
                        },
                child: Text(
                  widget.seq != 5 ? '다음' : '종료',
                  style: context.text.bodyMedium?.copyWith(fontSize: 15.sp),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget _renderImgForNameQuestion({required NameGameResponseModel question}) {
  //   return SizedBox(
  //     width: 180.w,
  //     height: 180.h,
  //     child: Stack(
  //       children: [
  //         Positioned.fill(
  //           child: CustomPaint(
  //             painter: OctagonPainter(
  //               fillColor: context.colors.surface,
  //               strokeColor: GREY_COLOR,
  //               isEasy: true,
  //               width: 2.w,
  //             ),
  //           ),
  //         ),
  //         ClipPath(
  //           clipper: OctagonClipper(),
  //           child: Image.asset(
  //             question.nameGameCategory == NameGameCategory.country
  //                 ? 'asset/img/component/default-head.png'
  //                 : 'asset/img/component/default-body.png',
  //             height: 170.h,
  //             width: 170.w,
  //             fit: BoxFit.contain,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _renderScaffold({required Widget body, bool canPop = false}) {
    return PopScope(
      canPop: canPop,
      child: Scaffold(
        appBar: AppBar(automaticallyImplyLeading: canPop),
        body: body,
      ),
    );
  }

  List<Widget> _renderQuizSeq(int seq) {
    return List.generate(5, (index) {
      return CustomPaint(
        painter: OctagonPainter(
          num: seq == index + 1 ? seq : null,
          isEasy: true,
          fillColor: seq == index + 1 ? BLUE_COLOR : BLACK_COLOR,
          textSize: 11.sp,
        ),
        size: Size(16.w, 16.h),
      );
    });
  }

  void showResultAndGoToNextScreen() {
    setState(() {
      showResult = true;
    });
    Future.delayed(const Duration(milliseconds: 700), () {
      _pauseTimer();
      context.goNamed(
        widget.seq != 5 ? GameScreen.routeName : GameEndScreen.routeName,
        pathParameters: widget.seq != 5 ? {'seq': '${widget.seq + 1}'} : {},
        queryParameters: {
          'isNormal': '${widget.isNormal}',
          'gameType': widget.gameType.name,
        },
      );
    });
  }

  void _reduceTime(Timer timer) {
    if (currentTimeSec == 0) {
      timer.cancel();
      showResultAndGoToNextScreen();
    } else {
      setState(() {
        currentTimeSec -= 1;
      });
    }
  }

  void _pauseTimer() {
    if (timer != null && timer!.isActive) {
      timer!.cancel();
    }
  }

  void _resumeTimer() {
    if (timer != null && timer!.isActive) return;
    _startTimer();
  }

  void _startTimer() {
    currentTimeSec = 15;
    timer = Timer.periodic(Duration(seconds: 1), _reduceTime);
  }
}
