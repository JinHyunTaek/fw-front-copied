import 'dart:developer';

import 'package:json_annotation/json_annotation.dart';
import 'package:mma_flutter/fight_event/model/abst/i_fight_event_model.dart';
import 'package:mma_flutter/fight_event/model/abst/i_fighter_fight_event_model.dart';
import 'package:mma_flutter/fighter/model/fighter_model.dart';

import 'card_date_time_info_model.dart';

part 'fight_event_model.g.dart';

@JsonSerializable()
class FightEventModel extends IFightEventModel<FighterFightEventModel> {
  final bool upcoming;
  final bool alert;

  FightEventModel({
    required this.upcoming,
    required this.alert,
    required super.id,
    required super.name,
    required super.displayDate,
    required super.mainCardDateTimeInfo,
    required super.prelimCardDateTimeInfo,
    required super.earlyCardDateTimeInfo,
    required super.mainCardCnt,
    required super.prelimCardCnt,
    required super.earlyCardCnt,
    required super.location,
    required super.fighterFightEvents,
  });

  factory FightEventModel.fromJson(Map<String, dynamic> json) =>
      _$FightEventModelFromJson(json);
}

@JsonSerializable()
class FighterFightEventModel extends IFighterFightEvent<FighterModel> {
  final int eventId;
  // early > prelim > main > eventDate
  final DateTime displayDate;
  final bool fotN;
  final bool potN;

  FighterFightEventModel({
    required this.eventId,
    required this.displayDate,
    required this.fotN,
    required this.potN,
    required super.fightWeight,
    required super.eventName,
    required super.winner,
    required super.loser,
    required super.result,
    required super.id,
    required super.title,
  });

  factory FighterFightEventModel.fromJson(Map<String, dynamic> json) {
    try {
      return _$FighterFightEventModelFromJson(json);
    } catch (e, stackTrace) {
      log(
        'FighterFightEventModel json 변환 예외 발생',
        error: e,
        stackTrace: stackTrace,
      );
      return _$FighterFightEventModelFromJson(json);
    }
  }
}

@JsonSerializable()
class FightResultModel {
  final WinMethod? winMethod;
  final String? description;
  final int round;
  @JsonKey(fromJson: parseDuration)
  final Duration? fightDuration;
  final bool draw;
  final bool nc;
 
  FightResultModel({
    required this.winMethod,
    required this.description,
    required this.round,
    required this.fightDuration,
    required this.draw,
    required this.nc,
  });

  factory FightResultModel.fromJson(Map<String, dynamic> json) =>
      _$FightResultModelFromJson(json);
}

Duration? parseDuration(int? value) {
  if (value == null) return null;
  return Duration(seconds: value);
}

enum WinMethod {
  @JsonValue("SUB")
  sub,
  @JsonValue("KO_TKO")
  koTko,
  @JsonValue("U_DEC")
  uDec,
  @JsonValue("M_DEC")
  mDec,
  @JsonValue("S_DEC")
  sDec,
  @JsonValue("DQ")
  dq,
  @JsonValue("DEC")
  dec,
}

@JsonSerializable()
class FightRecordModel {
  final int win;
  final int loss;
  final int draw;

  FightRecordModel({required this.win, required this.loss, required this.draw});

  factory FightRecordModel.fromJson(Map<String, dynamic> json) =>
      _$FightRecordModelFromJson(json);
}
