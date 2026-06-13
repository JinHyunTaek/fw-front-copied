import 'package:json_annotation/json_annotation.dart';

part 'join_request_model.g.dart';

@JsonSerializable()
class ChatJoinRequestModel {
  final int userId;
  final String nickname;
  final int earnedBetSucceedPoint;

  ChatJoinRequestModel({required this.userId, required this.nickname, required this.earnedBetSucceedPoint});

  Map<String, dynamic> toJson() => _$ChatJoinRequestModelToJson(this);

}
