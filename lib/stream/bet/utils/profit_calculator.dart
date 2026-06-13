import 'package:mma_flutter/stream/bet/model/bet_request_model.dart';
import 'package:mma_flutter/stream/bet/provider/bet_card_provider.dart';
import 'package:mma_flutter/stream/bet/utils/prediction_reward_policy.dart';

/// 예측 적중 시 획득 점수(EXP) 미리보기 계산기.
///
/// 서버 정산 로직과 동일한 가산 방식. 정책 상수는
/// [PredictionRewardPolicy] 참조. 모든 카드가 적중했다는 가정 하에
/// 사용자가 선택한 옵션에 대한 점수를 합산한다.
class ProfitCalculator {
  static int calculateTotalProfit({
    required List<SelectedBetCardModel> betCards,
  }) {
    int total = 0;
    for (final card in betCards) {
      total += _scoreForCard(card);
    }

    if (betCards.length >= 2) {
      int totalOptions = 0;
      for (final card in betCards) {
        totalOptions += _optionCount(card);
      }
      total += totalOptions * PredictionRewardPolicy.comboBonusPerOption;
    }

    return total;
  }

  static int _optionCount(SelectedBetCardModel card) {
    int count = 1;
    if (card.drawSelected) {
      if (card.isFotNSelected) count++;
      if (card.isPotNSelected) count++;
      return count;
    }

    final winMethod = card.winMethodIndex != null
        ? WinMethodForBet.values[card.winMethodIndex!]
        : null;

    if (winMethod != null) count++;
    if (card.finishRoundIndex != null && winMethod != WinMethodForBet.dec) count++;
    if (card.isFotNSelected) count++;
    if (card.isPotNSelected) count++;
    return count;
  }

  static int _scoreForCard(SelectedBetCardModel card) {
    if (card.drawSelected) {
      int score = PredictionRewardPolicy.drawHit;
      if (card.isFotNSelected) score += PredictionRewardPolicy.fotnHit;
      if (card.isPotNSelected) score += PredictionRewardPolicy.potnHit;
      return score;
    }

    int score = PredictionRewardPolicy.winnerHit;

    final winMethod = card.winMethodIndex != null
        ? WinMethodForBet.values[card.winMethodIndex!]
        : null;
    if (winMethod != null) {
      score += winMethod == WinMethodForBet.dec
          ? PredictionRewardPolicy.winMethodDecHit
          : PredictionRewardPolicy.winMethodKoTkoSubHit;
    }

    final hasRound = card.finishRoundIndex != null && winMethod != WinMethodForBet.dec;
    if (hasRound) {
      score += PredictionRewardPolicy.finishRoundHit;
    }

    if (card.isFotNSelected) score += PredictionRewardPolicy.fotnHit;
    if (card.isPotNSelected) score += PredictionRewardPolicy.potnHit;

    final hasFullFourOptions = winMethod != null &&
        hasRound &&
        (card.isFotNSelected || card.isPotNSelected);
    if (hasFullFourOptions) {
      score += PredictionRewardPolicy.fullOptionBonus;
    }

    return score;
  }
}
