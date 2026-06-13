import 'package:json_annotation/json_annotation.dart';
import 'package:mma_flutter/setting/account/const/data.dart';

part 'withdrawal_request.g.dart';

@JsonSerializable()
class WithdrawalRequest {
  final WithdrawalCategory category;
  final String description;

  WithdrawalRequest({
    required this.category,
    required this.description
  });

  Map<String, dynamic> toJson() => _$WithdrawalRequestToJson(this);

}