/// AI 챗봇 대화 스레드의 한 말풍선(턴).
///
/// 칩 선택으로 만들어진 질문/안내, SSE 로 채워지는 답변이 모두 이 모델의
/// 리스트로 누적된다. 자유 입력을 나중에 얹어도 이 스레드 모델은 그대로
/// 재사용된다(입력 수단만 칩 ↔ 텍스트필드로 바뀔 뿐).
class AiChatMessage {
  final bool isUser;

  /// 봇 답변은 SSE 토큰이 도착할 때마다 누적되므로 가변이다.
  String text;

  /// 봇 답변이 아직 스트리밍 중인지(타이핑 인디케이터 노출 여부).
  bool isStreaming;

  /// 스트리밍 도중 오류로 종료됐는지(오류 메시지를 빨간색으로 표시).
  bool isError;

  AiChatMessage.user(this.text)
    : isUser = true,
      isStreaming = false,
      isError = false;

  AiChatMessage.bot({
    this.text = '',
    this.isStreaming = false,
    this.isError = false,
  }) : isUser = false;
}
