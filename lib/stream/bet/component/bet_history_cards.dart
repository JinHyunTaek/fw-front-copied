import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mma_flutter/common/const/colors.dart';
import 'package:mma_flutter/common/const/style.dart';
import 'package:mma_flutter/common/model/base_state_model.dart';
import 'package:mma_flutter/main.dart';
import 'package:mma_flutter/stream/bet/component/bet_history_card.dart';
import 'package:mma_flutter/stream/bet/component/bet_point_box.dart';
import 'package:mma_flutter/stream/bet/component/exp_point_box.dart';
import 'package:mma_flutter/stream/bet/model/bet_response_model.dart';
import 'package:mma_flutter/stream/bet/provider/bet_card_provider.dart';
import 'package:mma_flutter/stream/bet/provider/bet_history_provider.dart';
import 'package:mma_flutter/stream/bet/utils/profit_calculator.dart';
import 'package:mma_flutter/stream/model/stream_fight_event_model.dart';
import 'package:mma_flutter/stream/provider/stream_fight_event_provider.dart';

/**
 * for user ranking detail & stream bet history screen
 */
class BetHistoryCards extends ConsumerWidget {
  // eventId == null || userPoint == null -> UserRecentBetScreen
  final int? eventId;
  final int? userPoint;
  final TabController? tabController;
  final String eventName;
  final BetResponseModel betResponse;

