import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mma_flutter/common/const/colors.dart';
import 'package:mma_flutter/fighter/model/fighter_model.dart';
import 'package:mma_flutter/fighter/utils/fighter_utils.dart';
import 'package:mma_flutter/main.dart';

class FighterFightEventNameVersusName extends StatelessWidget {
  final FighterModel winner;
  final FighterModel loser;
  final bool versus;

  const FighterFightEventNameVersusName({
    required this.winner,
    required this.loser,
    this.versus = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 362.w,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _renderName(
            context,
            name: winner.koreanName ?? winner.name,
            borderColor: RED_COLOR,
          ),
          if (versus)
            Text(
              'vs',
              style: context.text.bodyMedium?.copyWith(fontSize: 16.sp),
            ),
          _renderName(
            context,
            name: loser.koreanName ?? loser.name,
            borderColor: BLUE_COLOR,
          ),
        ],
      ),
    );
  }

  _renderName(
    BuildContext context, {
    required String name,
    required Color borderColor,
  }) {
    final names = FighterUtils.splitFirstAndLastName(name);
    return Container( 
      width: 162.w,
      padding: EdgeInsets.symmetric(vertical: 3.h, horizontal: 12.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: borderColor, width: 2.w),
        color: context.colors.surface,
      ),
      child: Text(
        '${names[0]}\n${names[1]}',
        style: TextStyle(
          fontWeight: FontWeight.w700,
          color: context.colors.onSurface,
          fontSize: 15.sp,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

}
