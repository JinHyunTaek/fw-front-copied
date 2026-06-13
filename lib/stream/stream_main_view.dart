import 'dart:convert';
import 'dart:developer';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:mma_flutter/common/component/retry_loading/custom_circular_progess_indicator.dart';
import 'package:mma_flutter/common/component/retry_loading/retry_button.dart';
import 'package:mma_flutter/common/const/colors.dart';
import 'package:mma_flutter/common/const/style.dart';
import 'package:mma_flutter/common/model/base_state_model.dart';
import 'package:mma_flutter/common/service/admob_service.dart';
import 'package:mma_flutter/common/utils/date_utils.dart';
import 'package:mma_flutter/common/utils/fight_utils.dart';
import 'package:mma_flutter/main.dart';
import 'package:mma_flutter/stream/bet/provider/bet_history_provider.dart';
import 'package:mma_flutter/stream/bet/screen/bet_screen.dart';
import 'package:mma_flutter/stream/ai/screen/ai_chat_screen.dart';
import 'package:mma_flutter/stream/bet/screen/stream_bet_history_screen.dart';
import 'package:mma_flutter/stream/chat/model/join_request_model.dart';
import 'package:mma_flutter/stream/chat/screen/chat_room.dart';
import 'package:mma_flutter/stream/model/stream_fight_event_model.dart';
import 'package:mma_flutter/stream/model/stream_message_request_model.dart';
import 'package:mma_flutter/stream/model/stream_message_response_model.dart';
import 'package:mma_flutter/stream/provider/socket_stream_provider.dart';
import 'package:mma_flutter/stream/provider/stream_component_providers.dart';
import 'package:mma_flutter/stream/provider/stream_fight_event_provider.dart';
import 'package:mma_flutter/stream/screen/stream_fight_event_screen.dart';
import 'package:mma_flutter/stream/screen/stream_fighter_info_screen.dart';
import 'package:mma_flutter/user/model/user_model.dart';

class StreamMainView extends ConsumerStatefulWidget {
  final UserModel user;

  const StreamMainView({required this.user, super.key});

  @override
  ConsumerState<StreamMainView> createState() => _StreamMainViewState();
}

