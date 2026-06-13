import 'dart:io';

import 'package:dio/dio.dart' hide Headers;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mma_flutter/common/const/data.dart';
import 'package:mma_flutter/common/model/pagination_model.dart';
import 'package:mma_flutter/common/provider/dio/dio_provider.dart';
import 'package:mma_flutter/common/repository/pagination_base_repository.dart';
import 'package:mma_flutter/ranking/model/user_ranking_model.dart';
import 'package:mma_flutter/stream/bet/model/bet_response_model.dart';
import 'package:mma_flutter/user/model/join_request.dart';
import 'package:mma_flutter/user/model/password_reset_request.dart';
import 'package:mma_flutter/user/model/user_model.dart';
import 'package:mma_flutter/user/model/user_profile_model.dart';
import 'package:mma_flutter/user/model/withdrawal_request.dart';
import 'package:retrofit/http.dart';
import 'package:retrofit/error_logger.dart';

part 'user_repository.g.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  final dio = ref.read(dioProvider);
  return UserRepository(dio, baseUrl: '$baseUrl/user');
});

// $baseUrl/user/me
@RestApi()
abstract class UserRepository {
  factory UserRepository(Dio dio, {String baseUrl}) = _UserRepository;

  @GET('/me')
  @Headers({'accessToken': 'true'})
  Future<UserModel?> getMe();

  @GET('/dup_nickname')
  Future<bool> checkDuplicatedNickname({
    @Body() required Map<String, String> nickname,
  });

  @GET('/password')
  @Headers({'accessToken': 'true'})
  Future<bool> checkPassword({@Body() required Map<String, String> password});

  @GET('/is_social')
  @Headers({'accessToken': 'true'})
  Future<bool> checkIsSocial();

  @PATCH('/nickname')
  @Headers({'accessToken': 'true'})
  Future<UserModel> updateNickname({
    @Body() required Map<String, String> nickname,
  });

  @PATCH('/password')
  @Headers({'accessToken': 'true'})
  Future<void> changePassword({@Body() required Map<String, String> password});

  @PATCH('/password-reset')
  Future<void> resetPassword({@Body() required PasswordResetRequest request});

  @POST('')
  Future<void> join({@Body() required JoinRequest request});

  @DELETE('')
  @Headers({'accessToken': 'true'})
  Future<void> delete({@Body() required WithdrawalRequest request});

  @GET('/profile')
  @Headers({'accessToken': 'true'})
  Future<UserProfileModel> profile();

  @Headers({'accessToken': 'true'})
  @PUT('/image')
  Future<String> uploadProfileImage({ @Body() required FormData image,}   );

  @DELETE('/image')
  @Headers({'accessToken': 'true'})
  Future<void> deleteProfileImage();

  @GET('/{id}/bet_history')
  @Headers({'accessToken' : 'true'})
  Future<List<BetResponseModel>> getUserRecentBetHistory({@Path('id') required int userId,});

  @GET('/ranking')
  @Headers({'accessToken': 'true'})
  Future<UserRankingModel> getUserRanking();
}
