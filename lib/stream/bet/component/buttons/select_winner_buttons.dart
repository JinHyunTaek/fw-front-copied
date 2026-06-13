import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mma_flutter/common/const/colors.dart';
import 'package:mma_flutter/common/const/style.dart';
import 'package:mma_flutter/common/utils/fight_utils.dart';
import 'package:mma_flutter/stream/bet/model/selected_fight_model.dart';
import 'package:mma_flutter/stream/bet/provider/bet_card_provider.dart';

class SelectWinnerButtons extends ConsumerWidget {
  final SelectedFightModel fight;
  final int index;
  final SelectedBetCardModel card;
  final bool drawSelected;

  const SelectWinnerButtons({
    required this.fight,
    required this.index,
    required this.card,
    required this.drawSelected,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _nameButton(
          mainColor: RED_COLOR,
          myWinner: fight.redFighter,
          myLoser: fight.blueFighter,
          isLeft: true,
          ref: ref,
          ffeId: fight.fighterFightEventId,
        ),
        SizedBox(width: 4.w),
        _nameButton(
          mainColor: BLUE_COLOR,
          myWinner: fight.blueFighter,
          myLoser: fight.redFighter,
          isLeft: false,
          ref: ref,
          ffeId: fight.fighterFightEventId,
        ),
        SizedBox(width: 4.w),
        SizedBox(
          width: 57.w,
          child: _drawButton(ref: ref, mainColor: Color(0xff8a38f5)),
        ),
      ],
    );
  }

  Widget _nameButton({
    required Color mainColor,
    required FighterSelection myWinner,
    required FighterSelection myLoser,
    required bool isLeft,
    required WidgetRef ref,
    required int ffeId,
  }) {
    bool isSelected = false;
    if (isLeft) {
      isSelected = card.leftNameSelected == true;
    } else {
      isSelected = card.leftNameSelected == false;
    }

    return SizedBox(
      width: 150.w,
      child: ElevatedButton(
        onPressed: () {
          ref.read(betCardProvider.notifier).update((state) {
            final updated = [...state];
            final newCard = isSelected
                ? SelectedBetCardModel(ffeId: ffeId)
                : SelectedBetCardModel(ffeId: ffeId).copyWith(
                    newMyWinner: myWinner,
                    newMyLoser: myLoser,
                    newLeftNameSelected: isLeft,
                  );
            updated[index] = updated[index].copyWithCard(newCard);
            return updated;
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? mainColor : DARK_GREY_COLOR,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadiusGeometry.circular(8.r),
          ),
        ),
        child: Text(
          CustomFightUtils.extractLastName(myWinner.name),
          style: defaultTextStyle.copyWith(
            fontWeight: FontWeight.w700,
            color: isSelected ? null : mainColor,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  ElevatedButton _drawButton({
    required WidgetRef ref,
    required Color mainColor,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.zero,
        backgroundColor: drawSelected ? mainColor : DARK_GREY_COLOR,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      ),
      onPressed: () {
        ref.read(betCardProvider.notifier).update((state) {
          final updated = [...state];
          final prev = updated[index].card;
          final newCard = drawSelected
              ? SelectedBetCardModel(ffeId: prev.ffeId)
              : SelectedBetCardModel(ffeId: prev.ffeId, drawSelected: true);
          updated[index] = updated[index].copyWithCard(newCard);
          return updated;
        });
      },
      child: Text(
        '무승부',
        style: TextStyle(
          fontSize: 15.sp,
          fontWeight: FontWeight.w600,
          color: drawSelected ? WHITE_COLOR : mainColor,
        ),
      ),
    );
  }
}
