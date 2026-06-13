import 'dart:developer';

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mma_flutter/common/const/colors.dart';
import 'package:mma_flutter/common/layout/default_layout.dart';
import 'package:mma_flutter/common/provider/interstitial_ad_provider.dart';
import 'package:mma_flutter/fight_event/screen/fight_event/fight_event_screen.dart';
import 'package:mma_flutter/game/screen/game_main_screen.dart';
import 'package:mma_flutter/home/screen/home_screen.dart';
import 'package:mma_flutter/main.dart';
import 'package:mma_flutter/user/screen/profile/profile_screen.dart';

class RootTab extends ConsumerStatefulWidget {
  static String get routeName => 'home';

  const RootTab({super.key});

  @override
  ConsumerState<RootTab> createState() => _RootTabState();
}

class _RootTabState extends ConsumerState<RootTab>
    with SingleTickerProviderStateMixin {
  late final TabController controller;
  int index = 0;

  @override
  void initState() {
    log('init root tab');
    super.initState();
    ref.read(interstitialAdProvider.notifier).load();
    controller = TabController(length: 4, vsync: this, initialIndex: index);
    controller.addListener(tabListener);
  }

  @override
  void dispose() {
    log('dispose root_tab');
    controller.removeListener(tabListener);
    controller.dispose();
    super.dispose();
  }

  void tabListener() {
    setState(() {
      index = controller.index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldExit = await _showExitDialog(context);
        if (shouldExit == true) {
          SystemNavigator.pop();
        }
      },
      child: DefaultLayout(
        resizeToAvoidBottomInset: false,
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: context.colors.surface,
          selectedItemColor: BLUE_COLOR,
          showSelectedLabels: false,
          unselectedItemColor: context.colors.onSurface,
          selectedFontSize: 10,
          unselectedFontSize: 10,
          type: BottomNavigationBarType.fixed,
          onTap: (index) {
            controller.animateTo(index);
          },
          currentIndex: index,
          items: [
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                'asset/img/icon/bottombar/home.svg',
                colorFilter: ColorFilter.mode(
                  index == 0 ? BLUE_COLOR : context.colors.onSurface,
                  BlendMode.srcIn,
                ),
              ),
              label: '홈',
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                'asset/img/icon/bottombar/schedule.svg',
                colorFilter: ColorFilter.mode(
                  index == 1 ? BLUE_COLOR : context.colors.onSurface,
                  BlendMode.srcIn,
                ),
              ),
              label: '경기 일정',
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                'asset/img/icon/bottombar/'
                    '${index == 2 ? 'selected' : 'unselected'}_quiz_'
                    '${context.isDark ? 'white' : 'black'}.svg',
              ),
              label: '게임',
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                'asset/img/icon/bottombar/profile.svg',
                colorFilter: ColorFilter.mode(
                  index == 3 ? BLUE_COLOR : context.colors.onSurface,
                  BlendMode.srcIn,
                ),
              ),
              label: '프로필',
            ),
          ],
        ),
        child: TabBarView(
          // TabBarView 간 스크롤(좌우) 불가
          physics: NeverScrollableScrollPhysics(),
          controller: controller,
          children: [
            HomeScreen(),
            // SearchScreen(),
            FightEventScreen(),
            GameMainScreen(),
            ProfileScreen(),
          ],
        ),
      ),
    );
  }

  Future<bool?> _showExitDialog(BuildContext context) async {
    if (Platform.isIOS) {
      return showCupertinoDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('앱 종료'),
          content: const Text('정말 종료하시겠습니까?'),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('취소'),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () => Navigator.pop(context, true),
              child: const Text('종료'),
            ),
          ],
        ),
      );
    }
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('앱 종료'),
        content: const Text('정말 종료하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('종료'),
          ),
        ],
      ),
    );
  }
}
