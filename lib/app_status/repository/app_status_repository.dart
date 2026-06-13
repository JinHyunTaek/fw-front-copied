import 'package:dio/dio.dart' hide Headers;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mma_flutter/app_status/model/app_status_response_model.dart';
import 'package:mma_flutter/common/const/data.dart';
import 'package:mma_flutter/common/provider/dio/dio_provider.dart';
import 'package:retrofit/error_logger.dart';
import 'package:retrofit/http.dart';

part 'app_status_repository.g.dart';

final appStatusRepositoryProvider = Provider((ref) {
  final dio = ref.read(dioProvider);
  return AppStatusRepository(dio,baseUrl: '$baseUrl/app-status');
},);

@RestApi()
abstract class AppStatusRepository {
  factory AppStatusRepository(Dio dio,{String baseUrl}) = _AppStatusRepository;

  @GET('')
  Future<AppStatusResponseModel> getAppStatus();

}