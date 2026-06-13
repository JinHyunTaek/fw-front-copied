import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mma_flutter/common/const/data.dart';
import 'package:mma_flutter/common/utils/date_utils.dart';
import 'package:mma_flutter/fight_event/model/abst/i_fight_event_model.dart';
import 'package:mma_flutter/fight_event/model/card_date_time_info_model.dart';
import 'package:mma_flutter/main.dart';

class FightEventCardSequence {
  const FightEventCardSequence._();

  static Widget? buildSequenceHeader(
    BuildContext context, {
    required IFightEventModel fe,
    required int index,
  }) {
    String? text;
    CardDateTimeInfoModel? info;

    if (index == 0) {
      text = '메인 카드';
      info = fe.mainCardDateTimeInfo;
    } else if (fe.mainCardCnt == index) {
      text = '언더 카드';
      info = fe.prelimCardDateTimeInfo;
    } else if (fe.earlyCardCnt != null &&
        fe.mainCardCnt! + fe.prelimCardCnt! == index) {
      text = '파이트 패스 언더 카드';
      info = fe.earlyCardDateTimeInfo;
    }

    if (text == null || info == null) return null;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Text(
        '$text (${CustomDateUtils.formatDurationToHHMM(info.time)})',
        style: context.text.bodyMedium?.copyWith(
          fontSize: 20.sp,
          color: context.colors.onSurface,
        ),
      ),
    );
  }

  static (CardDateTimeInfoModel?, String) resolveCardSequenceInfo(
    IFightEventModel fe,
    int index,
  ) {
    if (index < fe.mainCardCnt!) {
      return (fe.mainCardDateTimeInfo, mainCard);
    } else if (fe.earlyCardDateTimeInfo != null &&
        fe.mainCardCnt! + fe.prelimCardCnt! <= index) {
      return (fe.earlyCardDateTimeInfo, earlyCard);
    } else {
      return (fe.prelimCardDateTimeInfo, prelimCard);
    }
  }
}
