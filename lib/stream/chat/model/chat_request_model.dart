import 'package:json_annotation/json_annotation.dart';

part 'chat_request_model.g.dart';

@JsonSerializable()
class ChatRequestModel {
  final String message;

  ChatRequestModel({required this.message});

  Map<String,dynamic> toJson() => _$ChatRequestModelToJson(this);

}
