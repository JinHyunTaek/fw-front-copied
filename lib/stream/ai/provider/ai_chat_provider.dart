import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mma_flutter/stream/ai/model/ai_question_model.dart';
import 'package:mma_flutter/stream/ai/repository/ai_chat_repository.dart';

/// 챗봇 진입 시 고정 질문 메뉴를 1회 조회한다(서버가 단일 출처).
final aiQuestionsProvider = FutureProvider<List<AiQuestionModel>>((ref) {
  return ref.read(aiChatRepositoryProvider).getQuestions();
});
