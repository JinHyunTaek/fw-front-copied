import 'package:json_annotation/json_annotation.dart';
import 'package:mma_flutter/report/model/report_request_model.dart';

part 'user_model.g.dart';

abstract class UserModelBase {}

class UserLoginErrorErrorModel extends UserModelBase {
  final String message;

  UserLoginErrorErrorModel({required this.message});
}

class UserModelLoading extends UserModelBase {}

class UserModelJoining extends UserModelBase {}

// Skeleton UI
class UserModelLoadingToHome extends UserModelBase {}

class UserModelNicknameSetting extends UserModel {
  UserModelNicknameSetting({
    required super.point,
    required super.id,
    required super.email,
    required super.earnedBetSucceedPoint,
    required super.profileImgUrl,
    required super.reportedReason,
    required super.restrictEndAt,
  }) : super(nickname: null);
}

@JsonSerializable()
class UserModel extends UserModelBase {
  final int id;
  final String? nickname;
  final String email;
  final int point;
  final int earnedBetSucceedPoint;
  final String? profileImgUrl;
  final ReportCategory? reportedReason;
  final DateTime? restrictEndAt;

  UserModel({
    required this.point,
    required this.id,
    required this.nickname,
    required this.email,
    required this.earnedBetSucceedPoint,
    required this.profileImgUrl,
    required this.reportedReason,
    required this.restrictEndAt
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}
