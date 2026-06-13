import 'dart:convert';

import 'package:dio/dio.dart' hide Headers;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mma_flutter/common/const/data.dart';
import 'package:mma_flutter/common/provider/dio/dio_provider.dart';
import 'package:mma_flutter/stream/ai/model/ai_question_model.dart';
import 'package:retrofit/error_logger.dart';
import 'package:retrofit/http.dart';

part 'ai_chat_repository.g.dart';

final aiChatRepositoryProvider = Provider((ref) {
  final dio = ref.read(dioProvider);
  return AiChatRepository(
    AiChatClient(dio, baseUrl: '$baseUrl/stream'),
    dio,
  );
});

/// 타입이 고정된 JSON 엔드포인트만 retrofit 으로 생성한다.
/// (SSE 스트리밍은 retrofit 의 용례가 아니라 [AiChatRepository] 에서 raw dio 로 처리.)
@RestApi()
abstract class AiChatClient {
  factory AiChatClient(Dio dio, {String baseUrl}) = _AiChatClient;

  /// 챗봇 진입 시 노출할 고정 질문 메뉴(서버 단일 출처).
  @GET('/ai/questions')
  @Headers({'accessToken': 'true'})
  Future<List<AiQuestionModel>> getQuestions();
}

/// AI 챗봇 데이터 레이어.
/// - 질문 메뉴: retrofit([AiChatClient]) 위임
/// - 답변 스트리밍: text/event-stream(SSE)을 raw dio 로 받아 토큰 스트림으로 변환
class AiChatRepository {
  final AiChatClient _client;
  final Dio _dio;

  AiChatRepository(this._client, this._dio);

  Future<List<AiQuestionModel>> getQuestions() => _client.getQuestions();

  /// 이벤트 단위 질문(카드 전체 큐레이션) - id 불필요.
  Stream<String> askEvent(String question) =>
      _sse('/ai/event', {'question': question});

  /// 경기 단위 질문(A vs B head-to-head) - fightId 필수.
  Stream<String> askFight(String question, int fightId) =>
      _sse('/ai/fight', {'question': question, 'fightId': fightId});

  /// 선수 단위 질문(스카우팅 리포트) - fighterId 필수.
  Stream<String> askFighter(String question, int fighterId) =>
      _sse('/ai/fighter', {'question': question, 'fighterId': fighterId});

  /// SSE(text/event-stream) 응답을 받아 토큰 문자열을 순서대로 흘려보낸다.
  /// done 이벤트에서 정상 종료하고, error 이벤트에서 [AiChatException] 을 던진다.
  ///
  /// 프레임 형식:
  ///   event:token\n data:{"answer":"..."}\n\n  → 토큰 조각(누적)
  ///   event:done\n  data:{"answer":"done"}\n\n → 완료
  ///   event:error\n data:{"answer":"..."}\n\n  → 오류
  ///
  /// receiveTimeout 은 dio 에서 '토큰 사이 간격'(inter-chunk)에 적용되므로,
  /// 전체 답변 길이는 제한하지 않으면서 죽은 커넥션은 60초 안에 감지하도록 둔다
  /// (글로벌 dio 의 15초는 첫 토큰 지연/느린 LLM 에서 끊겨 여기서 덮어쓴다).
  Stream<String> _sse(String path, Map<String, dynamic> query) async* {
    final res = await _dio.get<ResponseBody>(
      '$baseUrl/stream$path',
      queryParameters: query,
      options: Options(
        headers: {'accessToken': 'true', 'Accept': 'text/event-stream'},
        responseType: ResponseType.stream,
        receiveTimeout: const Duration(seconds: 60),
      ),
    );

    // utf8.decoder 로 변환하면 한글 멀티바이트가 청크 경계에서 깨지지 않는다.
    final decoded = res.data!.stream.cast<List<int>>().transform(utf8.decoder);

    final buffer = StringBuffer();
    await for (final chunk in decoded) {
      buffer.write(chunk);
      var content = buffer.toString();

      // 빈 줄(\n\n)로 구분된 '완성된' 프레임만 처리하고, 나머지는 버퍼에 남긴다.
      int sep;
      while ((sep = content.indexOf('\n\n')) != -1) {
        final frame = content.substring(0, sep);
        content = content.substring(sep + 2);

        String? event;
        final dataLines = <String>[];
        for (final line in const LineSplitter().convert(frame)) {
          if (line.startsWith('event:')) {
            event = line.substring(6).trim();
          } else if (line.startsWith('data:')) {
            dataLines.add(line.substring(5).trim());
          }
        }
        if (dataLines.isEmpty) continue;

        final answer = jsonDecode(dataLines.join('\n'))['answer'] as String?;

        if (event == 'error') {
          throw AiChatException(answer ?? '처리 중 오류가 발생했습니다.');
        }
        if (event == 'done') {
          return;
        }
        // event == 'token'
        if (answer != null && answer.isNotEmpty) {
          yield answer;
        }
      }

      buffer
        ..clear()
        ..write(content);
    }
  }
}

class AiChatException implements Exception {
  final String message;

  AiChatException(this.message);

  @override
  String toString() => message;
}
