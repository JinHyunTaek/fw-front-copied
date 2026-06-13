import 'package:json_annotation/json_annotation.dart';

enum WithdrawalCategory{
  @JsonValue("SCREEN_COMPLEXITY")
  screenComplexity("화면이 너무 복잡해요"),
  @JsonValue("DISRESPECTFUL_USER")
  disrespectfulUser("비매너 사용자를 만났어요"),
  @JsonValue("NEW_ACCOUNT")
  newAccount("새 계정을 만들고 싶어요"),
  @JsonValue("NO_LONGER_WATCHING_UFC")
  noLongerWatchingUFC("더 이상 UFC를 시청하지 않아요"),
  @JsonValue("POINT_GAINING_DIFFICULTY")
  pointGainingDifficulty("포인트를 획득하기 너무 어려워요"),
  @JsonValue("OTHER")
  other("기타");

  final String korean;

  const WithdrawalCategory(this.korean);

}