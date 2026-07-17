import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:mma_flutter/common/const/colors.dart';
import 'package:mma_flutter/common/const/style.dart';
import 'package:mma_flutter/event/common/screen/active_event_screen.dart';
import 'package:mma_flutter/event/promotion/screen/promotion_detail_screen.dart';
import 'package:mma_flutter/home/model/home_promotion_model.dart';
import 'package:mma_flutter/main.dart';

class HomePromotionBanner extends StatelessWidget {
  final HomePromotionDto homePromotionModel;

  const HomePromotionBanner({required this.homePromotionModel, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58.h,
      width: 362.w,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: context.isDark ? EVENT_CARD_COLOR : context.colors.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: WHITE_COLOR.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.55),
            blurRadius: 16.r,
            offset: Offset(0, 6.h),
          ),
        ],
      ),
      child: Stack(
        children: [
          // 좌측 빨간 accent bar
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(width: 3.w, color: RED_COLOR),
          ),
          Padding(
            padding: EdgeInsets.only(
              left: 12.w,
              right: 14.w,
              top: 9.h,
              bottom: 9.h,
            ),
            child: Row(
              children: [
                Container(
                  width: 40.w,
                  height: 40.h,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: RED_COLOR.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text('🎁', style: TextStyle(fontSize: 20.sp)),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        homePromotionModel.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.text.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 14.sp,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        '${_leftDate(homePromotionModel.endDate)} · 예측 시 자동 응모 · ${homePromotionModel.maxWinnerCount}명',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.text.bodySmall?.copyWith(
                          color: context.colors.subText,
                          fontSize: 10.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 12.w),
                ElevatedButton(
                  onPressed: () {
                    context.goNamed(
                      PromotionDetailScreen.routeName,
                      pathParameters: {'id': homePromotionModel.id.toString()},
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: RED_COLOR,
                    elevation: 0,
                    padding: EdgeInsets.only(
                      left: 14.w,
                      right: 12.w,
                      top: 8.h,
                      bottom: 8.h,
                    ),
                    minimumSize: Size.zero,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '자세히 보기',
                        style: defaultTextStyle.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 12.sp,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        '›',
                        style: defaultTextStyle.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 13.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _leftDate(DateTime endDateTime) {
    return 'D-${endDateTime.day - DateTime.now().day}';
  }
}
