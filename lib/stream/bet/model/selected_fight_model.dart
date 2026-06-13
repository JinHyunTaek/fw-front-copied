import 'package:mma_flutter/stream/bet/model/bet_request_model.dart';
import 'package:mma_flutter/stream/bet/provider/bet_card_provider.dart';

/** api request를 위한 model이 아닌, StreamFightEventModel의 기본 데이터가
 *  BetRequestModel 까지 전달될 수 있도록 하는 징검다리 역할의 model
 */
class SelectedFightModel{
  final bool isFiveRound;
  final bool isTitle;
  final int fighterFightEventId;
  final String fightWeight;
  // streamFightEventModel의 winnerName (내가 예측한 winner 아님)
  final FighterSelection redFighter;
  final FighterSelection blueFighter;

  SelectedFightModel({
    required this.isFiveRound,
    required this.isTitle,
    required this.fightWeight,
    required this.fighterFightEventId,
    required this.redFighter,
    required this.blueFighter,
  });

}