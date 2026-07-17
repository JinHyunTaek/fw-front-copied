import 'package:json_annotation/json_annotation.dart';

part 'event_card_model.g.dart';

/**
 * @Builder
    public record EventCardDto(
    EventType type,
    Long refId,
    String title,
    String benefit,
    LocalDate startDate,
    LocalDate endDate
    ) {
 */

@JsonSerializable(createToJson: false)
class EventCardsModel {
  final List<EventCardModel> eventCards;

  const EventCardsModel({required this.eventCards});

  factory EventCardsModel.fromJson(Map<String, dynamic> json) =>
      _$EventCardsModelFromJson(json);
}

@JsonSerializable(createToJson: false)
class EventCardModel {
  final String type;
  final int refId;
  final String title;
  final String benefit;
  final DateTime? startDate;
  final DateTime? endDate;

  const EventCardModel({
    required this.type,
    required this.refId,
    required this.title,
    required this.benefit,
    required this.startDate,
    required this.endDate,
  });

  factory EventCardModel.fromJson(Map<String, dynamic> json) =>
      _$EventCardModelFromJson(json);
}
