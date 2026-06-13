import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mma_flutter/common/const/colors.dart';
import 'package:mma_flutter/fight_event/model/fight_event_model.dart';
import 'package:mma_flutter/fight_event/model/fighter_fight_event_detail_model.dart';
import 'package:mma_flutter/main.dart';
import 'dart:developer';

class FighterFightEventDetailStat extends StatelessWidget {

  final FighterFightEventFighterModel winner;
  final FighterFightEventFighterModel loser;

  const FighterFightEventDetailStat({required this.winner,required this.loser, super.key});

  @override
  Widget build(BuildContext context) {
    log(winner.birthday?.toString() ?? '');
    return Column(
      children: [
        _renderBoxWithFightersInfo(
          label: '랭킹',
          f1Info: winner.ranking != null ? winner.ranking == 0 ? 'C' : winner.ranking.toString() : '-',
          f2Info: loser.ranking != null ? loser.ranking == 0 ? 'C' : loser.ranking.toString() : '-',
          context: context,
        ),
        _renderBoxWithFightersInfo(
          label: '나이',
          f1Info: winner.birthday != null ? _calculateAge(winner.birthday!).toString() : '-',
          f2Info: loser.birthday != null ? _calculateAge(loser.birthday!).toString() : '-',
          context: context,
        ),
        _renderBoxWithFightersInfo(
          label: '신장',
          f1Info: '${winner.height}cm',
          f2Info: '${loser.height}cm',
          context: context,
        ),
        _renderBoxWithFightersInfo(
          label: '무게',
          f1Info: '${winner.weight.toString()}kg',
          f2Info: '${loser.weight.toString()}kg',
          context: context,
        ),
        _renderBoxWithFightersInfo(
          context: context,
          label: '리치',
          f1Info: '${winner.reach}cm',
          f2Info: '${loser.reach}cm',
        ),
        _renderBoxWithFightersInfo(
          label: '전적',
          f1Info: _renderRecord(winner.record),
          f2Info: _renderRecord(loser.record),
          context: context,
        ),
      ],
    );
  }

  Widget _renderBoxWithFightersInfo({
    required String label,
    required String f1Info,
    required String f2Info,
    required BuildContext context,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 30.h),
      child: SizedBox(
        height: 22.h,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 100.w,
              child: Text(
                f1Info,
                style: context.text.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(width: 20.w),
            SizedBox(
              width: 94.w,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(color: RED_COLOR, width: 2.w, height: 17.h),
                  Text(
                    label,
                    style: context.text.bodyMedium?.copyWith(
                      color: Colors.grey
                    ),
                  ),
                  Container(color: BLUE_COLOR, width: 2.w, height: 17.h),
                ],
              ),
            ),
            SizedBox(width: 20.w),
            SizedBox(
              width: 100.w,
              child: Text(
                f2Info,
                style: context.text.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _calculateAge(DateTime birthday) {
    DateTime now = DateTime.now();
    int age = now.year - birthday.year;
    if (birthday.month < now.month ||
        (birthday.month == now.month && birthday.day < now.day)) {
      age--;
    }
    return age;
  }

  String _renderRecord(FightRecordModel record) {
    return '${record.win}승 ${record.loss}패 ${record.draw}무';
  }
}
