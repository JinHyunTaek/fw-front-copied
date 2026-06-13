import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:mma_flutter/common/const/data.dart';
import 'package:mma_flutter/common/provider/theme/theme_mode_provider.dart';
import 'package:mma_flutter/common/screen/web_view_screen.dart';
import 'package:mma_flutter/main.dart';
import 'package:mma_flutter/setting/account/account_setting_screen.dart';
import 'package:mma_flutter/setting/announcement/screen/announcement_screen.dart';
import 'package:mma_flutter/setting/inquiry/faq/faq_screen.dart';
import 'package:mma_flutter/setting/notification/notification_setting_screen.dart';
import 'package:mma_flutter/user/provider/user_provider.dart';

class SettingSelectionScreen extends ConsumerWidget {
  static String get routeName => 'setting_selection';

  const SettingSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: context.colors.surface,
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: Platform.isIOS ? const BouncingScrollPhysics() : const ClampingScrollPhysics(),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                child: Text(
                  '설정',
                  style: context.text.bodyMedium?.copyWith(fontSize: 18.sp),
                ),
              ),
              _renderSettingCategory(
                context,
                screenWidth: screenWidth,
                settingCategory: SettingCategory.account,
              ),
              _renderSettingSelection(
                context,
                screenWidth: screenWidth,
                label: '계정 설정',
                onPressed: () {
                  context.pushNamed(AccountSettingScreen.routeName);
                },
              ),
              _renderSettingCategory(
                context,
                screenWidth: screenWidth,
                settingCategory: SettingCategory.alert,
              ),
              _renderSettingSelection(
                context,
                screenWidth: screenWidth,
                label: '푸시 알림',
                onPressed: () {
                  context.pushNamed(NotificationSettingScreen.routeName);
                },
              ),
              _renderSettingCategory(
                context,
                screenWidth: screenWidth,
                settingCategory: SettingCategory.inquiry,
              ),
              _renderSettingSelection(
                context,
                screenWidth: screenWidth,
                label: '공지사항',
                onPressed: () {
                  context.pushNamed(AnnouncementScreen.routeName);
                },
              ),
              _renderSettingSelection(
                context,
                screenWidth: screenWidth,
                label: 'FAQ',
                onPressed: () {
                  context.pushNamed(FaqScreen.routeName);
                },
              ),

              _renderSettingCategory(
                context,
                screenWidth: screenWidth,
                settingCategory: SettingCategory.legal,
              ),
              _renderSettingSelection(
                context,
                screenWidth: screenWidth,
                label: '개인정보처리방침',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const WebViewScreen(
                        url: 'https://jinhyuntaek.github.io/fightweek-privacy/',
                        title: '개인정보처리방침',
                      ),
                    ),
                  );
                },
              ),

              _renderSettingCategory(
                context,
                screenWidth: screenWidth,
                settingCategory: SettingCategory.display,
              ),
              _renderSettingSelection(
                context,
                screenWidth: screenWidth,
                label: context.isDark ? '화이트 모드로 변환' : '다크 모드로 변환',
                onPressed: () {
                  ref
                      .read(themeModeProvider.notifier)
                      .update(
                        (state) =>
                            context.isDark ? ThemeMode.light : ThemeMode.dark,
                      );
                },
              ),
              Row(
                children: [
                  _renderSettingCategory(
                    context,
                    screenWidth: screenWidth,
                    settingCategory: SettingCategory.version,
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(top: 16.h),
                child: GestureDetector(
                  onTap: () {
                    ref.read(userProvider.notifier).logout();
                  },
                  child: Text(
                    '로그아웃',
                    style: context.text.bodyMedium?.copyWith(
                      decoration: TextDecoration.underline,
                      decorationColor: context.colors.onSurface,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _renderSettingCategory(
    BuildContext context, {
    required double screenWidth,
    required SettingCategory settingCategory,
  }) {
    return Container(
      color: context.colors.box,
      width: screenWidth,
      height: 45.h,
      child: Padding(
        padding: EdgeInsets.only(left: 30.w),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            settingCategory.label,
            style: context.text.bodyMedium?.copyWith(
              color: context.colors.onSurface,
            ),
          ),
        ),
      ),
    );
  }

  Widget _renderSettingSelection(
    BuildContext context, {
    required double screenWidth,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        fixedSize: Size(screenWidth, 45.h),
        backgroundColor: context.colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.circular(8.r),
        ),
      ),
      onPressed: onPressed,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          label,
          style: context.text.bodyMedium?.copyWith(
            color: context.colors.onSurface,
          ),
        ),
      ),
    );
  }
}

enum SettingCategory {
  account,alert,inquiry,legal, display, version
}

extension SettingCategoryExtension on SettingCategory{
  String get label {
    switch(this){
      case SettingCategory.account:
        return '계정';
      case SettingCategory.alert:
        return '알림';
      case SettingCategory.inquiry:
        return '문의';
      case SettingCategory.legal:
        return '법적 고지';
      case SettingCategory.display:
        return '디스플레이';
      case SettingCategory.version:
        return '앱 버전 $appVersion';
    }
  }
}
