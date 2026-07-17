import 'dart:developer';

import 'package:json_annotation/json_annotation.dart';
import 'package:mma_flutter/fight_event/model/fight_event_model.dart';
import 'package:mma_flutter/fighter/model/fighter_model.dart';

import '../../common/enum/country.dart';

part 'fighter_fight_event_detail_model.g.dart';

@JsonSerializable()
class FighterFightEventDetailModel {
  final FighterFightEventFighterModel winner;
  final FighterFightEventFighterModel loser;
  final String fightWeight;

  FighterFightEventDetailModel({
    required this.winner,
    required this.loser,
    required this.fightWeight,
  });

  factory FighterFightEventDetailModel.fromJson(Map<String, dynamic> json)
  => _$FighterFightEventDetailModelFromJson(json);
}

@JsonSerializable()
class FighterFightEventFighterModel extends FighterModel {
  final int? reach;
  final DateTime? birthday;
  final int height;
  final double? weight;
  final String? bodyUrl;

  FighterFightEventFighterModel({
    required super.id,
    required super.name,
    required super.koreanName,
    required super.record,
    required super.ranking,
    required super.nationality,
    required super.headshotUrl,
    required this.weight,
    required this.height,
    required this.birthday,
    required this.reach,
    required this.bodyUrl,
  });

  factory FighterFightEventFighterModel.fromJson(Map<String, dynamic> json) {
    log(json.toString());
    return _$FighterFightEventFighterModelFromJson(json);
  }
}

