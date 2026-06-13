import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mma_flutter/common/const/colors.dart';
import 'package:mma_flutter/main.dart';

class AppMaintenanceAlertScreen extends StatelessWidget {
  static String get routeName => 'maintenance';

  const AppMaintenanceAlertScreen({super.key});

  void _exitApp() {
    if (Platform.isAndroid) {
      SystemNavigator.pop();
    } else {
      exit(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: context.colors.surface,
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _getAppLogo(context),
            SizedBox(height: 16.h),
            Text(
              '서버 점검 중입니다',
              style: context.text.bodyMedium?.copyWith(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              '잠시 후 다시 이용해 주세요',
              style: context.text.bodyMedium?.copyWith(
                fontSize: 14.sp,
                color: MID_GREY_COLOR,
              ),
            ),
            SizedBox(height: 32.h),
            TextButton(
              onPressed: _exitApp,
              child: Text(
                '확인',
                style: context.text.bodyMedium?.copyWith(
                  color: MID_GREY_COLOR,
                  decoration: TextDecoration.underline,
                  decorationColor: MID_GREY_COLOR,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getAppLogo(BuildContext context) {
    return SvgPicture.asset(
      context.isDark
          ? 'asset/img/logo/fight_week_white.svg'
          : 'asset/img/logo/fight_week_black.svg',
      width: 70.w,
    );
  }
}
