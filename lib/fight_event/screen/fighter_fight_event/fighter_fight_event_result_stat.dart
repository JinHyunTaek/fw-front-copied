import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mma_flutter/common/const/colors.dart';
import 'package:mma_flutter/common/utils/date_utils.dart';
import 'package:mma_flutter/common/utils/fight_utils.dart';
import 'package:mma_flutter/fight_event/model/fight_event_model.dart';
import 'package:mma_flutter/fighter/model/fighter_model.dart';
import 'package:mma_flutter/main.dart';

class FighterFightEventResultStat extends StatelessWidget {
  final FighterModel winner;
  final FighterModel loser;
  final FightResultModel result;

  const FighterFightEventResultStat({
    required this.winner,
    required this.loser,
    required this.result,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 362.w,
          decoration: BoxDecoration(
            color: context.colors.box,
            borderRadius: BorderRadiusGeometry.circular(8.r),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 20.h),
            child: Column(
              children: [
                _renderSingleResultStat(
                  context,
                  label: '승리 방식',
                  value:
                      result.draw
                          ? '무승부'
                          : result.nc
                          ? '무효'
                          : CustomFightUtils.winMethodMap[result.winMethod] ??
                              '',
                ),
                SizedBox(height: 20.h),
                if (result.description != null) ...[
                  _renderSingleResultStat(
                    context,
                    label: '승리 방식(상세)',
                    value: CustomFightUtils.winDescriptionKor(
                      result.description!,
                    ),
                  ),
                  SizedBox(height: 20.h),
                ],
                _renderSingleResultStat(
                  context,
                  label: '경기 종료 라운드',
                  value: '${result.round}R',
                ),
                SizedBox(height: 20.h),
                _renderSingleResultStat(
                  context,
                  label: '경기 소요 시간',
                  value:
                      result.fightDuration != null
                          ? CustomDateUtils.formatDurationToMMSS(
                            result.fightDuration!,
                          )
                          : '-',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _renderSingleResultStat(
    BuildContext context, {
    required String label,
    required String value,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        SizedBox(
          width: 90.w,
          child: Text(
            label,
            style: context.text.bodyMedium?.copyWith(
              fontSize: 12.sp,
              color: context.colors.subText,
            ),
          ),
        ),
        Container(color: RED_COLOR, width: 2.w, height: 17.h),
        SizedBox(
          width: 190.w,
          child: Text(
            value,
            style: context.text.bodyMedium?.copyWith(fontSize: 16.sp),
          ),
        ),
      ],
    );
  }
}
