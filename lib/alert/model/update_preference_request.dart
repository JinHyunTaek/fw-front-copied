import 'package:json_annotation/json_annotation.dart';
import 'package:mma_flutter/alert/model/update_alert_request.dart';

part 'update_preference_request.g.dart';

@JsonSerializable()
class UpdatePreferenceRequest {
  final bool on;
  final AlertTarget? alertTarget;
  final bool isWeeklyEvent;

  UpdatePreferenceRequest({
    required this.on,
    required this.alertTarget,
    this.isWeeklyEvent=false,
  });

  Map<String, dynamic> toJson() => _$UpdatePreferenceRequestToJson(this);
}
