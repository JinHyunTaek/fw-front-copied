import 'package:json_annotation/json_annotation.dart';

part 'chat_response_model.g.dart';

@JsonSerializable()
class ChatResponseModel {
  final String message;
  final String nickname;
  final int userId;
  final String messageId;
  final int earnedBetSucceedPoint;
  final String? profileImgUrl;
  final DateTime createdAt;

  ChatResponseModel({
    required this.message,
    required this.userId,
    required this.nickname,
    required this.earnedBetSucceedPoint,
    required this.profileImgUrl,
    required this.messageId,
    required this.createdAt,
  });

  factory ChatResponseModel.fromJson(Map<String, dynamic> json)
  => _$ChatResponseModelFromJson(json);

}
