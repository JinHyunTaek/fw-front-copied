import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mma_flutter/common/const/colors.dart';
import 'package:mma_flutter/fighter/model/fighter_model.dart';
import 'package:mma_flutter/main.dart';

class SimpleFighterCard extends ConsumerWidget {
  final FighterModel fighter;

  const SimpleFighterCard({super.key, required this.fighter});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: 86.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(width: 1.w, color: GREY_COLOR),
        color: context.colors.surface,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 123.w,
            height: 77.h,
            child: Image.asset(
              'asset/img/component/default-head.png',
              color: context.colors.onSurface,
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _splitName(name: fighter.koreanName ?? fighter.name),
                style: context.text.bodyMedium?.copyWith(fontSize: 16.sp),
              ),
              SizedBox(height: 2.h),
              Text(
                '${fighter.record.win}-${fighter.record.loss}-${fighter.record.draw}',
                style: context.text.bodyMedium?.copyWith(
                  fontSize: 12.sp,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _splitName({required String name}) {
    if (name.contains(' ')) {
      final names = name.split(' ');
      return '${names[0]}\n${names.sublist(1).join(' ')}';
    }
    return name;
  }
}
