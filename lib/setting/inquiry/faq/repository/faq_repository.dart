import 'package:dio/dio.dart' hide Headers;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mma_flutter/common/const/data.dart';
import 'package:mma_flutter/common/provider/dio/dio_provider.dart';
import 'package:mma_flutter/setting/inquiry/faq/model/faq_answers_response_model.dart';
import 'package:mma_flutter/setting/inquiry/faq/model/faq_response_model.dart';
import 'package:retrofit/error_logger.dart';
import 'package:retrofit/http.dart';

part 'faq_repository.g.dart';

final faqRepositoryProvider = Provider((ref) {
  final dio = ref.read(dioProvider);
  return FaqRepository(dio, baseUrl: '$baseUrl/faq');
});

@RestApi()
abstract class FaqRepository {
  factory FaqRepository(Dio dio, {String baseUrl}) = _FaqRepository;

  @Headers({'accessToken': 'true'})
  @GET('/faqs')
  Future<List<FaqResponseModel>> getFaqs();

  @Headers({'accessToken': 'true'})
  @GET('')
  Future<FAQAnswersResponseModel> faqsFromCategory({@Query('category') required String category});
}
