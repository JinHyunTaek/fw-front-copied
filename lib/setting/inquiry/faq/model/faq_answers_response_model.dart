import 'package:json_annotation/json_annotation.dart';
import 'package:mma_flutter/setting/inquiry/faq/model/faq_response_model.dart';

part 'faq_answers_response_model.g.dart';

@JsonSerializable()
class FAQAnswersResponseModel {
  final List<FaqAnswerResponseModel> faqAnswers;

  const FAQAnswersResponseModel({required this.faqAnswers});

  factory FAQAnswersResponseModel.fromJson(Map<String, dynamic> json) =>
      _$FAQAnswersResponseModelFromJson(json);
}

@JsonSerializable()
class FaqAnswerResponseModel {
  final int id;
  final String answer;

  const FaqAnswerResponseModel({required this.id, required this.answer});

  factory FaqAnswerResponseModel.fromJson(Map<String, dynamic> json) =>
      _$FaqAnswerResponseModelFromJson(json);
}
