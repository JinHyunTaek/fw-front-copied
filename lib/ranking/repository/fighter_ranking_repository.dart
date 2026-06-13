import 'package:dio/dio.dart' hide Headers;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mma_flutter/common/const/data.dart';
import 'package:mma_flutter/common/provider/dio/dio_provider.dart';
import 'package:mma_flutter/ranking/model/rankers_model.dart';
import 'package:retrofit/error_logger.dart';
import 'package:retrofit/http.dart';

part 'fighter_ranking_repository.g.dart';

final rankersFutureProvider = FutureProvider.family((
  ref,
  RankingCategory category,
) {
  return ref
      .read(rankersRepositoryProvider)
      .rankers(category: category.requestValue);
});

final rankersRepositoryProvider = Provider((ref) {
  final dio = ref.read(dioProvider);
  return FighterRankingRepository(dio, baseUrl: '$baseUrl/rankers');
});

@RestApi()
abstract class FighterRankingRepository {
  factory FighterRankingRepository(Dio dio, {String baseUrl}) =
      _FighterRankingRepository;

  @GET('')
  @Headers({'accessToken': 'true'})
  Future<RankersModel> rankers({
    @Query("category") required String category,
  });
}
