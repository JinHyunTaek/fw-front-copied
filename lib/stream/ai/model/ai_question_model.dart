import 'package:json_annotation/json_annotation.dart';

part 'ai_question_model.g.dart';

/// 백엔드 `/stream/ai/questions` 가 내려주는 고정 질문 메뉴 항목.
///
/// 질문 텍스트·라벨·카테고리는 서버가 단일 출처로 관리하고, 클라이언트는
/// [value](enum 이름)만 그대로 되돌려 보낸다(화이트리스트).
/// [category] 가 곧 요청에 필요한 파라미터를 결정한다:
/// event=없음, fight=fightId, fighter=fighterId.
@JsonSerializable(createToJson: false)
class AiQuestionModel {
  /// AiQuestion enum 이름. 답변 요청 시 question 파라미터로 그대로 전송한다.
  final String value;

  /// 사용자에게 노출할 라벨(칩 텍스트).
  final String label;

  final AiQuestionCategory category;

  AiQuestionModel({
    required this.value,
    required this.label,
    required this.category,
  });

  factory AiQuestionModel.fromJson(Map<String, dynamic> json) =>
      _$AiQuestionModelFromJson(json);
}

enum AiQuestionCategory {
  @JsonValue('EVENT')
  event,
  @JsonValue('FIGHT')
  fight,
  @JsonValue('FIGHTER')
  fighter,
}
