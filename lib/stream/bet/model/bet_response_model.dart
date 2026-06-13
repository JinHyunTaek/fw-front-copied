import 'package:json_annotation/json_annotation.dart';
import 'package:mma_flutter/stream/bet/model/bet_request_model.dart';

part 'bet_response_model.g.dart';

@JsonSerializable()
class BetDeleteResponseModel {
  final int userPoint;
  final BetResponseModel betResponse;

  const BetDeleteResponseModel({
    required this.userPoint,
    required this.betResponse,
  });

  factory BetDeleteResponseModel.fromJson(Map<String, dynamic> json) =>
      _$BetDeleteResponseModelFromJson(json);
}

@JsonSerializable()
class BetResponseModel {
  final String eventName;

  /// bets 값이 없는 경우, 서버에서 null이 아닌 빈 리스트를 반환함.
  final List<SingleBetResponseModel> singleBets;

  BetResponseModel({required this.eventName, required this.singleBets});

  factory BetResponseModel.fromJson(Map<String, dynamic> json) =>
      _$BetResponseModelFromJson(json);
}

@JsonSerializable()
class SingleBetResponseModel {
  final List<SingleBetCardResponseModel> betCards;
  final int betId;
  final int seedPoint;
  final bool? succeed;
  final DateTime createdDateTime;
  final bool isRefunded;

  SingleBetResponseModel({
    required this.betCards,
    required this.betId,
    required this.seedPoint,
    required this.succeed,
    required this.createdDateTime,
    required this.isRefunded,
  });

  factory SingleBetResponseModel.fromJson(Map<String, dynamic> json) =>
      _$SingleBetResponseModelFromJson(json);
}

@JsonSerializable()
class SingleBetCardResponseModel {
  final String redName;
  final String blueName;
  final String? myWinnerName;
  final String? myLoserName;
  final BetPredictionModel betPrediction;
  final bool isFiveRound;

  SingleBetCardResponseModel({
    required this.redName,
    required this.blueName,
    required this.myWinnerName,
    required this.myLoserName,
    required this.betPrediction,
    required this.isFiveRound,
  });

  factory SingleBetCardResponseModel.fromJson(Map<String, dynamic> json) =>
      _$SingleBetCardResponseModelFromJson(json);
}
