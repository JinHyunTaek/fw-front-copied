import 'package:dio/dio.dart' hide Headers;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mma_flutter/common/const/data.dart';
import 'package:mma_flutter/common/provider/dio/dio_provider.dart';
import 'package:mma_flutter/event/common/dto/event_card_model.dart';
import 'package:retrofit/error_logger.dart';
import 'package:retrofit/http.dart';

part 'event_repository.g.dart';

final eventRepositoryProvider = Provider<EventRepository>((ref) {
  final dio = ref.read(dioProvider);
  return EventRepository(dio, baseUrl: '$baseUrl/event');
});

@RestApi()
abstract class EventRepository {
  factory EventRepository(Dio dio, {String baseUrl}) = _EventRepository;

  @GET('')
  @Headers({'accessToken' : 'true'})
  Future<EventCardsModel> getActiveEvents();

}