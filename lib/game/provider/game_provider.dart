import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mma_flutter/common/const/data.dart';
import 'package:mma_flutter/common/model/base_state_model.dart';
import 'package:mma_flutter/common/provider/dio/dio_provider.dart';
import 'package:mma_flutter/game/model/fight_game_response_model.dart';
import 'package:mma_flutter/game/model/game_args.dart';
import 'package:mma_flutter/game/model/game_attempt_response_model.dart';
import 'package:mma_flutter/game/model/image_game_response_model.dart';
import 'package:mma_flutter/game/model/name_game_response_model.dart';
import 'package:mma_flutter/game/repository/game_repository.dart';
import 'package:mma_flutter/user/model/user_model.dart';
import 'package:mma_flutter/user/provider/user_provider.dart';

final gameAttemptCountProvider =
    FutureProvider.autoDispose<GameAttemptResponseModel>((ref) async {
      ref.onDispose(() => log('dispose gameAttemptCountProvider'));
      return await ref.watch(gameRepositoryProvider).getGameAttemptCount();
    });

/// gameProvider를 더 이상 참조하는 위젯이 없을 때 자동 dispose
/// family : <Notifier, State, Arg>
final gameProvider = StateNotifierProvider.family<
  GameStateNotifier,
  StateBase<GameState>,
  GameArgs
>((ref, gameArgs) {
  ref.onDispose(() => log('dispose gameProvider'));
  final gameRepository = ref.read(gameRepositoryProvider);
  return GameStateNotifier(
    gameRepository: gameRepository,
    ref: ref,
    isNormal: gameArgs.isNormal,
    type: gameArgs.type,
  );
});

final gameRepositoryProvider = Provider<GameRepository>((ref) {
  final dio = ref.read(dioProvider);
  return GameRepository(dio, baseUrl: '$baseUrl/game');
});

class GameStateNotifier extends StateNotifier<StateBase<GameState>> {
  final Ref ref;
  final GameRepository gameRepository;
  final bool isNormal;
  final GameType type;
  List<String> questions = [];
  List<GameResponse> responses = [];
  List<List<String>> selectionsList = [];
  List<String> selectedList = ['', '', '', '', ''];
  List<String> answers = [];

  GameStateNotifier({
    required this.gameRepository,
    required this.ref,
    required this.isNormal,
    required this.type,
  }) : super(StateLoading()) {
    fetchGameQuestions();
  }

  Future<void> fetchGameQuestions() async {
    try {
      switch (type) {
        case GameType.name:
          final resp = await gameRepository.getNameGame(
            isNormal: isNormal,
            type: type.name.toUpperCase(),
          );
          for (NameGameResponseModel e in resp) {
            log(e.nameGameCategory.toString());
            responses.add(NameGameResponse(e));
            questions.add(e.nameGameCategory.textQuestion(model: e));
            selectionsList.add([...e.wrongSelections, e.answer]..shuffle());
            answers.add(e.answer);
          }
          break;
        case GameType.fight:
          final resp = await gameRepository.getFightGame(
            isNormal: isNormal,
            type: type.name.toUpperCase(),
          );
          for (FightGameResponseModel e in resp) {
            responses.add(FightGameResponse(e));
            questions.add(e.textQuestion);
            selectionsList.add(
              [
                ...e.wrongSelections.map((e) => e.toString()),
                e.answer.toString(),
              ]..shuffle(),
            );
            answers.add(e.answer.toString());
          }
      }
      state = StateData<GameState>(
        data: GameState(
          type: type,
          gameResponses: responses,
          selectionsList: selectionsList,
          selectedList: selectedList,
        ),
      );
    } catch (e, stack) {
      print(e);
      print(stack);
      state = StateError(message: 'error while getting game questions');
    }
  }

  void selectAnswer(int index, String answer) {
    selectedList[index] = answer;
    state = StateData(
      data: GameState(
        type: type,
        gameResponses: responses,
        selectionsList: selectionsList,
        selectedList: selectedList,
      ),
    );
  }

  Future<int> getCorrectCount() async{
    log('$selectedList');
    try {
      final userState = ref.read(userProvider);
      if(userState is! UserModel) return -1;
      int currentPoint = userState.point;
      int correctCount = 0;
      final List<String> answers = getCorrectAnswers();
      for (int i = 0; i < answers.length; i++) {
        if (selectedList[i] == answers[i]) {
          currentPoint += isNormal ? 5 : 10;
          correctCount += 1;
        }
      }
      await updateUserPoint(currentPoint);
      return correctCount;
    } catch (e) {
      log('error while getting answer names');
      return -1;
    }
  }

  Future<void> updateUserPoint(int newPoint) async {
    ref
        .read(userProvider.notifier)
        .updatePoint(
          await gameRepository.updatePoint(newPoint: newPoint.toString()),
        );
  }

  List<String> getCorrectAnswers() {
    return answers;
  }
}
