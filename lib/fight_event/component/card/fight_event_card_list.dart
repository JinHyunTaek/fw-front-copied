import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:mma_flutter/fight_event/component/card/fight_event_card_sequence.dart';
import 'package:mma_flutter/fight_event/component/card/fighter_fight_event_card.dart';
import 'package:mma_flutter/fight_event/model/abst/i_fight_event_model.dart';
import 'package:mma_flutter/fight_event/model/abst/i_fighter_fight_event_model.dart';
import 'package:mma_flutter/fight_event/model/card_date_time_info_model.dart';
import 'package:mma_flutter/fight_event/model/fight_event_model.dart';

class FightEventCardList extends StatelessWidget {
  final IFightEventModel fe;

  const FightEventCardList({super.key, required this.fe});

  @override
  Widget build(BuildContext context) {
    if (fe.mainCardDateTimeInfo == null || fe.mainCardCnt == null) {
      return Column(
        children:
            fe.fighterFightEvents
                .mapIndexed((index, ffe) => _buildCard(index: index, ffe: ffe))
                .toList(),
      );
    }
    return Column(
      children: List.generate(fe.fighterFightEvents.length, (index) {
        final ffe = fe.fighterFightEvents[index];
        final header = FightEventCardSequence.buildSequenceHeader(
          context,
          fe: fe,
          index: index,
        );
        final cardSeqInfo = FightEventCardSequence.resolveCardSequenceInfo(
          fe,
          index,
        );
        return Column(
          children: [
            if (header != null) header,
            _buildCard(
              index: index,
              ffe: ffe,
              cardStartDateTimeInfo: cardSeqInfo.$1,
              whichCard: cardSeqInfo.$2,
            ),
          ],
        );
      }),
    );
  }

  Widget _buildCard({
    required int index,
    required IFighterFightEvent ffe,
    CardDateTimeInfoModel? cardStartDateTimeInfo,
    String? whichCard,
  }) {
    return FighterFightEventCard(
      ffe: ffe as FighterFightEventModel,
      cardStartDateTimeInfo: cardStartDateTimeInfo,
      whichCard: whichCard,
    );
  }
}
