import 'package:dio/dio.dart' hide Headers;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mma_flutter/common/const/data.dart';
import 'package:mma_flutter/common/model/pagination_model.dart';
import 'package:mma_flutter/common/provider/dio/dio_provider.dart';
import 'package:mma_flutter/common/repository/pagination_base_repository.dart';
import 'package:mma_flutter/fight_event/model/fight_event_model.dart';
import 'package:mma_flutter/fighter/model/fighter_detail_model.dart';
import 'package:mma_flutter/fighter/model/fighter_model.dart';
import 'package:mma_flutter/fighter/model/fighter_rating_request_model.dart';
import 'package:retrofit/error_logger.dart';
import 'package:retrofit/http.dart';

part 'fighter_repository.g.dart';

final fighterRepositoryProvider = Provider<FighterRepository>((ref) {
  final dio = ref.read(dioProvider);
  return FighterRepository(dio, baseUrl: '$baseUrl/fighter');
});

@RestApi()
abstract class FighterRepository
    implements PaginationBaseRepository<FighterModel> {
  factory FighterRepository(Dio dio, {String baseUrl}) = _FighterRepository;

  @GET('/{fighterId}')
  @Headers({'accessToken': 'true'})
  Future<FighterDetailModel> detail({
    @Path('fighterId') required int fighterId,
  });

  @GET('/{fighterId}/fights')
  @Headers({'accessToken': 'true'})
  Future<List<FighterFightEventModel>> getFightEventsByYear({
    @Path('fighterId') required int fighterId,
    @Query('year') required int year,
  });

  // @GET('/headshot')
  // @Headers({'accessToken': 'true'})
  // Future<Map<String, String>> getHeadshotUrl({
  //   @Query("name") required String name,
  // });
  //
  // @GET('/body')
  // @Headers({'accessToken': 'true'})
  // Future<Map<String, String>> getBodyUrl({@Query("name") required String name});

  @POST('/rating')
  @Headers({'accessToken': 'true'})
  Future<void> updateRating({
    @Body() required FighterRatingRequestModel request,
  });

  @override
  @GET('/fighters')
  @Headers({'accessToken': 'true'})
  Future<Pagination<FighterModel>> paginate({
    @Queries() Map<String, dynamic>? params,
  });
}
