import 'package:json_annotation/json_annotation.dart';
import 'package:mma_flutter/alert/model/update_alert_request.dart';
import 'package:mma_flutter/alert/model/update_preference_request.dart';

part 'user_preferences.g.dart';

@JsonSerializable()
class UserPreferences {
  final bool fighterAlertEnabled;
  final bool eventAlertEnabled;
  final bool weeklyEventAlertEnabled;

  UserPreferences({
    required this.fighterAlertEnabled,
    required this.eventAlertEnabled,
    required this.weeklyEventAlertEnabled,
  });

  factory UserPreferences.fromJson(Map<String, dynamic> json) =>
      _$UserPreferencesFromJson(json);

  UserPreferences copyWithUpdateRequest({
    required UpdatePreferenceRequest request,
  }) {
    return UserPreferences(
      fighterAlertEnabled:
          request.alertTarget == AlertTarget.fighter
              ? !fighterAlertEnabled
              : fighterAlertEnabled,
      eventAlertEnabled:
          request.alertTarget == AlertTarget.upcomingEvent
              ? !eventAlertEnabled
              : eventAlertEnabled,
      weeklyEventAlertEnabled:
          request.isWeeklyEvent
              ? !weeklyEventAlertEnabled
              : weeklyEventAlertEnabled,
    );
  }
}
