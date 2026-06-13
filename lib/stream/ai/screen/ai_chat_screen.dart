import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gpt_markdown/gpt_markdown.dart';
import 'package:mma_flutter/common/component/retry_loading/custom_circular_progess_indicator.dart';
import 'package:mma_flutter/common/component/retry_loading/retry_button.dart';
import 'package:mma_flutter/common/const/colors.dart';
import 'package:mma_flutter/fight_event/model/fighter_fight_event_detail_model.dart';
import 'package:mma_flutter/main.dart';
import 'package:mma_flutter/stream/ai/model/ai_chat_message.dart';
import 'package:mma_flutter/stream/ai/model/ai_question_model.dart';
import 'package:mma_flutter/stream/ai/provider/ai_chat_provider.dart';
import 'package:mma_flutter/stream/ai/repository/ai_chat_repository.dart';
import 'package:mma_flutter/stream/model/stream_fight_event_model.dart';

/// 이번 주 카드 전용 AI 분석 챗봇.
///
/// 사용자는 자유 입력 없이 하단 추천칩으로만 질문을 고른다(가이드형 대화).
/// 흐름: 카테고리(이벤트/경기/선수) → (선수는 대상 선택) → 상세 질문 → SSE 답변.
/// 경기 질문은 헤더에 잡힌 '현재 경기'를 대상으로 한다.
class AiChatScreen extends ConsumerStatefulWidget {
  final StreamFightEventModel event;

  const AiChatScreen({required this.event, super.key});

  @override
  ConsumerState<AiChatScreen> createState() => _AiChatScreenState();
}

/// 하단 칩 영역이 무엇을 보여줄지 결정하는 대화 단계.
enum _Step {
  category, // 1
  eventQuestions, // 2
  fightQuestions, // 2
  fightSelect, // 3
  fighterQuestions, // 2
  fighterSelect, // 3
}

class _AiChatScreenState extends ConsumerState<AiChatScreen> {
  final List<AiChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();

  _Step _step = _Step.category;
  bool _busy = false; // 답변 스트리밍 중에는 칩을 숨긴다.
  StreamSubscription<String>? _sub;

  /// 경기 질문 대상(헤더의 현재 경기). 카드가 비어 있으면 null.

  /// 이번 주 카드에 출전하는 선수 전원(중복 제거).
  late final List<FighterFightEventFighterModel> _fighters;

  /// 선수 질문 대상으로 사용자가 고른 선수.
  FighterFightEventFighterModel? _selectedFighter;
  StreamFighterFightEventModel? _selectedFight;

  @override
  void initState() {
    super.initState();
    _fighters = _collectFighters();
    _messages.add(
      AiChatMessage.bot(
        text: '안녕하세요! 이번 주 카드 분석 도우미예요.\n무엇이 궁금하세요? 아래에서 골라보세요.',
      ),
    );
  }

