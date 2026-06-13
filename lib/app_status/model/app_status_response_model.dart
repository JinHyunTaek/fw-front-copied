import 'package:json_annotation/json_annotation.dart';
import 'package:mma_flutter/user/model/user_model.dart';

part 'app_status_response_model.g.dart';

@JsonSerializable()
class AppStatusResponseModel {
  final String? latestVersion;
  final String? minVersion;

  const AppStatusResponseModel({
    required this.latestVersion,
    required this.minVersion,
  });

  factory AppStatusResponseModel.fromJson(Map<String, dynamic> json)
  => _$AppStatusResponseModelFromJson(json);

}
