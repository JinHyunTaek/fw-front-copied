import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mma_flutter/common/const/colors.dart';
import 'package:mma_flutter/common/const/style.dart';
import 'package:mma_flutter/stream/bet/provider/bet_card_provider.dart';

class XOfTheNightButton extends ConsumerWidget {
  final int index;
  final Color mainColor;
  final bool selected;
  final bool isFotN;

  const XOfTheNightButton({
    super.key,
    required this.mainColor,
    required this.index,
    required this.selected,
    required this.isFotN,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: 365.w,
      height: 28.h,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          backgroundColor: selected ? mainColor : DARK_GREY_COLOR,
          disabledBackgroundColor: mainColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
        onPressed:
            index == -1
                ? null
                : () {
                  ref.read(betCardProvider.notifier).update((state) {
                    final updated = [...state];
                    final prev = updated[index].card;
                    final newCard = prev.copyWith(
                      newIsFotN: isFotN ? !selected : prev.isFotNSelected,
                      newIsPotN: !isFotN ? !selected : prev.isPotNSelected,
                    );
                    updated[index] = updated[index].copyWithCard(newCard);
                    return updated;
                  });
                },
        child: Text(
          renderLabel(),
          style: defaultTextStyle.copyWith(fontSize: 12.sp, color: WHITE_COLOR),
        ),
      ),
    );
  }

  String renderLabel() {
    return isFotN ? '파이트 오브 더 나잇' : '퍼포먼스 오브 더 나잇';
  }
}
