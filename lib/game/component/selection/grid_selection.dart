import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mma_flutter/common/const/colors.dart';
import 'package:mma_flutter/main.dart';

class GridSelection extends StatelessWidget {
  final int? selectedAnswerIdx;
  final List<String> selections;
  final void Function(int) onTap;
  final bool showResult;
  final String correctAnswer;

  const GridSelection({
    required this.selectedAnswerIdx,
    required this.selections,
    required this.onTap,
    required this.showResult,
    required this.correctAnswer,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: MediaQuery
            .of(context)
            .size
            .width / 1.05,
      ),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 6.w,
          mainAxisSpacing: 6.h,
          childAspectRatio: 2.0,
        ),
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: selections.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              onTap(index);
            },
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: context.colors.surface,
                border: Border.all(color: _getBorderColor(index), width: 2.w),
                borderRadius: BorderRadius.circular(8.r),
              ),
              //
              child: Text(
                selections[index],
                style: context.text.bodyMedium?.copyWith(
                  fontSize: 18.sp,
                ),
                textAlign: TextAlign.center,
              ),
            ),);
        },
      ),
    );
  }

  Color _getBorderColor(int index) {
    if (!showResult) {
      return selectedAnswerIdx == index ? BLUE_COLOR : GREY_COLOR;
    }

    final isSelected = selectedAnswerIdx == index;
    final isCorrectAnswer = selections[index] == correctAnswer;

    if (isCorrectAnswer) return Colors.green;
    if (isSelected && !isCorrectAnswer) return Colors.red;

    return GREY_COLOR;
  }
}
