import 'package:dio/dio.dart' hide Headers;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mma_flutter/common/const/data.dart';
import 'package:mma_flutter/common/provider/dio/dio_provider.dart';
import 'package:mma_flutter/event/promotion/model/promotion_detail_model.dart';
import 'package:mma_flutter/home/model/home_promotion_model.dart';
import 'package:retrofit/error_logger.dart';
import 'package:retrofit/http.dart';

part 'promotion_repository.g.dart';

final promotionRepositoryProvider = Provider<PromotionRepository>((ref) {
  final dio = ref.read(dioProvider);
  return PromotionRepository(dio, baseUrl: '$baseUrl/promotion');
});

// 모든 /promotion 엔드포인트는 인증 필요 (SecurityConfig: anyRequest().authenticated())
@RestApi()
abstract class PromotionRepository {
  factory PromotionRepository(Dio dio, {String baseUrl}) = _PromotionRepository;

  @GET('/{id}')
  @Headers({'accessToken': 'true'})
  Future<PromotionDetailModel> getDetail({@Path('id') required int id});

}
