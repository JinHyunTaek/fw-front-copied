import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mma_flutter/common/const/colors.dart';
import 'package:mma_flutter/common/const/style.dart';
import 'package:mma_flutter/main.dart';
import 'package:mma_flutter/stream/bet/component/buttons/round_buttons.dart';
import 'package:mma_flutter/stream/bet/component/buttons/win_method_buttons.dart';
import 'package:mma_flutter/stream/bet/component/buttons/x_of_the_night_button.dart';
import 'package:mma_flutter/stream/bet/model/bet_response_model.dart';

class BetHistoryCard extends StatelessWidget {
  final SingleBetCardResponseModel betResponse;

  const BetHistoryCard({required this.betResponse, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 13.h),
          child: Text(
            '${betResponse.myWinnerName} vs ${betResponse.myLoserName}',
            style: context.text.bodyMedium?.copyWith(fontSize: 17.sp),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                _renderNameBox(
                  context,
                  label: '승',
                  name:
                      betResponse.betPrediction.draw
                          ? betResponse.redName
                          : betResponse.myWinnerName!,
                  bgColor:
                      betResponse.betPrediction.draw
                          ? DARK_GREY_COLOR
                          : _mainColor,
                  textColor:
                      betResponse.betPrediction.draw ? GREY_COLOR : WHITE_COLOR,
                ),
                SizedBox(height: 6.h),
                _renderNameBox(
                  context,
                  label: '패',
                  name:
                      betResponse.betPrediction.draw
                          ? betResponse.blueName
                          : betResponse.myLoserName!,
                  bgColor: DARK_GREY_COLOR,
                  textColor: GREY_COLOR,
                ),
              ],
            ),
            SizedBox(width: 11.w),
            Container(
              width: 83.w,
              height: 60.h,
              decoration: BoxDecoration(
                color:
                    betResponse.betPrediction.draw
                        ? Color(0xff8a38f5)
                        : DARK_GREY_COLOR,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Center(
                child: Text(
                  '무승부',
                  style: defaultTextStyle.copyWith(
                    fontSize: 15.sp,
                    color: betResponse.betPrediction.draw ? null : GREY_COLOR,
                  ),
                ),
              ),
            ),
          ],
        ),

        /// winMethod != null -> selectedWinMethodIndex는 null이 될 수 없음
        if (betResponse.betPrediction.winMethod != null)
          Padding(
            padding: EdgeInsets.only(top: 11.h),
            child: WinMethodButtons(
              mainColor: _mainColor,
              selectedWinMethodIndex:
                  betResponse.betPrediction.winMethod!.index,
            ),
          ),
        if (betResponse.betPrediction.finishRound != null)
          Padding(
            padding: EdgeInsets.only(top: 11.h),
            child: RoundButtons(
              isFiveRound:
                  betResponse.isFiveRound ||
                  betResponse.betPrediction.finishRound! > 3,
              selectedFinishRoundIndex: betResponse.betPrediction.finishRound! - 1,
              mainColor: _mainColor,
            ),
          ),
        if (betResponse.betPrediction.isFotN)
          Padding(
            padding: EdgeInsets.only(top: 11.h),
            child: XOfTheNightButton(
              index: -1,
              mainColor:
                  betResponse.betPrediction.draw
                      ? Color(0xff8a38f5)
                      : _mainColor,
              selected: true,
              isFotN: true,
            ),
          ),
        if (betResponse.betPrediction.isPotN)
          Padding(
            padding: EdgeInsets.only(top: 11.h),
            child: XOfTheNightButton(
              index: -1,
              mainColor:
                  betResponse.betPrediction.draw
                      ? Color(0xff8a38f5)
                      : _mainColor,
              selected: true,
              isFotN: false,
            ),
          ),
      ],
    );
  }

  Widget _renderNameBox(
    BuildContext context, {
    required String label,
    required String name,
    required Color bgColor,
    required Color textColor,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 60.w,
          child: Center(
            child: Text(
              label,
              style: context.text.bodyMedium?.copyWith(fontSize: 12.sp),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(8.r),
          ),
          width: 208.w,
          height: 27.h,
          child: Center(
            child: Text(
              name,
              style: TextStyle(color: textColor, fontSize: 15.sp),
            ),
          ),
        ),
      ],
    );
  }

  Color get _mainColor =>
      betResponse.redName == betResponse.myWinnerName ? RED_COLOR : BLUE_COLOR;
}
