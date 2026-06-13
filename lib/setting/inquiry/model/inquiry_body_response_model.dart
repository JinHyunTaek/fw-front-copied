import 'package:json_annotation/json_annotation.dart';

part 'inquiry_body_response_model.g.dart';

@JsonSerializable()
class InquiryBodyResponseModel {

  final String content;
  final String? answer;

  InquiryBodyResponseModel({
    required this.content,
    required this.answer
  });

  factory InquiryBodyResponseModel.fromJson(Map<String, dynamic> json)
  => _$InquiryBodyResponseModelFromJson(json);

}