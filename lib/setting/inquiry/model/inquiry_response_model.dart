import 'package:json_annotation/json_annotation.dart';
import 'package:mma_flutter/common/model/model_with_id.dart';

part 'inquiry_response_model.g.dart';

@JsonSerializable()
class InquiryResponseModel implements ModelWithId {
  @override
  final int id;
  final InquiryCategory category;
  final DateTime? answeredDate;
  final DateTime createdDate;

  InquiryResponseModel({
    required this.id,
    required this.category,
    required this.answeredDate,
    required this.createdDate,
  });

  factory InquiryResponseModel.fromJson(Map<String, dynamic> json) =>
      _$InquiryResponseModelFromJson(json);
}

enum InquiryCategory {
  @JsonValue('ERROR')
  error(korean: '버그/오류'),
  @JsonValue('USAGE')
  usage(korean: '사용 방법'),
  @JsonValue('FEEDBACK')
  feedback(korean: '건의 사항'),
  @JsonValue('OTHER')
  other(korean: '기타');

  final String korean;

  const InquiryCategory({required this.korean});
}
