import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mma_flutter/common/const/colors.dart';
import 'package:mma_flutter/common/const/style.dart';
import 'package:mma_flutter/common/model/base_state_model.dart';
import 'package:mma_flutter/common/utils/fight_utils.dart';
import 'package:mma_flutter/main.dart';
import 'package:mma_flutter/stream/bet/component/bet_point_box.dart';
import 'package:mma_flutter/stream/bet/component/exp_point_box.dart';
import 'package:mma_flutter/stream/bet/model/bet_request_model.dart';
import 'package:mma_flutter/stream/bet/provider/bet_card_provider.dart';
import 'package:mma_flutter/stream/bet/provider/bet_history_provider.dart';
import 'package:mma_flutter/stream/bet/utils/prediction_reward_policy.dart';
import 'package:mma_flutter/stream/bet/utils/profit_calculator.dart';
import 'package:mma_flutter/stream/model/stream_fight_event_model.dart';
import 'package:mma_flutter/stream/provider/stream_fight_event_provider.dart';

class BetAlertDialog extends ConsumerStatefulWidget {
  final TabController tabController;

  const BetAlertDialog({required this.tabController, super.key});

  @override
  ConsumerState<BetAlertDialog> createState() => _BetAlertDialogState();
}

class _BetAlertDialogState extends ConsumerState<BetAlertDialog> {
  bool _isSubmitting = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bets = ref.read(betCardProvider);
    final cards = bets.map((s) => s.card).toList();
    final totalEntryFee = PredictionRewardPolicy.entryFee * cards.length;

