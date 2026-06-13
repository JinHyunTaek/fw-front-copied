import 'package:json_annotation/json_annotation.dart';

part 'email_verification_code_request.g.dart';

@JsonSerializable()
class EmailVerificationCodeRequest {
  final String email;
  final bool isJoin;

  EmailVerificationCodeRequest({required this.email, required this.isJoin});

  Map<String, dynamic> toJson() => _$EmailVerificationCodeRequestToJson(this);

}
