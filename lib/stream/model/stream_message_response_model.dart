import 'package:json_annotation/json_annotation.dart';
import 'package:mma_flutter/stream/chat/model/recent_messages_model.dart';
import 'package:mma_flutter/stream/chat/model/chat_response_model.dart';
import 'package:mma_flutter/stream/model/stream_fight_event_model.dart';

part 'stream_message_response_model.g.dart';

@JsonSerializable()
class StreamMessageResponseModel {
  final ResponseMessageType responseMessageType;
  final ChatResponseModel? chatMessageResponse;
  final StreamFightEventModel? streamFightEvent;
  final RecentMessagesModel? recentMessages;
  final int? connectionCount;

  StreamMessageResponseModel({
    required this.responseMessageType,
    this.chatMessageResponse,
    this.streamFightEvent,
    this.recentMessages,
    this.connectionCount,
  });

  factory StreamMessageResponseModel.fromJson(Map<String, dynamic> json) =>
      _$StreamMessageResponseModelFromJson(json);
}

@JsonEnum(alwaysCreate: true)
enum ResponseMessageType {
  @JsonValue("TALK")
  talk,
  @JsonValue("CONNECTION_COUNT")
  connectionCount,
  @JsonValue("FIGHT")
  fight,
  @JsonValue("RECENT_MESSAGES")
  recentMessages
}
