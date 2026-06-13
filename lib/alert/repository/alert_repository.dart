import 'package:dio/dio.dart' hide Headers;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mma_flutter/alert/model/update_alert_request.dart';
import 'package:mma_flutter/alert/model/update_preference_request.dart';
import 'package:mma_flutter/alert/model/user_preferences.dart';
import 'package:mma_flutter/common/const/data.dart';
import 'package:mma_flutter/common/provider/dio/dio_provider.dart';
import 'package:retrofit/error_logger.dart';
import 'package:retrofit/http.dart';

part 'alert_repository.g.dart';

final alertRepositoryProvider = Provider<AlertRepository>((ref) {
  final dio = ref.read(dioProvider);
  return AlertRepository(dio, baseUrl: '$baseUrl/alert');
});

@RestApi()
abstract class AlertRepository {
  factory AlertRepository(Dio dio, {String baseUrl}) = _AlertRepository;

  @POST('')
  @Headers({'accessToken': 'true'})
  Future<void> updateSingleAlert({@Body() required UpdateAlertRequest request});

  @GET('/preferences')
  @Headers({'accessToken': 'true'})
  Future<UserPreferences> preferences();

  @POST('/preferences')
  @Headers({'accessToken': 'true'})
  Future<void> updateAllPreferences({@Query("isOn") required bool isOn});

  @POST('/preference')
  @Headers({'accessToken': 'true'})
  Future<void> updateSinglePreference({
    @Body() required UpdatePreferenceRequest request,
  });
}
