import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mma_flutter/common/const/colors.dart';
import 'package:mma_flutter/common/utils/fight_utils.dart';
import 'package:mma_flutter/main.dart';
import 'package:mma_flutter/stream/bet/component/buttons/round_buttons.dart';
import 'package:mma_flutter/stream/bet/component/buttons/select_winner_buttons.dart';
import 'package:mma_flutter/stream/bet/component/buttons/win_method_buttons.dart';
import 'package:mma_flutter/stream/bet/component/buttons/x_of_the_night_button.dart';
import 'package:mma_flutter/stream/bet/model/bet_request_model.dart';
import 'package:mma_flutter/stream/bet/provider/bet_card_provider.dart';
import 'package:mma_flutter/user/model/user_model.dart';

class BetCreateCard extends ConsumerWidget {
  final BetState betState;
  final UserModel user;
  final int index;

  const BetCreateCard({
    required this.betState,
    required this.user,
    required this.index,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final card = ref.watch(betCardProvider)[index].card;
    final fight = betState.fight;

    final nameSelected = card.myWinner != null && card.leftNameSelected != null;
    log('$nameSelected');
    final drawSelected = card.drawSelected;
    final isFotNSelected = card.isFotNSelected;
    final isPotNSelected = card.isPotNSelected;
    final winMethodIndex = card.winMethodIndex;

    return Center(
      child: Container(
        width: 387.w,
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 12.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 16.w),
                    child: SizedBox(
                      width: 220.w,
                      child: Text(
                        '${CustomFightUtils.extractLastName(fight.redFighter.name)} vs ${CustomFightUtils.extractLastName(fight.blueFighter.name)}',
                        style: context.text.bodyMedium?.copyWith(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 100.w,
                    child: Text(
                      '${CustomFightUtils.fightWeightClassMap[fight.fightWeight]} ${fight.isTitle ? '타이틀전' : '매치'}',
                      style: context.text.bodyMedium?.copyWith(
                        color: context.colors.subText,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      ref
                          .read(betCardProvider.notifier)
                          .update(
                            (state) =>
                                state
                                    .where(
                                      (s) =>
                                          s.fight.fighterFightEventId !=
                                          fight.fighterFightEventId,
                                    )
                                    .toList(),
                          );
                    },
                    child: Padding(
                      padding: EdgeInsets.only(right: 8.w),
                      child: Icon(
                        FontAwesomeIcons.x,
                        color: context.colors.onSurface,
                        size: 15.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 11.h),
              child: SizedBox(
                width: 365.w,
                height: 28.h,
                child: SelectWinnerButtons(
                  fight: fight,
                  index: index,
                  card: card,
                  drawSelected: drawSelected,
                ),
              ),
            ),
            if (nameSelected && !drawSelected)
              Padding(
                padding: EdgeInsets.only(top: 11.h),
                child: _winMethodButtons(
                  leftNameSelected: card.leftNameSelected!,
                  ref: ref,
                  selectedWinMethodIndex: card.winMethodIndex,
                ),
              ),
            if (nameSelected &&
                !drawSelected &&
                (winMethodIndex == null ||
                    WinMethodForBet.values[winMethodIndex] !=
                        WinMethodForBet.dec))
              Padding(
                padding: EdgeInsets.only(top: 11.h),
                child: _selectWhichRoundToFinish(
                  isFiveRound: fight.isFiveRound,
                  leftNameSelected: card.leftNameSelected!,
                  selectedFinishRoundIndex: card.finishRoundIndex,
                  ref: ref,
                ),
              ),
            if (drawSelected || nameSelected)
              Padding(
                padding: EdgeInsets.only(top: 11.h),
                child: XOfTheNightButton(
                  index: index,
                  mainColor:
                      drawSelected
                          ? Color(0xff8a38f5)
                          : card.leftNameSelected!
                          ? RED_COLOR
                          : BLUE_COLOR,
                  selected: isFotNSelected,
                  isFotN: true,
                ),
              ),
            if (drawSelected || nameSelected)
              Padding(
                padding: EdgeInsets.only(top: 11.h),
                child: XOfTheNightButton(
                  index: index,
                  mainColor:
                      drawSelected
                          ? Color(0xff8a38f5)
                          : card.leftNameSelected!
                          ? RED_COLOR
                          : BLUE_COLOR,
                  selected: isPotNSelected,
                  isFotN: false,
                ),
              ),
            SizedBox(height: 12.h),
          ],
        ),
      ),
    );
  }

  Widget _winMethodButtons({
    required bool leftNameSelected,
    required WidgetRef ref,
    required int? selectedWinMethodIndex,
  }) {
    final mainColor = leftNameSelected ? RED_COLOR : BLUE_COLOR;
    return WinMethodButtons(
      mainColor: mainColor,
      selectedWinMethodIndex: selectedWinMethodIndex,
      onPressed: (winMethodIndex) {
        ref.read(betCardProvider.notifier).update((state) {
          final updated = [...state];
          final prev = updated[index].card;
          final newCard =
              prev.winMethodIndex == winMethodIndex
                  ? SelectedBetCardModel(
                    ffeId: prev.ffeId,
                    myWinner: prev.myWinner,
                    myLoser: prev.myLoser,
                    leftNameSelected: prev.leftNameSelected,
                  )
                  : prev.copyWith(
                    newWinMethodIndex: winMethodIndex,
                  );
          updated[index] = updated[index].copyWithCard(newCard);
          return updated;
        });
      },
    );
  }

  Widget _selectWhichRoundToFinish({
    required bool isFiveRound,
    required bool leftNameSelected,
    required int? selectedFinishRoundIndex,
    required WidgetRef ref,
  }) {
    final mainColor = leftNameSelected ? RED_COLOR : BLUE_COLOR;
    return RoundButtons(
      isFiveRound: isFiveRound,
      selectedFinishRoundIndex: selectedFinishRoundIndex,
      onPressed: (finishRoundIndex) {
        ref.read(betCardProvider.notifier).update((state) {
          final updated = [...state];
          final prev = updated[index].card;
          final newCard =
              prev.finishRoundIndex != null && prev.finishRoundIndex == finishRoundIndex
                  ? SelectedBetCardModel(
                    ffeId: prev.ffeId,
                    myWinner: prev.myWinner,
                    myLoser: prev.myLoser,
                    leftNameSelected: prev.leftNameSelected,
                    winMethodIndex: prev.winMethodIndex,
                  )
                  : prev.copyWith(newFinishRoundIndex: finishRoundIndex);
          updated[index] = updated[index].copyWithCard(newCard);
          return updated;
        });
      },
      mainColor: mainColor,
    );
  }
}
