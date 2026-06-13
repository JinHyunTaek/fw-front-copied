import 'package:json_annotation/json_annotation.dart';

part 'bet_request_model.g.dart';

@JsonSerializable(explicitToJson: true)
class BetRequestModel {
  final int eventId;

  final int seedPoint;

  final List<SingleBetCardRequestModel> singleBetCards;

  BetRequestModel({
    required this.eventId,
    required this.seedPoint,
    required this.singleBetCards,
  });

  Map<String, dynamic> toJson() => _$BetRequestModelToJson(this);
}

@JsonSerializable(explicitToJson: true)
class SingleBetCardRequestModel {
  final int fighterFightEventId;
  final BetPredictionModel betPrediction;

  SingleBetCardRequestModel({
    required this.fighterFightEventId,
    required this.betPrediction,
  });

  factory SingleBetCardRequestModel.fromJson(Map<String, dynamic> json)
  => _$SingleBetCardRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$SingleBetCardRequestModelToJson(this);
}

@JsonSerializable()
class BetPredictionModel {
  final int? myWinnerId;
  final int? myLoserId;
  final WinMethodForBet? winMethod;
  final bool draw;
  final int? finishRound;
  final bool isFotN;
  final bool isPotN;

  BetPredictionModel({
    required this.myWinnerId,
    required this.myLoserId,
    this.winMethod,
    this.finishRound,
    this.draw=false,
    this.isFotN=false,
    this.isPotN=false
  });

  Map<String, dynamic> toJson() => _$BetPredictionModelToJson(this);

  factory BetPredictionModel.fromJson(Map<String, dynamic> json) =>
      _$BetPredictionModelFromJson(json);
}

enum WinMethodForBet {
  @JsonValue("SUB")
  sub,
  @JsonValue("KO_TKO")
  koTko,
  @JsonValue("DEC")
  dec,
}

extension WinMethodExtension on WinMethodForBet {
  String get label {
    switch (this) {
      case WinMethodForBet.sub:
        return '서브미션';
      case WinMethodForBet.koTko:
        return 'KO/TKO';
      case WinMethodForBet.dec:
        return '판정';
    }
  }
}