    return AlertDialog(
      backgroundColor: context.colors.box,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.circular(8.r),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: cards.length > 1 ? 248.h : 124.h,
                child: RawScrollbar(
                  controller: _scrollController,
                  thumbVisibility: true,
                  thumbColor: BLUE_COLOR,
                  trackColor: BLACK_COLOR,
                  radius: Radius.circular(8.r),
                  trackVisibility: true,
                  child: Padding(
                    padding: EdgeInsets.only(left: 16.w, right: 16.w, top: 12.h),
                    child: _renderBetCards(bets: bets, ref: ref),
                  ),
                ),
              ),
              BetPointBox(point: totalEntryFee),
              ExpPointBox(
                exp: ProfitCalculator.calculateTotalProfit(betCards: cards),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 20.h),
                child: Center(
                  child: Text('예측하시겠습니까?', style: context.text.bodyMedium),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        disabledBackgroundColor: GREY_COLOR,
                        backgroundColor: BLACK_COLOR,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadiusGeometry.circular(8.r),
                        ),
                      ),
                      onPressed: _isSubmitting
                          ? null
                          : () => Navigator.of(context).pop(),
                      child: Text(
                        '취소',
                        style: defaultTextStyle.copyWith(fontSize: 12.sp),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSubmitting
                          ? null
                          : () async {
                              setState(() {
                                _isSubmitting = true;
                              });
                              final singleBets = bets.map((s) {
                                final WinMethodForBet? winMethodForBet =
                                    s.card.winMethodIndex != null
                                    ? WinMethodForBet
                                          .values[s.card.winMethodIndex!]
                                    : null;
                                int? finishRound = s.card.finishRoundIndex != null
                                    ? s.card.finishRoundIndex! + 1
                                    : null;
                                if (winMethodForBet == WinMethodForBet.dec) {
                                  finishRound = null;
                                }
                                return SingleBetCardRequestModel(
                                  fighterFightEventId: s.card.ffeId,
                                  betPrediction: BetPredictionModel(
                                    myWinnerId: s.card.myWinner?.id,
                                    myLoserId: s.card.myLoser?.id,
                                    draw: s.card.drawSelected,
                                    winMethod: winMethodForBet,
                                    finishRound: finishRound,
                                    isFotN: s.card.isFotNSelected,
                                    isPotN: s.card.isPotNSelected,
                                  ),
                                );
                              }).toList();
                              final res = await ref.read(
                                betCreateFutureProvider(
                                  BetRequestModel(
                                    seedPoint: totalEntryFee,
                                    eventId:
                                        (ref.read(streamFightEventProvider)
                                                as StateData<
                                                  StreamFightEventModel
                                                >)
                                            .data!
                                            .id,
                                    singleBetCards: singleBets,
                                  ),
                                ).future,
                              );
                              if (res != null) {
                                ScaffoldMessenger.of(
                                  context,
                                ).showSnackBar(SnackBar(content: Text(res)));
                              }
                              Navigator.of(context).pop();
                              ref.invalidate(betCardProvider);
                              widget.tabController.animateTo(3);
                            },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        backgroundColor: BLUE_COLOR,
                        disabledBackgroundColor: GREY_COLOR,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadiusGeometry.circular(8.r),
                        ),
                      ),
                      child: Text(
                        '예측하기',
                        style: defaultTextStyle.copyWith(fontSize: 12.sp),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _renderBetCards({
    required WidgetRef ref,
    required List<BetState> bets,
  }) {
    return ListView.separated(
      controller: _scrollController,
      itemBuilder: (context, index) {
        final card = bets[index].card;
        final fight = bets[index].fight;
        if (card.drawSelected) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _renderLabelWithValue(
                label: 'Card ${index + 1}',
                value:
                    '${CustomFightUtils.extractLastName(fight.redFighter.name)} vs ${CustomFightUtils.extractLastName(fight.blueFighter.name)}',
              ),
              _renderLabelWithValue(label: '예측', value: '무승부'),
              if (card.isFotNSelected)
                Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: Text('파이트 오브 더 나잇', style: context.text.bodySmall),
                ),
              if (card.isPotNSelected)
                Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: Text('퍼포먼스 오브 더 나잇', style: context.text.bodySmall),
                ),
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _renderLabelWithValue(
              label: 'Card ${index + 1}',
              value:
                  '${CustomFightUtils.extractLastName(card.myWinner!.name)} vs ${CustomFightUtils.extractLastName(card.myLoser!.name)}',
            ),
            _renderLabelWithValue(
              label: '예측 승자',
              value: CustomFightUtils.extractLastName(card.myWinner!.name),
            ),
            if (card.winMethodIndex != null)
              _renderLabelWithValue(
                label: '승리 방식',
                value: WinMethodForBet.values[card.winMethodIndex!].label,
              ),
            if (card.finishRoundIndex != null &&
                (card.winMethodIndex == null ||
                    WinMethodForBet.values[card.winMethodIndex!] !=
                        WinMethodForBet.dec))
              _renderLabelWithValue(
                label: '피니시 라운드',
                value: '${card.finishRoundIndex! + 1}R',
              ),
            if (card.isFotNSelected)
              Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: Text('파이트 오브 더 나잇', style: context.text.bodySmall),
              ),
            if (card.isPotNSelected)
              Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: Text('퍼포먼스 오브 더 나잇', style: context.text.bodySmall),
              ),
          ],
        );
      },
      separatorBuilder: (BuildContext context, int index) {
        return Column(
          children: [
            Container(height: 2.h, width: 226.w, color: context.colors.onBox),
            SizedBox(height: 14.h),
          ],
        );
      },
      itemCount: bets.length,
    );
  }

  Widget _renderLabelWithValue({required String label, required String value}) {
    return Column(
      children: [
        Row(
          children: [
            SizedBox(
              width: 50.w,
              child: Text(
                label,
                style: defaultTextStyle.copyWith(
                  color: context.colors.subText,
                  fontSize: 12.sp,
                ),
              ),
            ),
            SizedBox(width: 16.w),
            SizedBox(
              width: 160.w,
              child: Text(
                value,
                style: context.text.bodyMedium?.copyWith(
                  fontSize: label.contains('Card') ? 15.sp : 13.sp,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
      ],
    );
  }
}
