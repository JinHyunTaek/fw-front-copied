/// 예측(prediction) 점수 정책. 서버 정책과 동일해야 함.
///
/// 정책 변경 시 백엔드 PredictionRewardPolicy와 함께 갱신할 것.
class PredictionRewardPolicy {
  /// 예측 1건당 고정 참가 포인트 (취소 시 환불)
  static const int entryFee = 300;

  static const int winnerHit = 300;
  static const int drawHit = 3000;
  static const int winMethodKoTkoSubHit = 300;
  static const int winMethodDecHit = 200;
  static const int finishRoundHit = 300;
  static const int fotnHit = 300;
  static const int potnHit = 300;

  /// 4-옵션(승자 + 승리 방식 + 피니시 라운드 + (FotN 또는 PotN)) 풀 적중 보너스
  static const int fullOptionBonus = 200;

  /// 조합 예측(N ≥ 2) 전부 적중 시, 카드별 적중 옵션 1개당 가산 보너스
  static const int comboBonusPerOption = 100;
}
