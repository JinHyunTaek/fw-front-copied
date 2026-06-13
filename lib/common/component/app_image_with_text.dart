import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mma_flutter/main.dart';

class AppImageWithText extends StatelessWidget {
  final String text;

  const AppImageWithText({required this.text, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(top: 90.h, bottom: 26.h),
          child: SvgPicture.asset(
            context.isDark ?
            'asset/img/logo/fight_week_white.svg'
            : 'asset/img/logo/fight_week_black.svg',
            height: 57.h,
            width: 64.w,
          ),
        ),
        Text(
          text,
          style: TextStyle(
            color: context.colors.onSurface,
            fontWeight: FontWeight.w700,
            fontSize: 17.sp,
          ),
        ),
      ],
    );
  }
}
