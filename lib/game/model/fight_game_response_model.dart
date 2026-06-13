import 'package:json_annotation/json_annotation.dart';
import 'package:mma_flutter/common/utils/fight_utils.dart';
import 'package:mma_flutter/fight_event/model/fight_event_model.dart';

part 'fight_game_response_model.g.dart';

@JsonSerializable()
class FightGameResponseModel {
  final String eventName;
  final String winnerName;
  final String loserName;
  final SingleFightGameSelectionModel answer;
  final List<SingleFightGameSelectionModel> wrongSelections;

  const FightGameResponseModel({
    required this.eventName,
    required this.winnerName,
    required this.loserName,
    required this.answer,
    required this.wrongSelections,
  });

  factory FightGameResponseModel.fromJson(Map<String, dynamic> json) =>
      _$FightGameResponseModelFromJson(json);
}

extension FightGameExtension on FightGameResponseModel {
  String get textQuestion {
    String reducedEventName;
    String keyword = 'UFC Fight Night';
    if (eventName.contains(keyword)) {
      reducedEventName = eventName.replaceAll(keyword, 'UFN');
    } else {
      reducedEventName = eventName.split(':')[0];
    }
    return '$reducedEventName\n${CustomFightUtils.extractLastName(winnerName)} vs ${CustomFightUtils.extractLastName(loserName)} 경기에서\n승리한 선수 및 승리 방식은?';
  }
}

@JsonSerializable()
class SingleFightGameSelectionModel {
  final String name;
  final WinMethod winMethod;

  const SingleFightGameSelectionModel({
    required this.name,
    required this.winMethod,
  });

  factory SingleFightGameSelectionModel.fromJson(Map<String, dynamic> json) =>
      _$SingleFightGameSelectionModelFromJson(json);

  @override
  String toString() {
    return '$name - ${CustomFightUtils.winMethodMap[winMethod]}';
  }
}

extension SingleFightGameExtension on SingleFightGameSelectionModel {
  String get selection {
    return '$name-${CustomFightUtils.winMethodMap[winMethod]}';
  }
}