class _StreamMainViewState extends ConsumerState<StreamMainView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  BannerAd? banner;

  /// CHAT 탭 인덱스(탭 순서: INFO, CARDS, PICK, RECORD, CHAT).
  static const int _chatTabIndex = 4;

  @override
  void initState() {
    log('--stream main view init--');
    _tabController = TabController(length: 5, vsync: this);
    banner = BannerAd(
      size: AdSize.banner,
      adUnitId: AdMobService.bannerAdUnitId,
      listener: AdMobService.bannerAdListener,
      request: AdRequest(),
    )..load();
    super.initState();

    Future.microtask(() {
      ref
          .read(socketProvider)
          .sink
          .add(
            json.encode(
              StreamMessageRequestModel(
                requestMessageType: RequestMessageType.join,
                chatJoinRequest: ChatJoinRequestModel(
                  nickname: widget.user.nickname!,
                  userId: widget.user.id,
                  earnedBetSucceedPoint: widget.user.earnedBetSucceedPoint,
                ),
              ),
            ),
          );

      ref.listenManual<AsyncValue<StreamMessageResponseModel>>(
        socketResponseProvider,
        (prev, next) {
          next.whenData((message) {
            if (message.responseMessageType == ResponseMessageType.talk) {
              log('talk response received');
              ref
                  .read(chatResponseProvider.notifier)
                  .update((state) => message.chatMessageResponse!);
            } else if (message.responseMessageType ==
                ResponseMessageType.fight) {
              ref
                  .read(streamFightEventProvider.notifier)
                  .update(message.streamFightEvent!);
            } else if (message.responseMessageType ==
                ResponseMessageType.connectionCount) {
              ref
                  .read(connectionCountProvider.notifier)
                  .update((state) => message.connectionCount!);
            } else if (message.responseMessageType ==
                ResponseMessageType.recentMessages) {
              ref
                  .read(recentChatMessagesProvider.notifier)
                  .update((state) => message.recentMessages!.recentMessages);
            }
          });
        },
      );
    });
  }

  @override
  void deactivate() {
    ref.invalidate(socketProvider);
    super.deactivate();
  }

  @override
  void dispose() {
    banner?.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    log('rebuild stream main view');
    final socket = ref.watch(socketProvider);
    final state = ref.watch(streamFightEventProvider);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(),
      // AI 분석 챗봇 진입점. CHAT 탭(실시간 유저 채팅)에서는 하단 입력창과
      // 겹치므로 숨긴다. 탭 전환 시 _tabController 가 notify → 재빌드.
      floatingActionButton: AnimatedBuilder(
        animation: _tabController,
        builder: (context, _) {
          // CHAT 탭(실시간 유저 채팅)에서는 숨기고, 카드 데이터가 준비된
          // 상태에서만 노출한다(AI 챗봇은 이번 주 카드 컨텍스트가 필요).
          if (_tabController.index == _chatTabIndex ||
              state is! StateData<StreamFightEventModel>) {
            return const SizedBox.shrink();
          }
          final event = state.data!;
          return FloatingActionButton(
            backgroundColor: WHITE_COLOR,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => AiChatScreen(event: event)),
            ),
            child: Icon(Icons.smart_toy_outlined, color: BLACK_COLOR),
          );
        },
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final totalHeight = constraints.maxHeight;
          final headerHeight = totalHeight * (164.22 / 768) + 24.h;
          return Column(
            children: [
              SizedBox(
                width: banner!.size.width.toDouble(),
                height: banner!.size.height.toDouble(),
                child: AdWidget(ad: banner!),
              ),
              SizedBox(height: headerHeight, child: _header(state: state)),
              Expanded(
                child: Column(
                  children: [
                    Container(
                      color: context.colors.surface,
                      height: 66.h,
                      child: TabBar(
                        indicator: BoxDecoration(color: context.colors.box),
                        indicatorSize: TabBarIndicatorSize.tab,
                        controller: _tabController,
                        labelColor: context.colors.onSurface,
                        unselectedLabelColor: GREY_COLOR,
                        indicatorColor: Colors.transparent,
                        labelStyle: TextStyle(fontSize: 12.sp),
                        // 선택된 탭 텍스트 스타일
                        unselectedLabelStyle: TextStyle(fontSize: 12.sp),
                        dividerColor: Colors.transparent,
                        // 선택되지 않은 탭 텍스트 스타일
                        tabs: [
                          Tab(
                            icon: Icon(Icons.info_outline, size: 20.h),
                            text: 'INFO',
                          ),
                          Tab(
                            icon: AnimatedBuilder(
                              animation: _tabController,
                              builder: (context, _) {
                                final isSelected = _tabController.index == 1;
                                return SvgPicture.asset(
                                  'asset/img/icon/events.svg',
                                  height: 20.h,
                                  width: 20.w,
                                  colorFilter: ColorFilter.mode(
                                    isSelected
                                        ? context.colors.onSurface
                                        : GREY_COLOR,
                                    BlendMode.srcIn,
                                  ),
                                );
                              },
                            ),
                            text: 'CARDS',
                          ),
                          Tab(
                            icon: Icon(Icons.how_to_vote, size: 20.h),
                            text: 'PICK',
                          ),
                          Tab(
                            icon: Icon(Icons.list, size: 20.h),
                            text: 'RECORD',
                          ),
                          Tab(
                            icon: Icon(
                              Icons.chat_bubble_outline_sharp,
                              size: 20.h,
                            ),
                            text: 'CHAT',
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: TabBarView(
                        physics: NeverScrollableScrollPhysics(),
                        controller: _tabController,
                        children: [
                          _renderFighterInfoScreen(state: state),
                          StreamFightEventScreen(tabController: _tabController),
                          state is StateData<StreamFightEventModel>
                              ? BetScreen(
                                betAvailable:
                                    state.data!.mainCardDateTimeInfo != null &&
                                    !CustomDateUtils.isBettingRestricted(
                                      state.data!.mainCardDateTimeInfo!.date,
                                    ),
                                tabController: _tabController,
                              )
                              : SizedBox.shrink(),
                          _renderBetHistoryScreen(state: state),
                          ChatRoom(user: widget.user, socket: socket),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _renderFighterInfoScreen({
    required StateBase<StreamFightEventModel> state,
  }) {
    if (state is! StateData) {
      return _renderNonDataState(state);
    }
    final ffe = _getCurrentOFirstFightEvent(
      state as StateData<StreamFightEventModel>,
    );
    return FighterInfoScreen(f1: (ffe).winner, f2: ffe.loser);
  }

  Widget _renderBetHistoryScreen({
    required StateBase<StreamFightEventModel> state,
  }) {
    if (state is! StateData) {
      return _renderNonDataState(state);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(selectedBetHistoryEventIdProvider.notifier)
          .update((s) => (state as StateData<StreamFightEventModel>).data!.id);
    });
    return StreamBetHistoryScreen(
      tabController: _tabController,
      userPoint: widget.user.point,
    );
  }

  Widget _header({required StateBase<StreamFightEventModel> state}) {
    if (state is! StateData) {
      return _renderNonDataState(state);
    }
    final ffe = _getCurrentOFirstFightEvent(
      state as StateData<StreamFightEventModel>,
    );
    int winnerRate = firstFighterCountToRate(
      first: ffe.firstFighterBetCount.toInt(),
      last: ffe.lastFighterBetCount.toInt(),
    );
    int loserRate = 100 - winnerRate;

    return Container(
      color: context.colors.surface,
      child: Column(
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: SvgPicture.asset(
                      'asset/img/component/stream_view_header_cage.svg',
                      fit: BoxFit.fitWidth,
                      colorFilter: ColorFilter.mode(
                        GREY_COLOR,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${CustomFightUtils.fightWeightClassMap[ffe.fightWeight] ?? ''} ${ffe.title ? '타이틀전' : '매치'}',
                      style: context.text.bodySmall?.copyWith(
                        fontSize: 28.sp,
                        fontFamily: 'Dalmation',
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Expanded(child: _renderCurrentFighterInfo(ffe)),
                  ],
                ),
              ],
            ),
          ),
          Row(
            children: [
              Expanded(
                flex: winnerRate,
                child: Container(
                  padding: EdgeInsets.only(left: 12.w),
                  color: RED_COLOR,
                  child: Text(
                    '$winnerRate%',
                    style: defaultTextStyle,
                    textAlign: TextAlign.left,
                  ),
                ),
              ),
              Expanded(
                flex: loserRate,
                child: Container(
                  padding: EdgeInsets.only(right: 12.w),
                  color: BLUE_COLOR,
                  child: Text(
                    '$loserRate%',
                    style: defaultTextStyle,
                    textAlign: TextAlign.end,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _renderCurrentFighterInfo(StreamFighterFightEventModel ffe) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final nameBarHeight = 28.h;
        final spacing = 4.h;
        final imageHeight = (constraints.maxHeight - nameBarHeight - spacing)
            .clamp(0.0, double.infinity);
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _renderHeaderFighterInfo(
              name:
                  ffe.winner.koreanName != null
                      ? ffe.winner.koreanName!
                      : ffe.winner.name,
              color: RED_COLOR,
              imageHeight: imageHeight,
              nameBarHeight: nameBarHeight,
            ),
            Text(
              'vs',
              style: context.text.bodyMedium?.copyWith(
                fontSize: 40.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            _renderHeaderFighterInfo(
              name:
                  ffe.loser.koreanName != null
                      ? ffe.loser.koreanName!
                      : ffe.loser.name,
              color: BLUE_COLOR,
              imageHeight: imageHeight,
              nameBarHeight: nameBarHeight,
            ),
          ],
        );
      },
    );
  }

  _renderHeaderFighterInfo({
    required String name,
    required Color color,
    required double imageHeight,
    required double nameBarHeight,
  }) {
    final imageWidth = 100.w;
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Image.asset(
          'asset/img/component/default-head.png',
          height: imageHeight,
          width: imageWidth,
          fit: BoxFit.fitHeight,
          color: context.colors.onSurface,
        ),
        SizedBox(height: 4.h),
        SizedBox(
          height: nameBarHeight,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: color, width: 2.0),
              color: context.colors.surface,
            ),
            child: SizedBox(
              width: imageWidth,
              child: Center(
                child: Text(
                  CustomFightUtils.extractLastName(name),
                  style: context.text.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// last : 아직 이벤트 시작하지 않은 경우
  StreamFighterFightEventModel _getCurrentOFirstFightEvent(
    StateData<StreamFightEventModel> state,
  ) {
    final fe = state.data!;
    return fe.fighterFightEvents.firstWhereOrNull(
          (e) => e.status == StreamFighterFightEventStatus.now,
        ) ??
        fe.fighterFightEvents.first;
  }

  Widget _renderNonDataState(StateBase<StreamFightEventModel> state) {
    if (state is StateLoading) {
      return CustomCircularProgressIndicator();
    }
    if (state is StateError) {
      return RetryButton(
        onRetry:
            () =>
                ref
                    .read(streamFightEventProvider.notifier)
                    .getCurrentFightEventInfo(),
      );
    }
    return SizedBox();
  }

  int firstFighterCountToRate({required int first, required int last}) {
    return first == 0 && last == 0
        ? 50
        : (first / (first + last) * 100).round();
  }
}
