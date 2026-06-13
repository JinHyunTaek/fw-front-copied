import 'package:json_annotation/json_annotation.dart';

part 'password_reset_request.g.dart';

@JsonSerializable()
class PasswordResetRequest {
  final String email;
  final String password;
  final String resetToken;

  PasswordResetRequest({
    required this.email,
    required this.password,
    required this.resetToken,
  });

  Map<String, dynamic> toJson() => _$PasswordResetRequestToJson(this);

}
