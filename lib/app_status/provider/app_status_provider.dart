import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mma_flutter/app_status/model/app_status_response_model.dart';
import 'package:mma_flutter/app_status/repository/app_status_repository.dart';

final appStatusProvider = FutureProvider<AppStatusResponseModel>((ref) async {
  return await ref.read(appStatusRepositoryProvider).getAppStatus();
});
