import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mma_flutter/app_status/provider/app_status_provider.dart';
import 'package:mma_flutter/common/component/retry_loading/custom_circular_progess_indicator.dart';
import 'package:mma_flutter/common/component/retry_loading/retry_button.dart';
import 'package:mma_flutter/common/const/colors.dart';
import 'package:mma_flutter/common/const/data.dart';
import 'package:mma_flutter/main.dart';
import 'package:mma_flutter/user/provider/user_provider.dart';
import 'package:url_launcher/url_launcher.dart';

const _playStoreUrl =
    'https://play.google.com/store/apps/details?id=com.ht.fightweek';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  static String get routeName => 'splash';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: context.colors.surface,
      body: ref
          .watch(appStatusProvider)
          .when(
            skipLoadingOnRefresh: false,
            data: (status) {
              WidgetsBinding.instance.addPostFrameCallback((_) async {
                log(status.toString());
                final res = _isForceUpdateRequired(
                  current: appVersion,
                  min: status.minVersion!,
                  latest: status.latestVersion!,
                );
                log(res.toString());
                if (res == true) {
                  if (Platform.isIOS) {
                    showCupertinoDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) => CupertinoAlertDialog(
                        title: const Text('업데이트 필요'),
                        content: const Text(
                          '최신 버전으로 앱을 업데이트하기 위해 스토어로 이동합니다.',
                        ),
                        actions: [
                          CupertinoDialogAction(
                            onPressed: () async {
                              await launchUrl(
                                Uri.parse(_playStoreUrl),
                                mode: LaunchMode.externalApplication,
                              );
                            },
                            child: const Text('확인'),
                          ),
                        ],
                      ),
                    );
                  } else {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) => AlertDialog(
                        backgroundColor: context.colors.box,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        title: Text(
                          '업데이트 필요',
                          style: context.text.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 20.sp,
                          ),
                        ),
                        content: const Text(
                          '최신 버전으로 앱을 업데이트하기 위해 스토어로 이동합니다.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () async {
                              await launchUrl(
                                Uri.parse(_playStoreUrl),
                                mode: LaunchMode.externalApplication,
                              );
                            },
                            child: Text('확인', style: context.text.bodyMedium),
                          ),
                        ],
                      ),
                    );
                  }
                  return;
                } else if (res == false) {
                  // dialog 닫았을 때, 닫힌 후에야 getMe() 호출 보장하기 위해 await 사용
                  if (Platform.isIOS) {
                    await showCupertinoDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) => CupertinoAlertDialog(
                        title: const Text('업데이트 권장'),
                        content: const Text('최신 버전이 출시되었습니다. 업데이트하시겠습니까?'),
                        actions: [
                          CupertinoDialogAction(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('나중에'),
                          ),
                          CupertinoDialogAction(
                            onPressed: () async {
                              await launchUrl(
                                Uri.parse(_playStoreUrl),
                                mode: LaunchMode.externalApplication,
                              );
                              if (context.mounted) Navigator.of(context).pop();
                            },
                            child: const Text('확인'),
                          ),
                        ],
                      ),
                    );
                  } else {
                    await showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) => AlertDialog(
                        backgroundColor: context.colors.box,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        title: Text(
                          '업데이트 권장',
                          style: context.text.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 20.sp,
                          ),
                        ),
                        content: const Text('최신 버전이 출시되었습니다. 업데이트하시겠습니까?'),
                        actionsPadding: EdgeInsets.only(bottom: 8.h),
                        actionsAlignment: MainAxisAlignment.center,
                        actions: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadiusGeometry.circular(8.r),
                                side: BorderSide(width: 1.w, color: MID_GREY_COLOR),
                              ),
                            ),
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text('나중에', style: context.text.bodyMedium),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadiusGeometry.circular(8.r),
                                side: BorderSide(width: 1.w, color: MID_GREY_COLOR),
                              ),
                            ),
                            onPressed: () async {
                              await launchUrl(
                                Uri.parse(_playStoreUrl),
                                mode: LaunchMode.externalApplication,
                              );
                              if (context.mounted) Navigator.of(context).pop();
                            },
                            child: Text('확인', style: context.text.bodyMedium),
                          ),
                        ],
                      ),
                    );
                  }
                }
                ref.read(userProvider.notifier).getMe();
              });
              return _renderLoading(context);
            },
            loading: () => _renderLoading(context),
            error: (_, __) => _renderError(context, ref),
          ),
    );
  }

  Widget _renderLoading(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _getAppLogo(context),
          const SizedBox(height: 16),
          CustomCircularProgressIndicator(),
        ],
      ),
    );
  }

  Widget _renderError(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _getAppLogo(context),
          const SizedBox(height: 16),
          RetryButton(onRetry: () => ref.invalidate(appStatusProvider)),
        ],
      ),
    );
  }

  // latest >= min and (min >= current or current >= min)
  bool? _isForceUpdateRequired({
    required String current,
    required String min,
    required String latest,
  }) {
    final c = current.split('.').map(int.parse).toList();
    final m = min.split('.').map(int.parse).toList();
    final l = latest.split('.').map(int.parse).toList();

    // 현재 버전이 최소 버전보다 낮으면, 앱 업데이트 필수
    for (int i = 0; i < 3; i++) {
      if (c[i] < m[i]) return true;
      if (c[i] > m[i]) break;
    }

    // 현재 MAJOR 버전이 최신 MAJOR 버전보다 낮으면, 업데이트 필수
    if (c[0] < l[0]) return true;

    // 업데이트 권장 (minor/patch가 최신보다 낮으면)
    for (int i = 1; i < 3; i++) {
      if (c[i] < l[i]) return false;
      if (c[i] > l[i]) break;
    }
    // 업데이트 필요 없음
    return null;
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
