import 'package:json_annotation/json_annotation.dart';
import 'package:mma_flutter/common/enum/country.dart';
import 'package:mma_flutter/common/utils/fight_utils.dart';
import 'package:mma_flutter/fight_event/model/fight_event_model.dart';
import 'package:mma_flutter/ranking/model/rankers_model.dart';

part 'name_game_response_model.g.dart';

RankingCategory? _rankingCategoryFromJson(String? value) {
  if (value == null) return null;
  for (final e in RankingCategory.values) {
    if (e.description == value || e.requestValue == value) return e;
  }
  return null;
}

@JsonSerializable()
class NameGameResponseModel {
  final NameGameCategory nameGameCategory;

  final String? nickname;

  final int? ranking;
  @JsonKey(fromJson: _rankingCategoryFromJson)
  final RankingCategory? rankingCategory;

  final Country? nationality;

  List<String>? opponents;

  final FightRecordModel? fightRecord;

  final String answer;
  final List<String> wrongSelections;

  NameGameResponseModel({
    required this.nameGameCategory,
    required this.answer,
    required this.nickname,
    required this.ranking,
    required this.rankingCategory,
    required this.nationality,
    required this.opponents,
    required this.fightRecord,
    required this.wrongSelections,
  });

  factory NameGameResponseModel.fromJson(Map<String, dynamic> json) =>
      _$NameGameResponseModelFromJson(json);
}

enum NameGameCategory {
  @JsonValue('COUNTRY')
  country,
  @JsonValue('OPPONENT')
  opponent,
  @JsonValue('NICKNAME')
  nickname,
  @JsonValue('RANKING')
  ranking,
  @JsonValue('RECORD')
  record,
}

extension GameCategoryExtension on NameGameCategory {
  String get label {
    switch (this) {
      case NameGameCategory.country:
        return '국적';
      case NameGameCategory.opponent:
        return '상대 선수';
      case NameGameCategory.record:
        return '전적';
      case NameGameCategory.ranking:
        return '랭킹';
      case NameGameCategory.nickname:
        return '닉네임';
    }
  }

  String textQuestion({required NameGameResponseModel model}) {
    switch (this) {
      case NameGameCategory.country:
        return '${model.nationality!.label} 출신 파이터는?';
      case NameGameCategory.opponent:
        return '${model.opponents!.map((e) => CustomFightUtils.extractLastName(e)).join(', ')}\n 상대로 승리를 거둔 파이터는?';
      case NameGameCategory.nickname:
        return '$label이\n \'${model.nickname!}\'인 파이터는?';
      case NameGameCategory.ranking:
        if (model.ranking! != 0) {
          return '${model.rankingCategory!.description} $label\n ${model.ranking!}위인 파이터는?';
        } else {
          return '${model.rankingCategory!.description}\n챔피언은?';
        }
      case NameGameCategory.record:
        return '$label이\n ${CustomFightUtils.renderRecord(model.fightRecord!)}인 파이터는?';
    }
  }
}
