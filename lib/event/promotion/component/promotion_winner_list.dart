import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mma_flutter/main.dart';
import 'package:mma_flutter/event/promotion/model/promotion_detail_model.dart';

/// 종료(추첨 완료) 프로모션 상세의 '🏆 당첨자' 카드.
/// 서버가 기프티콘 우선순위(displayOrder)대로 정렬해 내려주므로 그 순서 그대로 렌더한다.
class PromotionWinnerList extends StatelessWidget {
  static const _gold = Color(0xffFFDC5D);

  final int maxWinnerCount;
  final List<PromotionWinnerGifticonModel> winnerGifticons;

  const PromotionWinnerList({
    required this.maxWinnerCount,
    required this.winnerGifticons,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 338.w,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('🏆 당첨자', style: TextStyle(fontSize: 15.sp)),
                Text(
                  '총 $maxWinnerCount명',
                  style: TextStyle(fontSize: 15.sp, color: _gold),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 338.w,
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.only(top: 14.h),
              itemCount: winnerGifticons.length,
              separatorBuilder: (context, index) => SizedBox(height: 14.h),
              itemBuilder: (context, index) {
                final winner = winnerGifticons[index];
                final emoji = winner.category.emoji;
                return SizedBox(
                  height: 40.h,
                  child: Row(
                    children: [
                      Container(
                        width: 40.w,
                        height: 40.w,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: _gold.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Text(emoji, style: TextStyle(fontSize: 20.sp)),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              winner.winnerNickname,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: context.colors.onSurface,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              winner.gifticonName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: context.colors.subText,
                                fontSize: 11.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
