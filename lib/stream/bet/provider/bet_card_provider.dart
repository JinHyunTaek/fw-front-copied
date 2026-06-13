import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mma_flutter/stream/bet/model/bet_response_model.dart';
import 'package:mma_flutter/stream/bet/model/selected_fight_model.dart';

final betCardProvider = StateProvider<List<BetState>>((ref) => []);

class BetState {
  final SelectedFightModel fight;
  final SelectedBetCardModel card;

  const BetState({required this.fight, required this.card});

  BetState copyWithCard(SelectedBetCardModel card) =>
      BetState(fight: fight, card: card);
}

// 초기에는 ffeId 정보밖에 없음
// (streamFightEventScreen에서 fight card checkBox 선택 및 예측하기 클릭 시)
class SelectedBetCardModel {
  final int ffeId;
  final FighterSelection? myWinner;
  final FighterSelection? myLoser;
  final bool drawSelected;
  final bool? leftNameSelected;
  final int? winMethodIndex;
  final int? finishRoundIndex;
  final bool isFotNSelected;
  final bool isPotNSelected;

  const SelectedBetCardModel({
    required this.ffeId,
    this.myWinner,
    this.myLoser,
    this.drawSelected = false,
    this.isFotNSelected = false,
    this.isPotNSelected = false,
    this.leftNameSelected,
    this.winMethodIndex,
    this.finishRoundIndex,
  });

  SelectedBetCardModel copyWith({
    FighterSelection? newMyWinner,
    FighterSelection? newMyLoser,
    bool? newDrawSelected,
    int? newWinMethodIndex,
    bool? newLeftNameSelected,
    int? newFinishRoundIndex,
    bool? newIsFotN,
    bool? newIsPotN,
  }) {
    return SelectedBetCardModel(
      ffeId: ffeId,
      myWinner: newMyWinner ?? myWinner,
      myLoser: newMyLoser ?? myLoser,
      drawSelected: newDrawSelected ?? drawSelected,
      winMethodIndex: newWinMethodIndex ?? winMethodIndex,
      finishRoundIndex: newFinishRoundIndex ?? finishRoundIndex,
      leftNameSelected: newLeftNameSelected ?? leftNameSelected,
      isFotNSelected: newIsFotN ?? isFotNSelected,
      isPotNSelected: newIsPotN ?? isPotNSelected,
    );
  }

  static SelectedBetCardModel fromSingleBetCardResponseToCalculateProfit({
    required SingleBetCardResponseModel bet,
  }) {
    final prediction = bet.betPrediction;
    // doesn't matter even if it doesn't five selected fighter info(name, id)
    return SelectedBetCardModel(
      ffeId: 0,
      drawSelected: prediction.draw,
      winMethodIndex: prediction.winMethod?.index,
      finishRoundIndex:
          prediction.finishRound != null ? prediction.finishRound! - 1 : null,
      isFotNSelected: prediction.isFotN,
      isPotNSelected: prediction.isPotN,
    );
  }
}

class FighterSelection {
  final int id;
  final String name;

  const FighterSelection({required this.id, required this.name});
}
