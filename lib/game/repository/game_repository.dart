import 'package:dio/dio.dart' hide Headers;
import 'package:mma_flutter/game/model/fight_game_response_model.dart';
import 'package:mma_flutter/game/model/game_args.dart';
import 'package:mma_flutter/game/model/game_attempt_response_model.dart';
import 'package:mma_flutter/game/model/image_game_response_model.dart';
import 'package:mma_flutter/game/model/name_game_response_model.dart';
import 'package:retrofit/error_logger.dart';
import 'package:retrofit/http.dart';

part 'game_repository.g.dart';

@RestApi()
abstract class GameRepository {
  factory GameRepository(Dio dio, {String baseUrl}) = _GameRepository;

  // @GET('/fighter')
  // @Headers({'accessToken': 'true'})
  // Future<List<T>> getGameQuestions<T>({
  //   @Query('isNormal') required bool isNormal,
  //   @Query('gameType') required String gameType,
  // });

  @GET('/start')
  @Headers({'accessToken': 'true'})
  Future<List<NameGameResponseModel>> getNameGame({
    @Query('isNormal') required bool isNormal,
    @Query('type') required String type,
  });

  @GET('/start')
  @Headers({'accessToken': 'true'})
  Future<List<FightGameResponseModel>> getFightGame({
    @Query('isNormal') required bool isNormal,
    @Query('type') required String type,
  });

  @GET('/attempt_count')
  @Headers({'accessToken': 'true'})
  Future<GameAttemptResponseModel> getGameAttemptCount();

  @POST('/attempt_count')
  @Headers({'accessToken': 'true'})
  Future<void> updateAttemptCount({
    @Query("isSubtract") required bool isSubtract,
  });

  @PATCH('/point')
  @Headers({'accessToken': 'true'})
  Future<int> updatePoint({@Query("newPoint") required String newPoint});

}