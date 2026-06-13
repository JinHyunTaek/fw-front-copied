import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:mma_flutter/common/const/colors.dart';
import 'package:mma_flutter/common/const/style.dart';
import 'package:mma_flutter/main.dart';
import 'package:mma_flutter/setting/account/account_deletion_screen.dart';
import 'package:mma_flutter/setting/account/verify_password_screen.dart';
import 'package:mma_flutter/user/provider/user_provider.dart';

class AccountSettingScreen extends ConsumerWidget {
  static String get routeName => 'account_setting';

  const AccountSettingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          '계정 설정',
          style: context.text.bodyMedium,
        ),
      ),
      body: Container(
        color: context.colors.surface,
        child: Column(
          children: [
            _menuWithIcon(
              context,
              screenWidth: screenWidth,
              icon: FontAwesomeIcons.key,
              label: '비밀번호 변경',
              onPressed: () async {
                if(await ref.read(userProvider.notifier).checkIsSocial()){
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('소셜 로그인 플랫폼 사용자는 비밀번호를 변경할 수 없습니다.')),
                  );
                }else{
                  context.goNamed(VerifyPasswordScreen.routeName);
                }
              },
            ),
            _menuWithIcon(
              context,
              screenWidth: screenWidth,
              icon: FontAwesomeIcons.x,
              label: '회원탈퇴',
              onPressed: () {
                context.goNamed(AccountDeletionScreen.routeName);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuWithIcon(
      BuildContext context,
      {
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required double screenWidth,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.zero),
        backgroundColor: context.colors.surface,
        fixedSize: Size(screenWidth, 52.h),
      ),
      child: Row(
        children: [
          Icon(icon, color: context.colors.onSurface),
          SizedBox(width: 20.w),
          Text(label, style: context.text.bodySmall),
        ],
      ),
    );
  }
}
