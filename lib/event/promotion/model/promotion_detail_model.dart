import 'package:json_annotation/json_annotation.dart';
import 'package:mma_flutter/event/promotion/model/gifticon_category.dart';

part 'promotion_detail_model.g.dart';

@JsonSerializable(createToJson: false)
class PromotionDetailModel{
  final PromotionDetailDto promotion;
  final int myEntryCount;
  final int entryCap;

  const PromotionDetailModel({
    required this.promotion,
    required this.myEntryCount,
    required this.entryCap,
  });

  factory PromotionDetailModel.fromJson(Map<String, dynamic> json)
  => _$PromotionDetailModelFromJson(json);

}

@JsonSerializable(createToJson: false)
class PromotionDetailDto {
  final String title;
  final String benefit;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime announceDate;
  final int maxWinnerCount;
  final String? notice;
  final DateTime? drawnAt; // null이면 미추첨(진행/발표대기)
  final List<PromotionWinnerGifticonModel>? winnerGifticons;
  final List<GifticonModel> gifticons;

  const PromotionDetailDto({
    required this.title,
    required this.benefit,
    required this.startDate,
    required this.endDate,
    required this.announceDate,
    required this.maxWinnerCount,
    required this.notice,
    required this.drawnAt,
    required this.winnerGifticons,
    required this.gifticons,
  });

  bool get isDrawn => drawnAt != null;

  factory PromotionDetailDto.fromJson(Map<String, dynamic> json) =>
      _$PromotionDetailDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class PromotionWinnerGifticonModel{
  final String winnerNickname;
  final String gifticonName;
  final GifticonCategory category;

  const PromotionWinnerGifticonModel({
    required this.winnerNickname,
    required this.gifticonName,
    required this.category,
  });

  factory PromotionWinnerGifticonModel.fromJson(Map<String, dynamic> json)
  => _$PromotionWinnerGifticonModelFromJson(json);
}

@JsonSerializable(createToJson: false)
class GifticonModel {
  final String name;
  final GifticonCategory category;
  final int priority; // 낮을수록 상위(displayOrder)

  const GifticonModel({
    required this.name,
    required this.category,
    required this.priority,
  });

  factory GifticonModel.fromJson(Map<String, dynamic> json) =>
      _$GifticonModelFromJson(json);
}
