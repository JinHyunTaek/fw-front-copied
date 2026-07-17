import 'package:json_annotation/json_annotation.dart';
import 'package:mma_flutter/home/model/home_promotion_model.dart';
import 'package:mma_flutter/fight_event/model/card_date_time_info_model.dart';

part 'home_screen_model.g.dart';

@JsonSerializable()
class HomeScreenModel {
  final String eventName;
  final CardDateTimeInfoModel? mainCardDateTimeInfo;
  final String winnerName;
  final String loserName;
  final String? winnerKoreanName;
  final String? loserKoreanName;
  final String fightWeight;
  final bool title;
  final HomePromotionModel activePromotions;
  final String? winnerBodyUrl;
  final String? loserBodyUrl;

  HomeScreenModel({
    required this.eventName,
    required this.mainCardDateTimeInfo,
    required this.winnerName,
    required this.loserName,
    required this.winnerKoreanName,
    required this.loserKoreanName,
    required this.fightWeight,
    required this.title,
    required this.activePromotions,
    required this.winnerBodyUrl,
    required this.loserBodyUrl
  });

  factory HomeScreenModel.fromJson(Map<String, dynamic> json)
  => _$HomeScreenModelFromJson(json);
}
