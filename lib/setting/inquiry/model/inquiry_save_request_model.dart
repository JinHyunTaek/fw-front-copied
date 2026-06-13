import 'package:json_annotation/json_annotation.dart';
import 'package:mma_flutter/setting/inquiry/model/inquiry_response_model.dart';

part 'inquiry_save_request_model.g.dart';

@JsonSerializable()
class InquirySaveRequestModel {
  final InquiryCategory category;
  final String content;

  InquirySaveRequestModel({required this.category, required this.content});

  Map<String, dynamic> toJson() => _$InquirySaveRequestModelToJson(this);

}

