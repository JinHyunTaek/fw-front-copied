import 'package:mma_flutter/game/model/fight_game_response_model.dart';
import 'package:mma_flutter/game/model/image_game_response_model.dart';
import 'package:mma_flutter/game/model/name_game_response_model.dart';

class GameArgs {
  final bool isNormal;
  final GameType type;

  const GameArgs({required this.isNormal, required this.type});

  /**
   * 기존 GameScreen에서 매번 GameArgs 객체를 new로 생성해서 ref.watch(...)에 넘겨주고 있음.
      → GameArgs(isNormal: ..., isImage: ...)가 매번 새로운 객체라서 family 입장에서는 "다른 arg"로 인식함.
      → 매번 새로운 provider 인스턴스를 만들고, 그 안에서 getGameQuestions()가 다시 실행됨.
      그 결과, error 상태여도 build → watch → provider 새로 생성 → 다시 요청 → error → 무한 루프
      -> GameArgs를 const + equatable 처리 (자바와 비슷하게 ==, hashcode override 함으로써 GameArgs가 같은 객체임을 보장)
   */
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameArgs &&
          runtimeType == other.runtimeType &&
          isNormal == other.isNormal &&
          type == other.type;

  @override
  int get hashCode => isNormal.hashCode ^ type.hashCode;
}

enum GameType {
  name('선수 이름 맞추기'),
  fight('경기 승자 맞추기');

  final String description;

  const GameType(this.description);
}

sealed class GameResponse {}

class NameGameResponse extends GameResponse {
  final NameGameResponseModel model;

  NameGameResponse(this.model);
}

class ImageGameResponse extends GameResponse {
  final ImageGameResponseModel model;

  ImageGameResponse(this.model);
}

class FightGameResponse extends GameResponse {
  final FightGameResponseModel model;

  FightGameResponse(this.model);
}

class GameState{
  final GameType type;
  final List<GameResponse> gameResponses;
  final List<List<String>> selectionsList;
  final List<String> selectedList;

  GameState({
    required this.type,
    required this.gameResponses,
    required this.selectionsList,
    required this.selectedList,
  });
}