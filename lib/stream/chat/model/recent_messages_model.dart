import 'package:json_annotation/json_annotation.dart';
import 'package:mma_flutter/stream/chat/model/chat_response_model.dart';

part 'recent_messages_model.g.dart';

@JsonSerializable()
class RecentMessagesModel {
  final List<ChatResponseModel> recentMessages;

  RecentMessagesModel({required this.recentMessages});

  factory RecentMessagesModel.fromJson(Map<String, dynamic> json)
  => _$RecentMessagesModelFromJson(json);
}