  @override
  void dispose() {
    _sub?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  List<FighterFightEventFighterModel> _collectFighters() {
    final byId = <int, FighterFightEventFighterModel>{};
    for (final ffe in widget.event.fighterFightEvents) {
      byId[ffe.winner.id] = ffe.winner;
      byId[ffe.loser.id] = ffe.loser;
    }
    return byId.values.toList();
  }

  String _fighterName(FighterFightEventFighterModel f) =>
      f.koreanName ?? f.name;

  void _scrollToBottom() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _addBotPrompt(String text) {
    setState(() => _messages.add(AiChatMessage.bot(text: text)));
    _scrollToBottom();
  }

  // ===== 단계 전환 =====

  void _selectCategory(AiQuestionCategory category) {
    switch (category) {
      case AiQuestionCategory.event:
        _addBotPrompt('이번 주 카드 전체 중 무엇이 궁금하세요?');
        setState(() => _step = _Step.eventQuestions);
      case AiQuestionCategory.fight:
        _addBotPrompt('어떤 경기에 대해 분석해드릴까요?');
        setState(() => _step = _Step.fightSelect);
      case AiQuestionCategory.fighter:
        _addBotPrompt('어떤 선수가 궁금하세요?');
        setState(() => _step = _Step.fighterSelect);
    }
  }

  void _selectFight(StreamFighterFightEventModel fight) {
    setState(() {
      _selectedFight = fight;
    });
    _addBotPrompt(
      '${_fighterName(fight.winner)} vs ${_fighterName(fight.loser)} 경기에 대해 무엇을 알려드릴까요?',
    );
    setState(() {
      _step = _Step.fightQuestions;
    });
  }

  void _selectFighter(FighterFightEventFighterModel fighter) {
    setState(() => _selectedFighter = fighter);
    _addBotPrompt('「${_fighterName(fighter)}」 선수에 대해 무엇을 알려드릴까요?');
    setState(() => _step = _Step.fighterQuestions);
  }

  void _backToCategory() {
    setState(() => _step = _Step.category);
  }

  // ===== 질문 → SSE 답변 =====

  void _ask(AiQuestionModel q) {
    final repo = ref.read(aiChatRepositoryProvider);
    final bot = AiChatMessage.bot(isStreaming: true);
    setState(() {
      _messages.add(AiChatMessage.user(q.label));
      _messages.add(bot);
      _busy = true;
      _step = _Step.category; // 답변이 끝나면 다시 카테고리부터 고를 수 있게.
    });
    _scrollToBottom();

    final Stream<String> stream = switch (q.category) {
      AiQuestionCategory.event => repo.askEvent(q.value),
      AiQuestionCategory.fight => repo.askFight(q.value, _selectedFight!.id),
      AiQuestionCategory.fighter => repo.askFighter(
        q.value,
        _selectedFighter!.id,
      ),
    };

    _sub = stream.listen(
      (token) {
        setState(() => bot.text += token);
        _scrollToBottom();
      },
      onError: (e) {
        setState(() {
          bot.isStreaming = false;
          bot.isError = true;
          if (bot.text.isEmpty) {
            bot.text = e is AiChatException ? e.message : '처리 중 오류가 발생했습니다.';
          }
          _busy = false;
        });
        _scrollToBottom();
      },
      onDone: () {
        setState(() {
          bot.isStreaming = false;
          _busy = false;
        });
        _scrollToBottom();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final questions = ref.watch(aiQuestionsProvider);

    return Scaffold(
      backgroundColor: context.colors.surface,
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.smart_toy_outlined, color: context.colors.onSurface),
            SizedBox(width: 8.w),
            Text(
              'AI 분석 도우미',
              style: context.text.bodyLarge?.copyWith(fontSize: 16.sp),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.separated(
                controller: _scrollController,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                itemCount: _messages.length,
                separatorBuilder: (_, __) => SizedBox(height: 12.h),
                itemBuilder: (_, i) => _Bubble(message: _messages[i]),
              ),
            ),
            _buildChipArea(questions),
          ],
        ),
      ),
    );
  }

  /// 하단 추천칩 영역. 현재 단계와 서버 질문 메뉴에 따라 칩을 바꾼다.
  /// (자유 입력을 도입할 땐 이 영역을 텍스트 입력바로 교체/병행하면 된다.)
  Widget _buildChipArea(AsyncValue<List<AiQuestionModel>> questions) {
    return Container(
      width: double.infinity,
      color: context.colors.box,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      child: SafeArea(
        top: false,
        child: questions.when(
          loading: () => const Center(child: CustomCircularProgressIndicator()),
          error:
              (_, __) => RetryButton(
                onRetry: () => ref.invalidate(aiQuestionsProvider),
              ),
          data: (aiQuestions) => _chips(aiQuestions),
        ),
      ),
    );
  }

  Widget _chips(List<AiQuestionModel> aiQuestions) {
    if (_busy) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 16.r,
            height: 16.r,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: context.colors.onBox,
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            '분석 중…',
            style: context.text.bodyMedium?.copyWith(
              color: context.colors.onBox,
              fontSize: 13.sp,
            ),
          ),
        ],
      );
    }

    final chips = <Widget>[];
    switch (_step) {
      case _Step.category:
        chips.add(
          _chip(
            label: '이벤트',
            icon: Icons.event,
            onTap: () => _selectCategory(AiQuestionCategory.event),
          ),
        );
        chips.add(
          _chip(
            label: '경기',
            icon: Icons.sports_mma,
            onTap: () => _selectCategory(AiQuestionCategory.fight),
          ),
        );
        chips.add(
          _chip(
            label: '선수',
            icon: Icons.person,
            onTap: () => _selectCategory(AiQuestionCategory.fighter),
          ),
        );
      case _Step.eventQuestions:
        chips.addAll(_questionChips(aiQuestions, AiQuestionCategory.event));
        chips.add(_backChip());
      case _Step.fightSelect:
        for (final ffe in widget.event.fighterFightEvents) {
          chips.add(
            _chip(
              label:
                  '${(_fighterName(ffe.winner))} vs '
                  '${(_fighterName(ffe.loser))}',
              onTap: () => _selectFight(ffe),
            ),
          );
        }
        chips.add(_backChip());
      case _Step.fightQuestions:
        chips.addAll(_questionChips(aiQuestions, AiQuestionCategory.fight));
        chips.add(_backChip());
      case _Step.fighterSelect:
        for (final f in _fighters) {
          chips.add(
            _chip(label: _fighterName(f), onTap: () => _selectFighter(f)),
          );
        }
        chips.add(_backChip());
      case _Step.fighterQuestions:
        chips.addAll(_questionChips(aiQuestions, AiQuestionCategory.fighter));
        chips.add(_backChip());
    }

    // 선수가 많을 수 있어 세로로 넘치면 스크롤되게 높이를 제한한다.
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: 160.h),
      child: SingleChildScrollView(
        child: Wrap(spacing: 8.w, runSpacing: 8.h, children: chips),
      ),
    );
  }

  List<Widget> _questionChips(
    List<AiQuestionModel> aiQuestions,
    AiQuestionCategory category,
  ) {
    return aiQuestions
        .where((q) => q.category == category)
        .map((q) => _chip(label: q.label, onTap: () => _ask(q)))
        .toList();
  }

  Widget _backChip() =>
      _chip(label: '뒤로', icon: Icons.arrow_back, onTap: _backToCategory);

  Widget _chip({
    required String label,
    IconData? icon,
    required VoidCallback onTap,
  }) {
    return ActionChip(
      onPressed: onTap,
      backgroundColor: context.colors.surface,
      side: BorderSide(color: context.colors.subText),
      avatar:
          icon == null
              ? null
              : Icon(icon, size: 16.r, color: context.colors.onSurface),
      label: Text(
        label,
        style: context.text.bodyMedium?.copyWith(
          color: context.colors.onSurface,
          fontSize: 13.sp,
        ),
      ),
    );
  }
}

