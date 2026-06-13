import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:mma_flutter/fight_event/component/card/fighter_fight_event_card_row.dart';
import 'package:mma_flutter/fight_event/model/card_date_time_info_model.dart';
import 'package:mma_flutter/fight_event/model/fight_event_model.dart';
import 'package:mma_flutter/fight_event/screen/fighter_fight_event/fighter_fight_event_detail_screen.dart';

class FighterFightEventCard extends StatelessWidget {
  final FighterFightEventModel ffe;
  /// fightEventCard or fighterFightEventCard
  final CardDateTimeInfoModel? cardStartDateTimeInfo;
  final String? whichCard;

  const FighterFightEventCard({
    super.key,
    required this.ffe,
    this.cardStartDateTimeInfo,
    this.whichCard,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) {
              return FighterFightEventDetailScreen(
                eventName: ffe.eventName,
                id: ffe.id,
                fightWeight: ffe.fightWeight,
                isTitle: ffe.title,
                cardStartDateTimeInfo: cardStartDateTimeInfo,
                whichCard: whichCard,
                result: ffe.result,
              );
            },
          ),
        );
      },
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 4.h),
        child: FighterFightEventCardRow(ffe: ffe),
      ),
    );
  } 

  String formatDateKey(DateTime date) => DateFormat('yyyy-MM-dd').format(date);
}
