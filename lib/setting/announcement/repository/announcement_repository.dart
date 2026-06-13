import 'package:dio/dio.dart' hide Headers;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mma_flutter/common/const/data.dart';
import 'package:mma_flutter/common/model/pagination_model.dart';
import 'package:mma_flutter/common/provider/dio/dio_provider.dart';
import 'package:mma_flutter/common/repository/pagination_base_repository.dart';
import 'package:mma_flutter/setting/announcement/model/announcement_content_model.dart';
import 'package:mma_flutter/setting/announcement/model/announcement_model.dart';
import 'package:retrofit/error_logger.dart';
import 'package:retrofit/http.dart';

part 'announcement_repository.g.dart';

final announcementRepositoryProvider = Provider((ref) {
  final dio = ref.read(dioProvider);
  return AnnouncementRepository(dio, baseUrl: '$baseUrl/announcement');
});

@RestApi()
abstract class AnnouncementRepository
    implements PaginationBaseRepository<AnnouncementModel> {
  factory AnnouncementRepository(Dio dio, {String baseUrl}) =
      _AnnouncementRepository;

  @override
  @GET('/announcements')
  @Headers({'accessToken': 'true'})
  Future<Pagination<AnnouncementModel>> paginate({
    @Queries() Map<String, dynamic>? params,
  });

  @GET('/{id}')
  @Headers({'accessToken': 'true'})
  Future<AnnouncementContentModel> getAnnouncementContent({
    @Path('id') required int id,
  });
}
