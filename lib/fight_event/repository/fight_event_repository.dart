import 'package:dio/dio.dart' hide Headers;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mma_flutter/common/const/data.dart';
import 'package:mma_flutter/common/model/pagination_model.dart';
import 'package:mma_flutter/common/provider/dio/dio_provider.dart';
import 'package:mma_flutter/common/repository/pagination_base_repository.dart';
import 'package:mma_flutter/fight_event/model/fight_event_model.dart';
import 'package:mma_flutter/fight_event/model/fighter_fight_event_detail_model.dart';
import 'package:retrofit/error_logger.dart';
import 'package:retrofit/http.dart';

part 'fight_event_repository.g.dart';

final fightEventRepositoryProvider = Provider<FightEventRepository>((ref) {
  final dio = ref.read(dioProvider);
  return FightEventRepository(dio, baseUrl: '$baseUrl/event');
});

@RestApi()
abstract class FightEventRepository
    implements PaginationBaseRepository<FighterFightEventModel> {
  factory FightEventRepository(Dio dio, {String baseUrl}) =
      _FightEventRepository;

  @GET('/days')
  @Headers({'accessToken' : 'true'})
  Future<List<int>> getDays({@Query('year') required int year, @Query('month') required int month});

  @GET('/detail')
  @Headers({'accessToken': 'true'})
  Future<List<FightEventModel>?> getSchedule({@Query('date') required String date});

  @GET('/card/detail')
  @Headers({'accessToken': 'true'})
  Future<FighterFightEventDetailModel> getFighterFightEventDetail({
    @Query('cardId') required String ffeId,
  });

  @override
  @GET('/events')
  @Headers({'accessToken': 'true'})
  Future<Pagination<FighterFightEventModel>> paginate({
    @Queries() Map<String, dynamic>? params,
  });
}
