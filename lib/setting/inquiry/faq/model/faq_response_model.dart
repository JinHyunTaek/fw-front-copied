import 'package:json_annotation/json_annotation.dart';

part 'faq_response_model.g.dart';

@JsonSerializable()
class FaqResponseModel {
  final int id;
  final String question;
  final FAQCategory faqCategory;

  FaqResponseModel({
    required this.id,
    required this.question,
    required this.faqCategory,
  });

  factory FaqResponseModel.fromJson(Map<String, dynamic> json) =>
      _$FaqResponseModelFromJson(json);
}

enum FAQCategory {
  @JsonValue('MAIN')
  main('앱 설명', 'MAIN'),
  @JsonValue('PREDICTION')
  prediction('경기 예측/투표', 'PREDICTION'),
  @JsonValue('POINT')
  point('앱 포인트', 'POINT'),
  @JsonValue('ACCOUNT')
  account('계정', 'ACCOUNT'),
  @JsonValue('COMMUNITY')
  community('채팅/커뮤니티', 'COMMUNITY'),
  @JsonValue('FIGHTER_OR_FIGHT_EVENT')
  fighterOrFightEvent('경기 및 선수 정보', 'FIGHTER_OR_FIGHT_EVENT'),
  @JsonValue('ALERT')
  alert('알림', 'ALERT'),
  @JsonValue('BAN_OR_POLICY')
  banOrPolicy('앱 정책', 'BAN_OR_POLICY'),
  @JsonValue('GAME')
  game('게임', 'GAME'),
  @JsonValue('RANKING')
  ranking('랭킹', 'RANKING'),
  @JsonValue('PRIVACY')
  privacy('개인정보', 'PRIVACY'),
  @JsonValue('ETC')
  etc('그 외', 'ETC');

  final String korean;
  final String requestValue;

  const FAQCategory(this.korean, this.requestValue);
}
