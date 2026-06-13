import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:mma_flutter/common/component/retry_loading/custom_circular_progess_indicator.dart';
import 'package:mma_flutter/common/component/retry_loading/retry_button.dart';
import 'package:mma_flutter/common/const/colors.dart';
import 'package:mma_flutter/common/const/data.dart';
import 'package:mma_flutter/common/utils/fight_utils.dart';
import 'package:mma_flutter/main.dart';
import 'package:mma_flutter/ranking/model/user_ranking_model.dart';
import 'package:mma_flutter/ranking/user_ranking_provider.dart';
import 'package:mma_flutter/stream/bet/component/bet_history_cards.dart';
import 'package:mma_flutter/stream/bet/model/bet_response_model.dart';

class UserRecentBetScreen extends ConsumerStatefulWidget {
  final int userId;
  final RankedUserModel rankedUser;
  final int ranking;

  const UserRecentBetScreen({
    required this.userId,
    required this.rankedUser,
    required this.ranking,
    super.key,
  });

  @override
  ConsumerState<UserRecentBetScreen> createState() =>
      _UserRecentBetScreenState();
}

class _UserRecentBetScreenState extends ConsumerState<UserRecentBetScreen>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userRecentBet = ref.watch(
      userRecentBetsFutureProvider(widget.userId),
    );

    return userRecentBet.when(
      error: (error, stackTrace) {
        return RetryButton(
          onRetry: () => ref.invalidate(userRecentBetsFutureProvider),
        );
      },
      loading: () => CustomCircularProgressIndicator(),
      data: (data) {
        if (_tabController == null || _tabController!.length != data.length) {
          _tabController?.dispose();
          _tabController = TabController(length: data.length, vsync: this);
        }

        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text(
              '사용자 예측 상세',
              style: context.text.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          backgroundColor: context.colors.surface,
          body: Column(
            children: [
              _renderHeader(context, data: data),
              if (data.isEmpty)
                Expanded(
                  child: Center(
                    child: Text('예측 기록이 없습니다.', style: context.text.bodyMedium),
                  ),
                )
              else ...[
                TabBar(
                  controller: _tabController,
                  indicatorColor: BLUE_COLOR,
                  dividerColor: Colors.transparent,
                  labelColor: context.colors.onSurface,
                  unselectedLabelColor: GREY_COLOR,
                  isScrollable: data.length > 2,
                  tabs:
                      data
                          .map((e) => Tab(text: _shortEventName(e.eventName)))
                          .toList(),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children:
                        data
                            .map(
                              (e) => BetHistoryCards(
                                eventName: e.eventName,
                                betResponse: e,
                                eventId: null,
                              ),
                            )
                            .toList(),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _renderHeader(
    BuildContext context, {
    required List<BetResponseModel> data,
  }) {
    final wins =
        data.expand((e) => e.singleBets).where((b) => b.succeed == true).length;
    final losses =
        data
            .expand((e) => e.singleBets)
            .where((b) => b.succeed == false)
            .length;
    final total = wins + losses;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.all(16.w),
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [RED_COLOR, BLUE_COLOR]),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: context.colors.box,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Row(
          children: [
            _renderProfileImage(context),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '#${widget.ranking}',
                        style: context.text.bodySmall?.copyWith(
                          fontFamily: 'Dalmation',
                          color:
                              widget.ranking == 1
                                  ? const Color(0xFFFFD700)
                                  : widget.ranking == 2
                                  ? const Color(0xFFC0C0C0)
                                  : widget.ranking == 3
                                  ? const Color(0xFFCD7F32)
                                  : context.colors.onSurface,
                          fontSize: 16.sp,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        widget.rankedUser.nickname,
                        style: context.text.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 16.sp,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      beltByPoint(
                        point: widget.rankedUser.earnedBetSucceedPoint,
                        width: 24.w,
                        height: 24.h,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        CustomFightUtils.beltNameByPoint(
                          point: widget.rankedUser.earnedBetSucceedPoint,
                        ),
                        style: context.text.bodySmall?.copyWith(
                          color: context.colors.subText,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    '${NumberFormat('#,###').format(widget.rankedUser.earnedBetSucceedPoint)} EXP',
                    style: context.text.bodySmall,
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    '최근 전적: $total전 $wins승 $losses패',
                    style: context.text.bodySmall?.copyWith(
                      color: context.colors.subText,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _renderProfileImage(BuildContext context) {
    return Container(
      width: 64.w,
      height: 64.h,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: GREY_COLOR, width: 1.5.w),
      ),
      child:
          widget.rankedUser.profileImgUrl != null
              ? CachedNetworkImage(
                imageUrl: widget.rankedUser.profileImgUrl!,
                imageBuilder:
                    (context, imageProvider) =>
                        CircleAvatar(backgroundImage: imageProvider),
                errorWidget:
                    (context, url, error) => Icon(
                      Icons.person_outline,
                      size: 28.sp,
                      color: context.colors.onSurface,
                    ),
              )
              : Icon(
                Icons.person_outline,
                size: 28.sp,
                color: context.colors.onSurface,
              ),
    );
  }

  String _shortEventName(String eventName) {
    return eventName
        .replaceAll('UFC Fight Night', 'UFN')
        .replaceAll('UFC ', '');
  }
}
