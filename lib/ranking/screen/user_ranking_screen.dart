import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:mma_flutter/common/component/octagon/octagon_painter.dart';
import 'package:mma_flutter/common/component/retry_loading/custom_circular_progess_indicator.dart';
import 'package:mma_flutter/common/component/retry_loading/retry_button.dart';
import 'package:mma_flutter/common/const/colors.dart';
import 'package:mma_flutter/common/const/data.dart';
import 'package:mma_flutter/common/component/octagon/octagon_clipper.dart';
import 'package:mma_flutter/main.dart';
import 'package:mma_flutter/ranking/model/user_ranking_model.dart';
import 'package:mma_flutter/ranking/screen/user_recent_bet_screen.dart';
import 'package:mma_flutter/ranking/user_ranking_provider.dart';
import 'package:mma_flutter/user/model/user_model.dart';
import 'package:mma_flutter/user/provider/user_provider.dart';

class UserRankingScreen extends ConsumerWidget {
  const UserRankingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'USER RANKING',
          style: context.text.bodyMedium?.copyWith(
            fontSize: 28.sp,
            fontFamily: 'Dalmation',
          ),
        ),
        centerTitle: true,
      ),
      backgroundColor: context.colors.surface,
      body: ref
          .watch(userRankingProvider)
          .when(
            loading: () => CustomCircularProgressIndicator(),
            error: (error, stackTrace) {
              return RetryButton(
                onRetry: () => ref.invalidate(userRankingProvider),
              );
            },
            data: (data) {
              final me = ref.read(userProvider);
              final rankers = data.rankedUsers;
              if (rankers.length < 3 || me is! UserModel) {
                return Center(child: Text('준비 중입니다.'));
              }
              return SafeArea(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: SizedBox(
                    width: 362.w,
                    child: SingleChildScrollView(
                      physics: Platform.isIOS ? const BouncingScrollPhysics() : const ClampingScrollPhysics(),
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 25.h),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.only(top: 40.h),
                                    child: _renderRankerInTop3(
                                      context,
                                      rank: 2,
                                      ranker: rankers[1],
                                      imgSize: 55,
                                      borderColor: Color(0xffC0C0C0),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: _renderRankerInTop3(
                                    context,
                                    rank: 1,
                                    ranker: rankers[0],
                                    imgSize: 76,
                                    borderColor: Color(0xffFFD700),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.only(top: 40.h),
                                    child: _renderRankerInTop3(
                                      context,
                                      rank: 3,
                                      ranker: rankers[2],
                                      imgSize: 55,
                                      borderColor: Color(0xffB87333),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            height: 50.h,
                            decoration: BoxDecoration(
                              color: GREY_COLOR,
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(8.r),
                                topLeft: Radius.circular(8.r),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width: 32.w,
                                  child: Padding(
                                    padding: EdgeInsets.only(left: 6.w),
                                    child: Text(
                                      '랭킹',
                                      style: context.text.bodySmall,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 40.w),
                                SizedBox(
                                  width: 100.w,
                                  child: Text(
                                    '닉네임',
                                    style: context.text.bodyMedium,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                SizedBox(
                                  width: 70.w,
                                  child: Text(
                                    'EXP',
                                    style: context.text.bodyMedium,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                SizedBox(
                                  width: 55.w,
                                  child: Text(
                                    '벨트',
                                    style: context.text.bodyMedium,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              for (
                                int i = 3;
                                i < rankers.length && i < 10;
                                i++
                              ) ...[
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 12.h,
                                      horizontal: 6.w,
                                    ),
                                    backgroundColor: context.colors.box,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadiusGeometry.only(
                                        bottomLeft: Radius.circular(8.r),
                                        bottomRight: Radius.circular(8.r),
                                      ),
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return UserRecentBetScreen(
                                            userId: rankers[i].id,
                                            rankedUser: rankers[i],
                                            ranking: i + 1,
                                          );
                                        },
                                      ),
                                    );
                                  },
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      _renderRanking(context, ranking: i + 1),
                                      SizedBox(
                                        width: 40.w,
                                        child: _renderProfileImage(
                                          context,
                                          profileImgUrl:
                                              rankers[i].profileImgUrl,
                                          size: 32,
                                        ),
                                      ),
                                      _renderNickname(
                                        context,
                                        nickname: rankers[i].nickname,
                                      ),
                                      _renderScore(
                                        context,
                                        earnedBetSucceedPoint:
                                            rankers[i].earnedBetSucceedPoint,
                                      ),
                                      _renderBelt(
                                        context,
                                        earnedBetSucceedPoint:
                                            rankers[i].earnedBetSucceedPoint,
                                      ),
                                    ],
                                  ),
                                ),
                                if (i < rankers.length - 1 && i < 9)
                                  Divider(
                                    height: 1,
                                    thickness: 1,
                                    color: GREY_COLOR,
                                  ),
                              ],
                            ],
                          ),
                          if (data.myRanking > 10)
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 16.h),
                              child: Container(
                                height: 70.h,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadiusGeometry.circular(
                                    8.r,
                                  ),
                                  border: Border.all(
                                    width: 1.w,
                                    color: BLUE_COLOR,
                                  ),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 6.w,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      _renderRanking(
                                        context,
                                        ranking: data.myRanking,
                                      ),
                                      SizedBox(
                                        width: 50.w,
                                        child: _renderProfileImage(
                                          context,
                                          profileImgUrl: me.profileImgUrl,
                                          size: 50,
                                        ),
                                      ),
                                      _renderNickname(
                                        context,
                                        nickname: me.nickname ?? '',
                                      ),
                                      _renderScore(
                                        context,
                                        earnedBetSucceedPoint:
                                            me.earnedBetSucceedPoint,
                                      ),
                                      _renderBelt(
                                        context,
                                        earnedBetSucceedPoint:
                                            me.earnedBetSucceedPoint,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
    );
  }

  Widget _renderRankerInTop3(
    BuildContext context, {
    required int rank,
    required RankedUserModel ranker,
    required double imgSize,
    required Color borderColor,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) {
              return UserRecentBetScreen(
                userId: ranker.id,
                rankedUser: ranker,
                ranking: rank,
              );
            },
          ),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '#$rank',
            style: context.text.bodyMedium?.copyWith(
              fontFamily: 'Dalmation',
              fontSize: 17.sp,
              color: borderColor,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 10.h,bottom: 6.h),
            child: _renderOctagonProfileImage(
              context,
              profileImgUrl: ranker.profileImgUrl,
              size: imgSize,
              borderColor: borderColor,
            ),
          ),
          SizedBox(
            width: 120.w,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                beltByPoint(
                  point: ranker.earnedBetSucceedPoint,
                  width: 16.w,
                  height: 16.h,
                ),
                SizedBox(width: 4.w),
                Text(
                  ranker.nickname,
                  style: context.text.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${NumberFormat('#,###').format(ranker.earnedBetSucceedPoint)} EXP',
            style: context.text.bodySmall?.copyWith(fontSize: 12.sp),
          ),
        ],
      ),
    );
  }

  Widget _renderOctagonProfileImage(
    BuildContext context, {
    required String? profileImgUrl,
    required double size,
    required Color borderColor,
  }) {
    const crownH = 14.0;
    // octagon 상단 꼭짓점 y = height/2 - width/2
    // crown bottom이 거기 닿으려면: top = octagonTopY - crownH.h
    final octagonTopY = size.h / 2 - size.w / 2;
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        SizedBox(
          width: size.w,
          height: size.h,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CustomPaint(
                painter: OctagonPainter(
                  strokeColor: borderColor,
                  fillColor: context.colors.surface,
                  isEasy: true,
                  width: 2.5.w,
                ),
              ),
              ClipPath(
                clipper: OctagonClipper(),
                child:
                    profileImgUrl != null
                        ? CachedNetworkImage(
                          imageUrl: profileImgUrl,
                          fit: BoxFit.cover,
                          errorWidget:
                              (context, url, error) => Icon(
                                Icons.person_outline,
                                size: size.sp * 0.5,
                                color: context.colors.onSurface,
                              ),
                        )
                        : Icon(
                          Icons.person_outline,
                          size: size.sp * 0.5,
                          color: context.colors.onSurface,
                        ),
              ),
            ],
          ),
        ),
        Positioned(
          top: octagonTopY - crownH.h,
          child: SvgPicture.asset(
            'asset/img/icon/crown.svg',
            height: crownH.h,
            colorFilter: ColorFilter.mode(borderColor, BlendMode.srcIn),
          ),
        ),
      ],
    );
  }

  Widget _renderProfileImage(
    BuildContext context, {
    required String? profileImgUrl,
    required double size,
    Color? color,
  }) {
    return Container(
      height: size.h,
      width: size.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color ?? Colors.transparent, width: 2.w),
      ),
      child:
          profileImgUrl != null
              ? CachedNetworkImage(
                imageUrl: profileImgUrl,
                imageBuilder: (context, imageProvider) {
                  return CircleAvatar(backgroundImage: imageProvider);
                },
                errorWidget: (context, url, error) {
                  log('error, e=$error');
                  return Icon(
                    Icons.person_outline,
                    size: size.sp - 10.sp,
                    color: context.colors.onSurface,
                  );
                },
              )
              : Icon(
                Icons.person_outline,
                size: size.sp - 10.sp,
                color: context.colors.onSurface,
              ),
    );
  }

  Widget _renderRanking(BuildContext context, {required int ranking}) {
    return SizedBox(
      width: 24.w,
      child: Text(
        '#$ranking',
        style: context.text.bodySmall?.copyWith(fontFamily: 'Dalmation'),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _renderNickname(BuildContext context, {required String nickname}) {
    return SizedBox(
      width: 100.w,
      child: Text(
        nickname,
        style: context.text.bodyMedium,
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _renderScore(
    BuildContext context, {
    required int earnedBetSucceedPoint,
  }) {
    return SizedBox(
      width: 70.w,
      child: Center(
        child: Text(
          NumberFormat('#,###').format(earnedBetSucceedPoint).toString(),
          style: context.text.bodySmall,
        ),
      ),
    );
  }

  Widget _renderBelt(
    BuildContext context, {
    required int earnedBetSucceedPoint,
  }) {
    return SizedBox(
      width: 50.w,
      child: Center(
        child: beltByPoint(
          point: earnedBetSucceedPoint,
          width: 20.w,
          height: 20.h,
        ),
      ),
    );
  }
}
