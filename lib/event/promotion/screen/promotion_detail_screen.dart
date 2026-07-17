import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:mma_flutter/common/component/retry_loading/retry_button.dart';
import 'package:mma_flutter/common/const/colors.dart';
import 'package:mma_flutter/common/provider/route/router.dart';
import 'package:mma_flutter/common/utils/date_utils.dart';
import 'package:mma_flutter/event/promotion/component/promotion_winner_list.dart';
import 'package:mma_flutter/event/promotion/model/gifticon_category.dart';
import 'package:mma_flutter/event/promotion/model/promotion_detail_model.dart';
import 'package:mma_flutter/event/promotion/provider/promotion_providers.dart';
import 'package:mma_flutter/main.dart';
import 'package:mma_flutter/stream/bet/utils/prediction_reward_policy.dart';
import 'package:mma_flutter/stream/stream_main_view.dart';
import 'package:mma_flutter/user/model/user_model.dart';
import 'package:mma_flutter/user/provider/user_provider.dart';

class PromotionDetailScreen extends ConsumerWidget {
  static String get routeName => 'promotion_detail';
  static final highlightColor = Color(0xffFFDC5D);
  static final greenColor = Color(0xff3CC773);

  final int id;

  const PromotionDetailScreen({required this.id, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(promotionDetailProvider(id));

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('프로모션 상세', style: context.text.bodyMedium),
      ),
      backgroundColor: context.colors.surface,
      body: state.when(
        data: (data) {
          return SingleChildScrollView(
            physics: ClampingScrollPhysics(),
            child: Column(
              children: [
                // 경품 개수는 이벤트마다 달라 높이가 동적 → 고정하지 않고 콘텐츠에 맞춰 hug
                _DefaultContainer(
                  child: _renderGifticons(
                    maxWinnerCount: data.promotion.maxWinnerCount,
                    gifticons: data.promotion.gifticons,
                  ),
                ),
                _DefaultContainer(
                  height: 104.h,
                  child: _renderPromotionInfo(
                    context,
                    startDate: data.promotion.startDate,
                    endDate: data.promotion.endDate,
                    announceDate: data.promotion.announceDate,
                    isDrawn: data.promotion.isDrawn,
                  ),
                ),
                if(data.promotion.isDrawn)
                  _DefaultContainer(
                    child: PromotionWinnerList(
                      maxWinnerCount: data.promotion.maxWinnerCount,
                      winnerGifticons: data.promotion.winnerGifticons!,
                    ),
                  ),
                if (!data.promotion.isDrawn)
                  _DefaultContainer(
                    child: _renderParticipationMethod(
                      context,
                      entryCap: data.entryCap,
                    ),
                  ),
                if (!data.promotion.isDrawn)
                  _DefaultContainer(
                    child: _renderMyStatus(
                      context,
                      ref,
                      entryCap: data.entryCap,
                      myEntryCount: data.myEntryCount,
                    ),
                  ),
              ],
            ),
          );
        },
        error:
            (_, __) => RetryButton(
              onRetry: () => ref.invalidate(promotionDetailProvider(id)),
            ),
        loading: () => _PromotionDetailSkeletonScreen(),
      ),
    );
  }

  Widget _renderGifticons({
    required int maxWinnerCount,
    required List<GifticonModel> gifticons,
  }) {
    final sorted = [...gifticons]..sort((a, b) => a.priority - b.priority);

    final Map<({GifticonCategory category, String name}), int>
    gifticonCountMap = {};
    for (final g in sorted) {
      final key = (category: g.category, name: g.name);
      gifticonCountMap[key] = (gifticonCountMap[key] ?? 0) + 1;
    }
    final groups = gifticonCountMap.entries.toList();
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Column(
        mainAxisSize: MainAxisSize.min, // 콘텐츠 높이만큼만 차지
        children: [
          SizedBox(
            width: 338.w,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('🎁 경품', style: TextStyle(fontSize: 15.sp)),
                Text(
                  '총 $maxWinnerCount명',
                  style: TextStyle(fontSize: 15.sp, color: highlightColor),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 338.w,
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.only(top: 12.h),
              itemBuilder: (context, index) {
                final key = groups[index].key;
                final count = groups[index].value; // 같은 기프티콘 개수 = 당첨 인원
                return SizedBox(
                  height: 40.h,
                  child: Row(
                    children: [
                      Container(
                        width: 40.w,
                        height: 40.w,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: highlightColor.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Text(
                          key.category.emoji,
                          style: TextStyle(fontSize: 20.sp),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              key.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: context.colors.onSurface,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 1.h),
                            Text(
                              key.category.label,
                              style: TextStyle(
                                color: context.colors.subText,
                                fontSize: 11.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: highlightColor.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(999.r),
                        ),
                        child: Text(
                          '$count명',
                          style: TextStyle(
                            color: highlightColor,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
              separatorBuilder: (context, index) => SizedBox(height: 12.h),
              itemCount: groups.length,
            ),
          ),
        ],
      ),
    );
  }

  Widget _renderPromotionInfo(
    BuildContext context, {
    required DateTime startDate,
    required DateTime endDate,
    required DateTime announceDate,
    required bool isDrawn,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Column(
        children: [
          _renderPromotionInfoRow(
            context,
            label: '기간',
            value:
                '${CustomDateUtils.formatDateWithoutYear(startDate)}~${CustomDateUtils.formatDateWithoutYear(endDate)}',
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            child: _renderPromotionInfoRow(
              context,
              label: '발표',
              value: CustomDateUtils.formatDateWithoutYear(announceDate),
            ),
          ),
          _renderPromotionInfoRow(
            context,
            label: '상태',
            value: isDrawn ? '● 종료' : '● 진행중',
            statusColor:
                isDrawn
                    ? context.colors.subText.withValues(alpha: 0.5)
                    : greenColor,
          ),
        ],
      ),
    );
  }

  Widget _renderPromotionInfoRow(
    BuildContext context, {
    required String label,
    required String value,
    Color? statusColor,
  }) {
    return SizedBox(
      width: 338.w,
      height: 16.h,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: context.colors.subText, fontSize: 13.sp),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13.sp,
              color: statusColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _renderParticipationMethod(
    BuildContext context, {
    required int entryCap,
  }) {
    // 강조색(onSurface). 금색은 '내 응모 현황' 배너 전용이라 규칙 안내인
    // 여기서는 중립 강조만 사용한다.
    final emph = TextStyle(
      color: context.colors.onSurface,
      fontWeight: FontWeight.w600,
    );

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '참여 방법',
            style: context.text.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 12.h),
          // 카드 1개 = 응모 1회 · entryFee P
          _ruleRow(
            context,
            leading: _ticketChip(context),
            title: '카드 1개 예측 = 응모 1회',
            sub: [
              TextSpan(
                text: '${PredictionRewardPolicy.entryFee}P',
                style: emph,
              ),
              const TextSpan(text: ' 소모'),
            ],
          ),
          SizedBox(height: 12.h),
          // 조합 예측 = 카드 수만큼 응모/포인트 (묶든 따로든 동일)
          _ruleRow(
            context,
            leading: _emojiChip(context, '🔗'),
            title: '묶든 따로든 카드 수만큼 응모',
            sub: [
              const TextSpan(text: '3개 = 3응모 · '),
              TextSpan(
                text: '${PredictionRewardPolicy.entryFee * 3}P',
                style: emph,
              ),
            ],
          ),
          SizedBox(height: 12.h),
          // 응모할수록 확률 ↑ (최대 entryCap회)
          _ruleRow(
            context,
            leading: _emojiChip(context, '📈'),
            title: '응모할수록 당첨 확률 ↑',
            sub: [
              TextSpan(text: '최대 $entryCap회까지', style: emph),
              const TextSpan(text: ' 반영'),
            ],
          ),
          SizedBox(height: 12.h),
          // 💡 상한 규칙 콜아웃(중립 톤): 예측은 가능, 확률만 정지
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: context.colors.onSurface.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('💡', style: TextStyle(fontSize: 13.sp)),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      style: context.text.bodySmall?.copyWith(
                        color: context.colors.onSurface.withValues(alpha: 0.86),
                        height: 1.5,
                        fontSize: 12.5.sp,
                      ),
                      children: [
                        TextSpan(
                          text:
                              '$entryCap회를 채운 뒤에도 예측은 계속 할 수 있어요. '
                              '다만 당첨 확률은 ',
                        ),
                        TextSpan(text: '더 오르지 않아요.', style: emph),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 이모지 아이콘 칩(중립 톤). 참여방법 일반 규칙 행에 사용.
  Widget _emojiChip(BuildContext context, String emoji) {
    return Container(
      width: 36.w,
      height: 36.w,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: context.colors.onSurface.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Text(emoji, style: TextStyle(fontSize: 17.sp)),
    );
  }

  /// 파이트위크 응모권 칩. 티켓 이미지가 흰 배경(불투명)이라, 흰 칩 위에
  /// 얹어 이음매를 없애고 살짝 확대해 여백을 크롭한다. (2048² 원본은
  /// cacheWidth로 다운샘플링해 메모리 낭비 방지)
  Widget _ticketChip(BuildContext context) {
    return Container(
      width: 36.w,
      height: 36.w,
      padding: EdgeInsets.all(6.w),
      // 아이콘과 칩 사이 여백
      decoration: BoxDecoration(
        color: context.colors.onSurface.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Image.asset(
        'asset/img/icon/fightweek_ticket.png',
        fit: BoxFit.contain,
        cacheWidth: 144,
        filterQuality: FilterQuality.medium,
      ),
    );
  }

  /// 참여방법 한 줄: [아이콘 칩] + [제목 + 보조설명] 구조.
  Widget _ruleRow(
    BuildContext context, {
    required Widget leading,
    required String title,
    required List<InlineSpan> sub,
  }) {
    return Row(
      children: [
        leading,
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: context.text.bodySmall?.copyWith(
                  color: context.colors.onSurface,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
              ),
              SizedBox(height: 2.h),
              Text.rich(
                TextSpan(
                  style: context.text.bodySmall?.copyWith(
                    color: context.colors.subText,
                    fontSize: 11.5.sp,
                    height: 1.4,
                  ),
                  children: sub,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _renderMyStatus(
    BuildContext context,
    WidgetRef ref, {
    required int entryCap,
    required int myEntryCount,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '내 응모 현황',
            style: context.text.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            child: Row(
              children: [
                ...List.generate(entryCap, (index) {
                  return Padding(
                    padding: EdgeInsets.only(right: 7.w),
                    child: Container(
                      width: 11.w,
                      height: 11.h,
                      decoration: BoxDecoration(
                        color:
                            index < myEntryCount
                                ? greenColor
                                : WHITE_COLOR.withValues(alpha: 0.16),
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                }),
                Text(
                  '응모 $myEntryCount / $entryCap회',
                  style: context.text.bodyMedium,
                ),
              ],
            ),
          ),
          if (myEntryCount < entryCap)
            Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: Container(
                height: 41.h,
                width: 338.w,
                decoration: BoxDecoration(
                  color: highlightColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Center(
                  child: Text(
                    '🎯 ${entryCap - myEntryCount}회 더 예측하면 당첨 확률이 최대가 돼요!',
                    style: context.text.bodySmall?.copyWith(
                      color: highlightColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          if (myEntryCount < entryCap)
            ElevatedButton(
              onPressed: () => _goPredict(context, ref),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(338.w, 44.h),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                backgroundColor: BLUE_COLOR,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadiusGeometry.circular(12.r),
                ),
              ),
              child: Text(
                '예측하러 가기',
                style: context.text.bodySmall?.copyWith(
                  color: WHITE_COLOR,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _goPredict(BuildContext context, WidgetRef ref) {
    final user = ref.read(userProvider);
    if (user is! UserModel) return;

    // 1) 상세·이벤트 라우트를 홈까지 declarative 하게 정리
    context.go('/');
    // 2) 다음 프레임(스택 정리 반영 후) 루트 네비게이터에 예측 화면 push
    WidgetsBinding.instance.addPostFrameCallback((_) {
      rootNavigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (_) => StreamMainView(user: user, initialTabIndex: 1),
        ),
      );
    });
  }
}

class _PromotionDetailSkeletonScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _DefaultContainer(height: 104.h),
        _DefaultContainer(height: 102.h),
        _DefaultContainer(height: 254.h),
        _DefaultContainer(height: 193.h),
      ],
    );
  }
}

class _DefaultContainer extends StatelessWidget {
  final double? height; // null 이면 child 높이에 맞춰 hug
  final Widget? child;

  const _DefaultContainer({this.height, this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 7.h),
      child: Center(
        child: Container(
          height: height,
          width: 366.w,
          decoration: BoxDecoration(
            color: context.colors.box,
            borderRadius: BorderRadius.circular(14.r),
          ),
          child: child,
        ),
      ),
    );
  }
}
