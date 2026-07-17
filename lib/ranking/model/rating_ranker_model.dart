import 'package:json_annotation/json_annotation.dart';
import 'package:mma_flutter/common/model/model_with_id.dart';

part 'rating_ranker_model.g.dart';

@JsonSerializable()
class RatingRankerModel implements ModelWithId{
  @override
  final int id;
  final double avgRating;
  final String name;
  final String? headshotUrl;

  const RatingRankerModel({
    required this.id,
    required this.avgRating,
    required this.name,
    required this.headshotUrl,
  });

  factory RatingRankerModel.fromJson(Map<String, dynamic> json)
  => _$RatingRankerModelFromJson(json);
}
