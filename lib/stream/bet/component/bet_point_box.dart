import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mma_flutter/common/component/point_with_icon.dart';
import 'package:mma_flutter/common/const/colors.dart';
import 'package:mma_flutter/main.dart';

class BetPointBox extends StatelessWidget {
  final int point;

  const BetPointBox({required this.point, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 21.h),
      child: Column(
        children: [
          _renderDividerWithLabel(context, label: '참가 포인트'),
          Container(
            decoration: BoxDecoration(
              color: DARK_GREY_COLOR,
              borderRadius: BorderRadius.circular(8.r),
            ),
            height: 25.h,
            width: 132.w,
            child: Center(
              child: Text(
                point.toString(),
                style: TextStyle(color: WHITE_COLOR),
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
          Expanded(child: Divider(thickness: 1, color: context.colors.box)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
            child: Text(
              label,
              style: context.text.bodyMedium?.copyWith(fontSize: 12.sp),
            ),
          ),
          Expanded(child: Divider(thickness: 1, color: context.colors.box)),
        ],
      ),
    );
  }
}
