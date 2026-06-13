import 'package:json_annotation/json_annotation.dart';

part 'update_alert_request.g.dart';

@JsonSerializable()
class UpdateAlertRequest {
  final int targetId;
  final bool on;
  final AlertTarget alertTarget;

  UpdateAlertRequest({
    required this.targetId,
    required this.on,
    required this.alertTarget,
  });

  Map<String, dynamic> toJson() => _$UpdateAlertRequestToJson(this);
}

enum AlertTarget {
  @JsonValue("FIGHTER")
  fighter,
  @JsonValue("UPCOMING_EVENT")
  upcomingEvent,
}
