import 'package:json_annotation/json_annotation.dart';
import 'package:mma_flutter/fight_event/model/fight_event_model.dart';
import 'package:mma_flutter/fighter/model/fighter_model.dart';

import '../../common/enum/country.dart';

part 'fighter_detail_model.g.dart';

@JsonSerializable()
class FighterDetailModel extends FighterModel {
  final int height;
  final double? weight;
  final DateTime? birthday;
  final int? reach;
  final String? nation;
  final bool alert;
  final String? nickname;
  final double avgRating;
  final int myRating;
  final String? bodyUrl;
  final List<FighterFightEventModel>? fighterFightEvents;

  FighterDetailModel({
    required super.id,
    required super.name,
    required super.koreanName,
    required super.ranking,
    required super.record,
    required super.nationality,
    required super.headshotUrl,
    required this.nickname,
    required this.height,
    required this.weight,
    required this.birthday,
    required this.reach,
    required this.alert,
    required this.nation,
    required this.avgRating,
    required this.myRating,
    required this.bodyUrl,
    required this.fighterFightEvents,
  });

  factory FighterDetailModel.fromJson(Map<String, dynamic> json) =>
      _$FighterDetailModelFromJson(json);

}
