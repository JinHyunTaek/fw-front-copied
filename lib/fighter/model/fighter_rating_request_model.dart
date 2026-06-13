import 'package:json_annotation/json_annotation.dart';

part 'fighter_rating_request_model.g.dart';

@JsonSerializable()
class FighterRatingRequestModel {
  final int fighterId;
  final int rating;

  const FighterRatingRequestModel({
    required this.fighterId,
    required this.rating,
  });

  Map<String, dynamic> toJson() => _$FighterRatingRequestModelToJson(this);
}
