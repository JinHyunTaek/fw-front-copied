import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:mma_flutter/common/const/data.dart';
import 'package:mma_flutter/common/const/style.dart';
import 'package:mma_flutter/main.dart';
import 'package:mma_flutter/ranking/screen/fighter_ranking_screen.dart';
import 'package:mma_flutter/ranking/screen/fighter_rating_ranking_screen.dart';
import 'package:mma_flutter/ranking/screen/user_ranking_screen.dart';
import 'package:mma_flutter/search/screen/search_screen.dart';
import 'package:mma_flutter/setting/setting_selection_screen.dart';
import 'package:mma_flutter/user/model/user_model.dart';
import 'package:mma_flutter/user/provider/user_provider.dart';

class DefaultLayout extends ConsumerWidget {
  final BottomNavigationBar? bottomNavigationBar;
  final Widget? floatingActionButton;
  final Widget child;
  final Color? backGroundColor;
  final bool? resizeToAvoidBottomInset;

  const DefaultLayout({
    required this.child,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.backGroundColor,
    this.resizeToAvoidBottomInset,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.read(userProvider);
    final tilePadding = EdgeInsets.symmetric(
      horizontal: 32.w,
      vertical: 0,
    );
    final tileTextStyle = context.text.bodyMedium?.copyWith(
      fontSize: 16.sp,
      fontWeight: FontWeight.w500,
      color: context.colors.onSurface,
    );

    return Scaffold(
      resizeToAvoidBottomInset: resizeToAvoidBottomInset ?? true,
      drawer:
      user is UserModel && bottomNavigationBar?.currentIndex == 0
          ? Drawer(
        width: 248.w,
        child: Container(
          color: context.colors.box,
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 프로필 영역
                Padding(
                  padding: EdgeInsets.fromLTRB(32.w, 20.h, 16.w, 20.h),
                  child: Row(
                    children: [
                      // 프로필 이미지
                      ClipOval(
                        child:
                        user.profileImgUrl != null
                            ? CachedNetworkImage(
                          imageUrl: user.profileImgUrl!,
                          width: 44.w,
                          height: 44.w,
                          fit: BoxFit.cover,
                          errorWidget:
                              (c, u, e) =>
                              _defaultProfileIcon(context),
                        )
                            : _defaultProfileIcon(context),
                      ),
                      SizedBox(width: 10.w),
                      // 닉네임 + 벨트 + 이메일
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  user.nickname ?? '',
                                  style: context.text.bodyMedium
                                      ?.copyWith(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w500,
                                    color: context.colors.onSurface,
                                  ),
                                ),
                                SizedBox(width: 4.w),
                                beltByPoint(
                                  point: user.earnedBetSucceedPoint,
                                  width: 18.w,
                                  height: 18.w,
                                ),
                              ],
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              user.email,
                              style: context.text.bodyMedium?.copyWith(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w400,
                                color: context.colors.subText,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(
                  color: context.colors.subText.withValues(alpha: 0.3),
                  height: 1,
                ),
                // 메뉴 항목
                ListTile(
                  contentPadding: tilePadding,
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => UserRankingScreen(),
                      ),
                    );
                  },
                  title: Text(
                      '유저 랭킹',
                      style: tileTextStyle
                  ),
                ),
                ListTile(
                  contentPadding: tilePadding,
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => FighterRankingScreen(),
                      ),
                    );
                  },
                  title: Text(
                    '파이터 랭킹',
                    style: tileTextStyle,
                  ),
                ),
                ListTile(
                  contentPadding: tilePadding,
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => FighterRatingRankingScreen(),
                      ),
                    );
                  },
                  title: Text(
                    '파이터 호감도 랭킹',
                    style: tileTextStyle,
                  ),
                ),
              ],
            ),
          ),
        ),
      )
          : null,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      appBar: renderAppBar(user, context, bottomNavigationBar),
      backgroundColor: context.colors.surface,
      body: child,
    );
  }

  Widget _defaultProfileIcon(BuildContext context) {
    return SvgPicture.asset(
      'asset/img/icon/bottombar/profile.svg',
      width: 44.w,
      height: 44.w,
      colorFilter: ColorFilter.mode(context.colors.onSurface, BlendMode.srcIn),
    );
  }

  PreferredSize renderAppBar(UserModelBase? user,
      BuildContext context,
      BottomNavigationBar? bottomNavigationBar,) {
    final canPop = ModalRoute
        .of(context)
        ?.canPop ?? false;

    return PreferredSize(
      preferredSize: Size.fromHeight(56.h),
      child: AppBar(
        centerTitle: false,
        title:
        bottomNavigationBar?.currentIndex == 0 || canPop
            ? null
            : Text(
          'FIGHT WEEK',
          style: context.text.bodyMedium?.copyWith(
            fontFamily: 'Dalmation',
            fontSize: 16.sp,
          ),
        ),
        actions:
        user is UserModel
            ? [
          IconButton(
            onPressed: () {
              context.pushNamed(
                bottomNavigationBar?.currentIndex == 3
                    ? SettingSelectionScreen.routeName
                    : SearchScreen.routeName,
              );
            },
            icon: bottomNavigationBar?.currentIndex == 3 ? SvgPicture.asset(
              'asset/img/icon/settings.svg',
              colorFilter: ColorFilter.mode(
                context.colors.onSurface,
                BlendMode.srcIn,
              ),
            ):
            Icon(Icons.search,
            ),
          ),
        ]
            : null,
      ),
    );
  }
}
