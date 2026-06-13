import 'package:json_annotation/json_annotation.dart';

part 'password_reset_token_model.g.dart';

@JsonSerializable()
class PasswordResetTokenModel{
  final String resetToken;

  PasswordResetTokenModel({required this.resetToken});

  factory PasswordResetTokenModel.fromJson(Map<String, dynamic> json)
  => _$PasswordResetTokenModelFromJson(json);
}