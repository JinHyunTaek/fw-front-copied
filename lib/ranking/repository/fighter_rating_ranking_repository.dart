import 'package:dio/dio.dart' hide Headers;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mma_flutter/common/const/data.dart';
import 'package:mma_flutter/common/model/pagination_model.dart';
import 'package:mma_flutter/common/provider/dio/dio_provider.dart';
import 'package:mma_flutter/common/provider/pagination_notifier.dart';
import 'package:mma_flutter/common/repository/pagination_base_repository.dart';
import 'package:mma_flutter/ranking/model/rating_ranker_model.dart';
import 'package:retrofit/error_logger.dart';
import 'package:retrofit/http.dart';

part 'fighter_rating_ranking_repository.g.dart';

final fighterRatingRankingPaginationProvider = StateNotifierProvider((ref) {
  final repo = ref.read(ratingRankingRepositoryProvider);
  return FighterRatingRakingPaginationStateNotifier(repository: repo);
});

class FighterRatingRakingPaginationStateNotifier
    extends PaginationNotifier<RatingRankerModel, RatingRankingRepository> {
  FighterRatingRakingPaginationStateNotifier({required super.repository});
}


final ratingRankingRepositoryProvider = Provider((ref) {
  final dio = ref.read(dioProvider);
  return RatingRankingRepository(dio, baseUrl: '$baseUrl/fighter/rating');
},);

@RestApi()
abstract class RatingRankingRepository implements PaginationBaseRepository<RatingRankerModel>{
  factory RatingRankingRepository(Dio dio, {String baseUrl}) = _RatingRankingRepository;

  @override
  @GET('')
  @Headers({'accessToken': 'true'})
  Future<Pagination<RatingRankerModel>> paginate({
    @Queries() Map<String, dynamic>? params,
  });

}