import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mma_flutter/common/const/colors.dart';
import 'package:mma_flutter/common/const/style.dart';
import 'package:mma_flutter/stream/bet/utils/button_color_renderer.dart';

/**
 * used for making bets & view history
 */
class RoundButtons extends StatelessWidget {
  final bool isFiveRound;
  final int? selectedFinishRoundIndex;
  final Color mainColor;
  final void Function(int)? onPressed;

  const RoundButtons({
    required this.isFiveRound,
    required this.selectedFinishRoundIndex,
    this.onPressed,
    required this.mainColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 365.w,
      height: 28.h,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ...List.generate(isFiveRound ? 5 : 3, (index) {
            final backGroundColor = renderBetButtonBackGroundColor(
              index: index,
              mainColor: mainColor,
              selectedIndex: selectedFinishRoundIndex,
            );

            return SizedBox(
              width: !isFiveRound ? 115.w : null,
              child: ElevatedButton(
                onPressed:
                    onPressed != null
                        ? () {
                          onPressed!(index);
                        }
                        : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: backGroundColor,
                  disabledBackgroundColor: backGroundColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusGeometry.circular(8.r),
                  ),
                ),
                child: Text(
                  '${index + 1}R',
                  style: defaultTextStyle.copyWith(
                    fontSize: 12.sp,
                    color: selectedFinishRoundIndex == index ? WHITE_COLOR : GREY_COLOR
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