  const BetHistoryCards({
    this.userPoint,
    this.tabController,
    required this.eventId,
    required this.eventName,
    required this.betResponse,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentEventId = ref.read(currentEventIdProvider);
    log('$betResponse');

    return Container(
      color: context.colors.box,
      child: Center(
        child: SizedBox(
          width: 387.w,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (eventId != null)
                Padding(
                  padding: EdgeInsets.only(
                    top: 30.h,
                    bottom: 20.h,
                    left: 10.w,
                    right: 10.w,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onTap:
                            eventId! > 1
                                ? () {
                                  moveBetHistory(
                                    ref: ref,
                                    eventId: eventId!,
                                    isLeft: true,
                                  );
                                }
                                : null,
                        child: Icon(
                          Icons.keyboard_arrow_left,
                          color:
                              eventId! > 1
                                  ? context.colors.onSurface
                                  : GREY_COLOR,
                        ),
                      ),
                      SizedBox(
                        width: 300.w,
                        child: Center(
                          child: Text(
                            _renderShortEventName(eventName),
                            style: context.text.bodyMedium?.copyWith(
                              fontSize: 17.sp,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap:
                            eventId! <
                                    (ref.read(streamFightEventProvider)
                                            as StateData<StreamFightEventModel>)
                                        .data!
                                        .id
                                ? () {
                                  moveBetHistory(
                                    ref: ref,
                                    eventId: eventId!,
                                    isLeft: false,
                                  );
                                }
                                : null,
                        child: Icon(
                          Icons.keyboard_arrow_right,
                          color:
                              currentEventId != null &&
                                      currentEventId == eventId!
                                  ? GREY_COLOR
                                  : context.colors.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              if (eventId == null) SizedBox(height: 12.h),
              if (betResponse.singleBets.isEmpty)
                Center(
                  child: Text('예측 기록이 없습니다.', style: context.text.bodyMedium),
                )
              else
                Expanded(
                  child: ListView.separated(
                    itemBuilder: (context, index) {
                      final currentBet = betResponse.singleBets[index];
                      final isRefunded = currentBet.isRefunded;
                      log('$isRefunded');
                      final isSucceed = currentBet.succeed;
                      // upcoming events bet
                      if (isSucceed == null && !isRefunded) {
                        return Column(
                          children: [
                            _renderDateTime(currentBet),
                            _renderSingleBet(
                              succeed: isSucceed,
                              singleBet: currentBet,
                              eventId: eventId,
                              ref: ref,
                              context: context,
                            ),
                          ],
                        );
                      } else {
                        return Column(
                          children: [
                            if (eventId != null) _renderDateTime(currentBet),
                            Stack(
                              children: [
                                _renderSingleBet(
                                  succeed: isSucceed,
                                  singleBet: currentBet,
                                  eventId: eventId,
                                  ref: ref,
                                  context: context,
                                ),
                                Positioned.fill(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(
                                        alpha: 0.5,
                                      ),
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                  ),
                                ),
                                Positioned.fill(
                                  child: Center(
                                    child:
                                        !isSucceed!
                                            ? _renderIfSucceed(
                                              context,
                                              isRefunded: isRefunded,
                                              isSucceed: isSucceed,
                                            )
                                            : Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                _renderIfSucceed(
                                                  context,
                                                  isRefunded: isRefunded,
                                                  isSucceed: isSucceed,
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                    top: 4.h,
                                                  ),
                                                  child: Container(
                                                    width: 200.w,
                                                    height: 35.h,
                                                    decoration: ShapeDecoration(
                                                      gradient: LinearGradient(
                                                        begin: Alignment(
                                                          0.00,
                                                          0.50,
                                                        ),
                                                        end: Alignment(
                                                          1.00,
                                                          0.50,
                                                        ),
                                                        colors: [
                                                          RED_COLOR,
                                                          BLUE_COLOR,
                                                        ],
                                                      ),
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              8,
                                                            ),
                                                      ),
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                        '${calculatePointFromSingleBet(singleBet: currentBet)} EXP',
                                                        style: TextStyle(
                                                          color: WHITE_COLOR,
                                                          fontSize: 12.sp,
                                                          fontFamily: 'Roboto',
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      }
                    },
                    separatorBuilder: (context, index) {
                      return SizedBox(height: 16.h);
                    },
                    itemCount: betResponse.singleBets.length,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _renderIfSucceed(
    BuildContext context, {
    required bool isRefunded,
    required bool isSucceed,
  }) {
    return Text(
      isRefunded
          ? '취소된 카드\n참가 포인트 환불 완료'
          : isSucceed
          ? '예측 성공'
          : '예측 실패',
      style: context.text.bodyMedium?.copyWith(
        fontSize: 28.sp,
        fontWeight: FontWeight.w600,
        color: WHITE_COLOR,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _renderSingleBet({
    required bool? succeed,
    required SingleBetResponseModel singleBet,
    required int? eventId,
    required WidgetRef ref,
    required BuildContext context,
  }) {
    final currentEventId = ref.read(currentEventIdProvider);
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Column(
            children: [
              ...List.generate(singleBet.betCards.length, (index) {
                return BetHistoryCard(betResponse: singleBet.betCards[index]);
              }),
              BetPointBox(point: singleBet.seedPoint),
              ExpPointBox(
                succeed: succeed,
                exp:
                    (succeed != null && !succeed)
                        ? 0
                        : calculatePointFromSingleBet(singleBet: singleBet),
              ),
              SizedBox(height: 21.h),
              if (currentEventId != null &&
                  eventId != null &&
                  currentEventId == eventId)
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.info_outline, size: 11, color: GREY_COLOR),
                        Text(
                          ' 예측 취소는 금요일 자정까지 최대 3회까지 가능합니다.',
                          style: context.text.bodySmall?.copyWith(
                            color: GREY_COLOR,
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 3.h),
                    SizedBox(
                      width: 129.w,
                      height: 34.h,
                      child: ElevatedButton(
                        onPressed: () async {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                backgroundColor: DARK_GREY_COLOR,
                                title: Text(
                                  '예측을 취소하시겠습니까?',
                                  style: defaultTextStyle.copyWith(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                content: Text(
                                  '\n예측을 취소할 경우, 참가 포인트는 환불됩니다.',
                                  style: defaultTextStyle.copyWith(
                                    fontSize: 12.sp,
                                  ),
                                ),
                                actions: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          style: ElevatedButton.styleFrom(
                                            padding: EdgeInsets.zero,
                                            backgroundColor: BLACK_COLOR,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadiusGeometry.circular(
                                                    8.r,
                                                  ),
                                            ),
                                          ),
                                          child: Text(
                                            '닫기',
                                            style: defaultTextStyle,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 12.w),
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () async {
                                            Navigator.of(context).pop();
                                            final res = await ref
                                                .read(
                                                  betHistoryProvider(
                                                    eventId,
                                                  ).notifier,
                                                )
                                                .deleteBet(
                                                  eventId: eventId,
                                                  seedPoint:
                                                      singleBet.seedPoint,
                                                  betId: singleBet.betId,
                                                  userPoint: userPoint!,
                                                );
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(content: Text(res ?? '예측 취소가 완료되었습니다.')),
                                              );
                                            }
                                          },
                                          style: ElevatedButton.styleFrom(
                                            padding: EdgeInsets.zero,
                                            backgroundColor: BLUE_COLOR,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadiusGeometry.circular(
                                                    8.r,
                                                  ),
                                            ),
                                          ),
                                          child: Text(
                                            '예측 취소하기',
                                            style: defaultTextStyle,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          backgroundColor: RED_COLOR,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadiusGeometry.circular(8.r),
                          ),
                        ),
                        child: Text(
                          '예측 취소하기',
                          style: defaultTextStyle.copyWith(fontSize: 14.sp),
                        ),
                      ),
                    ),
                  ],
                ),
              SizedBox(height: 12.h),
            ],
          ),
        ),
      ],
    );
  }

  int calculatePointFromSingleBet({required SingleBetResponseModel singleBet}) {
    return ProfitCalculator.calculateTotalProfit(
      betCards:
          singleBet.betCards
              .map(
                (e) =>
                    SelectedBetCardModel.fromSingleBetCardResponseToCalculateProfit(
                      bet: e,
                    ),
              )
              .toList(),
    );
  }

  Widget _renderDateTime(SingleBetResponseModel singleBet) {
    final dateTime = singleBet.createdDateTime;
    final year = dateTime.year;
    final month = dateTime.month;
    final day = dateTime.day;
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    String dateTimeStr = '$year년 $month월 $day일 $hour:$minute';
    return Align(
      alignment: Alignment.topLeft,
      child: Text(
        dateTimeStr,
        style: TextStyle(color: GREY_COLOR, fontSize: 12.sp),
      ),
    );
  }

  void moveBetHistory({
    required WidgetRef ref,
    required int eventId,
    required bool isLeft,
  }) {
    ref
        .read(betHistoryProvider(eventId + (isLeft ? -1 : 1)).notifier)
        .getBetHistory();
    ref
        .read(selectedBetHistoryEventIdProvider.notifier)
        .update((s) => eventId + (isLeft ? -1 : 1));
    tabController!.animateTo(3);
  }

  String _renderShortEventName(String eventName) {
    String keyword = 'UFC Fight Night';
    return eventName.contains(keyword)
        ? eventName.replaceAll(keyword, 'UFN')
        : eventName;
  }
}
