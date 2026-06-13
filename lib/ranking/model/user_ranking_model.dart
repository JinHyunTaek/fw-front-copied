import 'package:json_annotation/json_annotation.dart';
import 'package:mma_flutter/common/model/model_with_id.dart';

part 'user_ranking_model.g.dart';

@JsonSerializable()
class UserRankingModel {
  final int myRanking;
  final List<RankedUserModel> rankedUsers;

  const UserRankingModel({required this.myRanking, required this.rankedUsers});

  factory UserRankingModel.fromJson(Map<String, dynamic> json) =>
      _$UserRankingModelFromJson(json);
}

@JsonSerializable()
class RankedUserModel {
  final int id;
  final String nickname;
  final int earnedBetSucceedPoint;
  final String? profileImgUrl;

  RankedUserModel({
    required this.id,
    required this.nickname,
    required this.earnedBetSucceedPoint,
    required this.profileImgUrl,
  });

  factory RankedUserModel.fromJson(Map<String, dynamic> json) =>
      _$RankedUserModelFromJson(json);
}
