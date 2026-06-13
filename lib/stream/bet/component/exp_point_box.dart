import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:mma_flutter/common/component/point_with_icon.dart';
import 'package:mma_flutter/common/const/colors.dart';
import 'package:mma_flutter/main.dart';

class ExpPointBox extends StatelessWidget {
  final bool? succeed;
  final int exp;

  const ExpPointBox({this.succeed, required this.exp, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 21.h),
      child: Column(
        children: [
          _renderDividerWithLabel(
            context,
            label: succeed == null ? '예측 성공 시 획득 가능 EXP' : '획득 EXP',
          ),
          Container(
            height: 35.h,
            width: 276.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              color: context.colors.surface,
              border: Border.all(color: GREY_COLOR, width: 2.w),
            ),
            child: Center(
              child: Text(
                '${NumberFormat('#,###').format(exp)} EXP',
                style: context.text.bodySmall?.copyWith(fontSize: 12.sp),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _renderDividerWithLabel(
    BuildContext context, {
    required String label,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: Row(
        children: [
          Expanded(child: Divider(thickness: 1, color: DARK_GREY_COLOR)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
            child: Text(
              label,
              style: context.text.bodyMedium?.copyWith(fontSize: 12.sp),
            ),
          ),
          Expanded(child: Divider(thickness: 1, color: DARK_GREY_COLOR)),
        ],
      ),
    );
  }
}
