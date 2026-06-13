import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mma_flutter/common/const/colors.dart';
import 'package:mma_flutter/common/const/style.dart';
import 'package:mma_flutter/game/model/name_game_response_model.dart';
import 'package:mma_flutter/main.dart';

/**
 * 현재 퀴즈의 선택지 (총 4개의 항목) 렌더링
 */
class NonGridSelection extends StatelessWidget {
  final int? selectedAnswerIdx;
  final List<String> selections;
  final bool showResult;
  final String correctAnswer;
  final void Function(int) onTap;

  const NonGridSelection({
    required this.selectedAnswerIdx,
    required this.selections,
    required this.correctAnswer,
    required this.showResult,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ...List.generate(selections.length, (index) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 7.5.h, horizontal: 16.w),
            child: GestureDetector(
              onTap: () {
                onTap(index);
              },
              child: Container(
                constraints: BoxConstraints(minHeight: 62.h, minWidth: 370.w),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: context.colors.surface,
                  border: Border.all(color: _getBorderColor(index), width: 2.w),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  selections[index],
                  style: context.text.bodyMedium?.copyWith(fontSize: 18.sp),
                ),
              ),
            ),
          );
        }),
      ],
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
