import 'package:json_annotation/json_annotation.dart';

part 'home_promotion_model.g.dart';

@JsonSerializable()
class HomePromotionModel {
  final List<HomePromotionDto> homePromotions;

  const HomePromotionModel({
    required this.homePromotions
});

  factory HomePromotionModel.fromJson(Map<String, dynamic> json)
  => _$HomePromotionModelFromJson(json);
}

@JsonSerializable()
class HomePromotionDto {
  final int id;
  final String title;
  final String benefit;
  final DateTime startDate;
  final DateTime endDate;
  final int maxWinnerCount;

  const HomePromotionDto({
    required this.id,
    required this.title,
    required this.benefit,
    required this.startDate,
    required this.endDate,
    required this.maxWinnerCount,
  });

  factory HomePromotionDto.fromJson(Map<String, dynamic> json)
  => _$HomePromotionDtoFromJson(json);

}
