import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:mma_flutter/main.dart';

class PointWithIcon extends StatelessWidget {
  final int point;
  final double? fontSize;
  final double? distance;
  final double? iconSize;
  final Color? color;

  const PointWithIcon({
    required this.point,
    this.color,
    this.fontSize,
    this.iconSize,
    this.distance,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final formatted = NumberFormat('#,###').format(point);
    return SizedBox(
      child: RichText(
        text: TextSpan(
          children: [
            WidgetSpan(
              child: SvgPicture.asset(
                'asset/img/icon/point_black.svg',
                colorFilter: ColorFilter.mode(
                  color ?? context.colors.onSurface,
                  BlendMode.srcIn,
                ),
                height: iconSize ?? 16,
                width: iconSize ?? 16,
              ),
            ),
            WidgetSpan(child: SizedBox(width: distance ?? 5.w)),
            TextSpan(
              text: formatted.toString(),
              style: context.text.bodyMedium!.copyWith(
                fontSize: fontSize ?? 14.sp,
                color: color ?? context.colors.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