/// 단일 말풍선. 유저는 우측 정렬, 봇은 좌측 정렬 + 로봇 아바타.
class _Bubble extends StatelessWidget {
  final AiChatMessage message;

  const _Bubble({required this.message});

  @override
  Widget build(BuildContext context) {
    if (message.isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: _bubbleBox(
          context,
          background: BLUE_COLOR,
          child: Text(
            message.text,
            style: context.text.bodyMedium?.copyWith(
              color: WHITE_COLOR,
              fontSize: 14.sp,
              height: 1.4,
            ),
          ),
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 16.r,
          backgroundColor: context.colors.box,
          child: Icon(
            Icons.smart_toy_outlined,
            size: 18.r,
            color: context.colors.onBox,
          ),
        ),
        SizedBox(width: 8.w),
        Flexible(
          child: _bubbleBox(
            context,
            background: context.colors.box,
            child: _botContent(context),
          ),
        ),
      ],
    );
  }

  Widget _botContent(BuildContext context) {
    // 답변 시작 전(빈 텍스트 + 스트리밍 중)에는 '입력 중' 점 애니메이션을 보여준다.
    if (message.isStreaming && message.text.isEmpty) {
      return _TypingDots(color: context.colors.onBox);
    }

    final style = context.text.bodyMedium?.copyWith(
      color: message.isError ? RED_COLOR : context.colors.onBox,
      fontSize: 14.sp,
      height: 1.4,
    );

    // 오류 메시지는 평문, LLM 답변은 마크다운(굵게·불릿·목록)으로 렌더한다.
    // gpt_markdown 은 스트리밍 중 불완전한 마크다운도 깨지지 않게 처리한다.
    return message.isError
        ? Text(message.text, style: style)
        : GptMarkdown(message.text, style: style);
  }

  Widget _bubbleBox(
    BuildContext context, {
    required Color background,
    required Widget child,
  }) {
    return Container(
      constraints: BoxConstraints(maxWidth: 280.w),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: child,
    );
  }
}

/// 봇이 첫 토큰을 만들기 전 보여주는 '입력 중' 점 3개 애니메이션.
/// 각 점이 시차를 두고 밝아졌다 어두워지며 채팅의 타이핑 인디케이터를 표현한다.
class _TypingDots extends StatefulWidget {
  final Color color;

  const _TypingDots({required this.color});

  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1000),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 18.r,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(3, (i) {
              // 점마다 위상을 어긋나게 해 순차적으로 깜빡이게 한다.
              final t = (_controller.value - i * 0.2) % 1.0;
              final opacity = (0.3 + (1 - (t * 2 - 1).abs()) * 0.7).clamp(
                0.3,
                1.0,
              );
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 2.w),
                child: Opacity(
                  opacity: opacity,
                  child: Container(
                    width: 7.r,
                    height: 7.r,
                    decoration: BoxDecoration(
                      color: widget.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}
