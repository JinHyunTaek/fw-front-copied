import 'package:json_annotation/json_annotation.dart';
import 'package:mma_flutter/common/enum/country.dart';
import 'package:mma_flutter/common/model/model_with_id.dart';
import 'package:mma_flutter/fight_event/model/fight_event_model.dart';

part 'fighter_model.g.dart';

@JsonSerializable()
class FighterModel implements ModelWithId{
  @override
  final int id;
  final String name;
  final String? koreanName;
  final int? ranking;
  final String? headshotUrl;
  final FightRecordModel record;
  final Country? nationality;

  FighterModel({
    required this.id,
    required this.name,
    required this.koreanName,
    required this.ranking,
    required this.headshotUrl,
    required this.record,
    required this.nationality,
  });

  factory FighterModel.fromJson(Map<String, dynamic> json){
    return _$FighterModelFromJson(json);
  }

}
