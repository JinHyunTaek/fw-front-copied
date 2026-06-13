import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mma_flutter/common/const/colors.dart';
import 'package:mma_flutter/common/const/style.dart';
import 'package:mma_flutter/stream/bet/model/bet_request_model.dart';
import 'package:mma_flutter/stream/bet/utils/button_color_renderer.dart';

/**
 * used for making bets & view history
 */
class WinMethodButtons extends StatelessWidget {
  final Color mainColor;
  final int? selectedWinMethodIndex;
  final void Function(int)? onPressed;

  const WinMethodButtons({
    required this.mainColor,
    required this.selectedWinMethodIndex,
    this.onPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 365.w,
      child: SizedBox(
        height: 28.h,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ...WinMethodForBet.values.mapIndexed((index, e) {
              final backGroundColor = renderBetButtonBackGroundColor(
                index: index,
                mainColor: mainColor,
                selectedIndex: selectedWinMethodIndex,
              );
              return SizedBox(
                width: 115.w,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    backgroundColor: backGroundColor,
                    disabledBackgroundColor: backGroundColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadiusGeometry.circular(8.0),
                    ),
                  ),
                  onPressed:
                      onPressed != null
                          ? () {
                            onPressed!(index);
                          }
                          : null,
                  child: Text(
                    e.label,
                    style: defaultTextStyle.copyWith(
                      fontSize: 12.sp,
                      color: selectedWinMethodIndex == index ? WHITE_COLOR : GREY_COLOR
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
