import 'package:flutter/cupertino.dart';
import 'package:mma_flutter/fight_event/component/card/fight_event_card_sequence.dart';
import 'package:mma_flutter/fight_event/component/card/stream_fighter_fight_event_card.dart';
import 'package:mma_flutter/fight_event/model/abst/i_fighter_fight_event_model.dart';
import 'package:mma_flutter/fight_event/model/card_date_time_info_model.dart';
import 'package:mma_flutter/stream/model/stream_fight_event_model.dart';

class StreamFightEventList extends StatelessWidget {
  final StreamFightEventModel fe;
  final List<bool> checkBoxValues;
  final void Function(bool value, int index) checkBoxOnChanged;

  const StreamFightEventList({
    required this.fe,
    required this.checkBoxValues,
    required this.checkBoxOnChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {

    return Column(
      children:
      List.generate(fe.fighterFightEvents.length, (index) {
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

        if(ffe.status != StreamFighterFightEventStatus.canceled) {
          return Column(
            children: [
              if (header != null) header,
              _buildCard(
                index: index,
                ffe: ffe,
                mainCardInfo: fe.mainCardDateTimeInfo,
                cardStartDateTimeInfo: cardSeqInfo.$1,
                whichCard: cardSeqInfo.$2,
              )
            ],
          );
        }
        return SizedBox.shrink();
      }),
    );
  }

  Widget _buildCard({
    required int index,
    required IFighterFightEvent ffe,
    required CardDateTimeInfoModel? mainCardInfo,
    CardDateTimeInfoModel? cardStartDateTimeInfo,
    String? whichCard,
  }) {
    return StreamFighterFightEventCard(
      ffe: ffe as StreamFighterFightEventModel,
      checkboxValue: checkBoxValues[index],
      checkboxOnChanged: (value) {
        checkBoxOnChanged.call(value!, index);
      },
      mainCardInfo: mainCardInfo?.date,
      cardInfo: cardStartDateTimeInfo,
      whichCard: whichCard,
    );
  }
}
