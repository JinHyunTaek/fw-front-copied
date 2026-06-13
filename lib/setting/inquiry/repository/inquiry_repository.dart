import 'package:dio/dio.dart' hide Headers;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mma_flutter/common/const/data.dart';
import 'package:mma_flutter/common/model/model_with_id.dart';
import 'package:mma_flutter/common/model/pagination_model.dart';
import 'package:mma_flutter/common/provider/dio/dio_provider.dart';
import 'package:mma_flutter/common/repository/pagination_base_repository.dart';
import 'package:mma_flutter/setting/inquiry/model/inquiry_body_response_model.dart';
import 'package:mma_flutter/setting/inquiry/model/inquiry_response_model.dart';
import 'package:mma_flutter/setting/inquiry/model/inquiry_save_request_model.dart';
import 'package:retrofit/error_logger.dart';
import 'package:retrofit/http.dart';

part 'inquiry_repository.g.dart';

final inquiryRepositoryProvider = Provider((ref) {
  final dio = ref.read(dioProvider);
  return InquiryRepository(dio, baseUrl: '$baseUrl/inquiry');
});

@RestApi()
abstract class InquiryRepository extends PaginationBaseRepository<InquiryResponseModel> {
  factory InquiryRepository(Dio dio, {String baseUrl}) = _InquiryRepository;

  @GET('/{id}')
  @Headers({'accessToken': 'true'})
  Future<InquiryBodyResponseModel> getBody({
    @Path('id') required int inquiryId,
  });

  @POST('')
  @Headers({'accessToken': 'true'})
  Future<void> save({@Body() required InquirySaveRequestModel request});

  @GET('/inquiries')
  @Headers({'accessToken': 'true'})
  @override
  Future<Pagination<InquiryResponseModel>> paginate({
    @Queries() Map<String, dynamic>? params,
  });
}
