import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mma_flutter/common/const/colors.dart';
import 'package:mma_flutter/common/utils/date_utils.dart';
import 'package:mma_flutter/common/utils/fight_utils.dart';
import 'package:mma_flutter/fight_event/component/card/fighter_fight_event_card_row.dart';
import 'package:mma_flutter/fight_event/model/card_date_time_info_model.dart';
import 'package:mma_flutter/fight_event/screen/fighter_fight_event/fighter_fight_event_detail_screen.dart';
import 'package:mma_flutter/main.dart';
import 'package:mma_flutter/stream/model/stream_fight_event_model.dart';

class StreamFighterFightEventCard extends ConsumerStatefulWidget {
  final StreamFighterFightEventModel ffe;
  final bool checkboxValue;
  final void Function(bool?) checkboxOnChanged;
  final DateTime? mainCardInfo;
  final CardDateTimeInfoModel? cardInfo;
  final String? whichCard;

  const StreamFighterFightEventCard({
    super.key,
    required this.ffe,
    required this.checkboxValue,
    required this.checkboxOnChanged,
    required this.mainCardInfo,
    this.cardInfo,
    this.whichCard,
  });

  @override
  ConsumerState<StreamFighterFightEventCard> createState() =>
      _FightEventCardState();
}

class _FightEventCardState extends ConsumerState<StreamFighterFightEventCard> {
  bool isExpanded = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool? checkBoxValue = widget.checkboxValue;

    return Center(
      child: SizedBox(
        width: 362.w,
        child: Column(
          children: [
            Row(
              children: [
                if (widget.mainCardInfo != null &&
                    !CustomDateUtils.isBettingRestricted(widget.mainCardInfo!))
                  Transform.scale(
                    scale: 0.8,
                    child: Checkbox(
                      value: checkBoxValue,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      onChanged: widget.checkboxOnChanged,
                      side: BorderSide(color: GREY_COLOR),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadiusGeometry.circular(4.r),
                      ),
                      fillColor: WidgetStatePropertyAll(WHITE_COLOR),
                      checkColor: BLACK_COLOR,
                    ),
                  ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  child: Text(
                    '${CustomFightUtils.fightWeightClassMap[widget.ffe.fightWeight] ?? widget.ffe.fightWeight} 매치',
                    style: context.text.bodySmall,
                  ),
                ),
              ],
            ),
            InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return FighterFightEventDetailScreen(
                        eventName: widget.ffe.eventName,
                        id: widget.ffe.id,
                        fightWeight: widget.ffe.fightWeight,
                        isTitle: widget.ffe.title,
                        cardStartDateTimeInfo: widget.cardInfo,
                        whichCard: widget.whichCard,
                      );
                    },
                  ),
                );
              },
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 4.h),
                child: FighterFightEventCardRow(
                  ffe: widget.ffe,
                  betRateBar: _betRateBar(
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _betRateBar() {
    int firstFighterRate = firstFighterCountToRate(
      first: widget.ffe.firstFighterBetCount.toInt(),
      last: widget.ffe.lastFighterBetCount.toInt(),
    );
    int lastFighterRate = 100 - firstFighterRate;
    if (widget.ffe.winnerChanged) {
      int temp = firstFighterRate;
      firstFighterRate = lastFighterRate;
      lastFighterRate = temp;
    }
    return Container(
      padding: EdgeInsets.only(top: 2.h, bottom: 10.h),
      child: SizedBox(
        width: 342.w,
        child: Row(
          children: [
            Expanded(
              flex: firstFighterRate,
              child: Container(
                padding: EdgeInsets.only(left: 12.w, right: 4.w),
                decoration: BoxDecoration(
                  color: RED_COLOR,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(2.r),
                    bottomLeft: Radius.circular(2.r),
                  ),
                ),
                child: Text(
                  '$firstFighterRate%',
                  overflow: TextOverflow.ellipsis,
                  style: context.text.bodyMedium?.copyWith(
                    color: WHITE_COLOR,
                    fontSize: 12.sp,
                  ),
                  textAlign: TextAlign.start,
                ),
              ),
            ),
            Expanded(
              flex: lastFighterRate,
              child: Container(
                padding: EdgeInsets.only(right: 12.w, left: 4.w),
                decoration: BoxDecoration(
                  color: BLUE_COLOR,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(2.r),
                    bottomRight: Radius.circular(2.r),
                  ),
                ),
                child: Text(
                  '$lastFighterRate%',
                  overflow: TextOverflow.ellipsis,
                  style: context.text.bodyMedium?.copyWith(
                    color: WHITE_COLOR,
                    fontSize: 12.sp,
                  ),
                  textAlign: TextAlign.end,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  int firstFighterCountToRate({required int first, required int last}) {
    return first == 0 && last == 0
        ? 50
        : (first / (first + last) * 100).round();
  }
}
