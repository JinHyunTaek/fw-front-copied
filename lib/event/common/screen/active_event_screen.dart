import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:mma_flutter/common/component/retry_loading/custom_circular_progess_indicator.dart';
import 'package:mma_flutter/common/component/retry_loading/retry_button.dart';
import 'package:mma_flutter/common/const/colors.dart';
import 'package:mma_flutter/common/utils/date_utils.dart';
import 'package:mma_flutter/event/common/dto/event_card_model.dart';
import 'package:mma_flutter/event/common/event_provider.dart';
import 'package:mma_flutter/event/promotion/screen/promotion_detail_screen.dart';
import 'package:mma_flutter/main.dart';

/// 진행중 이벤트(프로모션 등) 목록 화면.
/// 라이트/다크 모드 모두 대응 — 카드/텍스트/뱃지 색은 context.colors 기반으로 전환된다.
class ActiveEventScreen extends ConsumerWidget {

  static String get routeName => 'active_event';

  const ActiveEventScreen({super.key});

  // 진행중 상태 초록 (테마 무관 고정 accent)
  static const _proceedingColor = Color(0xff3CC773);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeEvents = ref.watch(activeEventsProvider);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('이벤트', style: context.text.bodyMedium),
      ),
      body: activeEvents.when(
        data: (events) {
          if (events.eventCards.isEmpty) {
            return _buildPlaceholder(context, '진행중인 이벤트가 없어요');
          }
          return ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            itemCount: events.eventCards.length,
            separatorBuilder: (_, __) => SizedBox(height: 12.h),
            itemBuilder:
                (context, index) =>
                    _buildActiveEventCard(context, eventCard: events.eventCards[index]),
          );
        },
        loading: () => CustomCircularProgressIndicator(),
        error:
            (_, __) => RetryButton(
              onRetry: () => ref.invalidate(activeEventsProvider),
            ),
      ),
    );
  }

  Widget _buildActiveEventCard(
    BuildContext context, {
    required EventCardModel eventCard,
  }) {
    final isDark = context.isDark;
    // 다크: 홈 배너와 동일한 elevation 서피스 / 라이트: surface(흰색) + 테두리·그림자로 카드 구분
    final cardColor = isDark ? EVENT_CARD_COLOR : context.colors.surface;
    final borderColor =
        isDark
            ? WHITE_COLOR.withValues(alpha: 0.08)
            : Colors.black.withValues(alpha: 0.06);
    final durationText = _durationText(eventCard);

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: cardColor,
        elevation: isDark ? 0 : 1.5,
        shadowColor: Colors.black.withValues(alpha: 0.12),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14.r),
          side: BorderSide(color: borderColor),
        ),
      ),
      onPressed: () {
        if(eventCard.type == '프로모션') {
          context.pushNamed(
            PromotionDetailScreen.routeName,
            pathParameters: {'id': eventCard.refId.toString()},
          );
        }
      },
      child: Row(
        children: [
          Container(
            width: 44.w,
            height: 44.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: RED_COLOR.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text('🎁', style: TextStyle(fontSize: 22.sp)),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  eventCard.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.bodyMedium?.copyWith(
                    color: context.colors.onSurface,
                    fontWeight: FontWeight.w700,
                    fontSize: 14.sp,
                  ),
                ),
                SizedBox(height: 4.h),
                // benefit: 기프티콘 종류가 다양해 길어질 수 있어 2줄까지 허용
                Text(
                  eventCard.benefit,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.bodySmall?.copyWith(
                    color: context.colors.onSurface.withValues(alpha: 0.85),
                    fontSize: 12.sp,
                    height: 1.25,
                  ),
                ),
                if (durationText != null) ...[
                  SizedBox(height: 4.h),
                  Text(
                    durationText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.bodySmall?.copyWith(
                      color: context.colors.subText,
                      fontSize: 10.5.sp,
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(width: 10.w),
          _renderProceedingStatus(
            context,
            startDateTime: eventCard.startDate,
            endDateTime: eventCard.endDate,
          ),
        ],
      ),
    );
  }

  Widget _renderProceedingStatus(
    BuildContext context, {
    required DateTime? startDateTime,
    required DateTime? endDateTime,
  }) {
    final bool isProceeding =
        (startDateTime != null && endDateTime != null)
            ? _isProceeding(
              startDateTime: startDateTime,
              endDateTime: endDateTime,
            )
            : true;
    final Color color =
        isProceeding ? _proceedingColor : context.colors.subText;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6.w,
            height: 6.w,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          SizedBox(width: 5.w),
          Text(
            isProceeding ? '진행중' : '종료',
            style: context.text.bodySmall?.copyWith(
              color: color,
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('🎁', style: TextStyle(fontSize: 40.sp)),
          SizedBox(height: 12.h),
          Text(
            message,
            style: context.text.bodyMedium?.copyWith(
              color: context.colors.subText,
            ),
          ),
        ],
      ),
    );
  }

  String? _durationText(EventCardModel eventCard) {
    if (eventCard.startDate != null && eventCard.endDate != null) {
      return _dateTimeDuration(
        startDateTime: eventCard.startDate!,
        endDateTime: eventCard.endDate!,
      );
    }
    return null;
  }

  bool _isProceeding({
    required DateTime startDateTime,
    required DateTime endDateTime,
  }) {
    final now = DateTime.now();
    return now.isAfter(startDateTime) && now.isBefore(endDateTime);
  }

  String _dateTimeDuration({
    required DateTime startDateTime,
    required DateTime endDateTime,
  }) {
    return '${CustomDateUtils.formatDateWithoutYear(startDateTime)}~${CustomDateUtils.formatDateWithoutYear(endDateTime)}';
  }
}
