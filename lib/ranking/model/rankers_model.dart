import 'package:json_annotation/json_annotation.dart';
import 'package:mma_flutter/common/enum/country.dart';
import 'package:mma_flutter/fight_event/model/fight_event_model.dart';
import 'package:mma_flutter/fighter/model/fighter_model.dart';

part 'rankers_model.g.dart';

@JsonSerializable()
class RankersModel {
  final List<RankerModel> rankers;

  const RankersModel({required this.rankers});

  factory RankersModel.fromJson(Map<String, dynamic> json) =>
      _$RankersModelFromJson(json);
}

@JsonSerializable()
class RankerModel {
  final int id;
  final int ranking;
  final String name;
  final String? koreanName;
  final RankingCategory category;

  const RankerModel({
    required this.id,
    required this.ranking,
    required this.name,
    required this.koreanName,
    required this.category,
  });

  factory RankerModel.fromJson(Map<String, dynamic> json) =>
      _$RankerModelFromJson(json);
}

enum RankingCategory {
  @JsonValue("MENS_POUND_FOR_POUND_TOP_RANK")
  mensPoundForPoundTopRank("남성 P4P", "MENS_POUND_FOR_POUND_TOP_RANK"),
  @JsonValue("플라이급")
  flyweight("플라이급", "FLYWEIGHT"),
  @JsonValue("밴텀급")
  bantamweight("밴텀급", "BANTAMWEIGHT"),
  @JsonValue("페더급")
  featherweight("페더급", "FEATHERWEIGHT"),
  @JsonValue("라이트급")
  lightweight("라이트급", "LIGHTWEIGHT"),
  @JsonValue("웰터급")
  welterweight("웰터급", "WELTERWEIGHT"),
  @JsonValue("미들급")
  middleweight("미들급", "MIDDLEWEIGHT"),
  @JsonValue("라이트_헤비급")
  lightHeavyweight("라이트_헤비급", "LIGHT_HEAVYWEIGHT"),
  @JsonValue("헤비급")
  heavyweight("헤비급", "HEAVYWEIGHT"),
  @JsonValue("WOMENS_POUND_FOR_POUND_TOP_RANK")
  womensPoundForPoundTopRank("여성 P4P", "WOMENS_POUND_FOR_POUND_TOP_RANK"),
  @JsonValue("여성_스트로급")
  womensStrawweight("여성_스트로급", "WOMENS_STRAWWEIGHT"),
  @JsonValue("여성_플라이급")
  womensFlyweight("여성_플라이급", "WOMENS_FLYWEIGHT"),
  @JsonValue("여성_밴텀급")
  womensBantamweight("여성_밴텀급", "WOMENS_BANTAMWEIGHT");

  final String description;
  final String requestValue;

  const RankingCategory(this.description, this.requestValue);
}
