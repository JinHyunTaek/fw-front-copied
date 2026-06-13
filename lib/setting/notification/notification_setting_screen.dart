import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mma_flutter/alert/model/update_alert_request.dart';
import 'package:mma_flutter/alert/model/update_preference_request.dart';
import 'package:mma_flutter/alert/model/user_preferences.dart';
import 'package:mma_flutter/alert/provider/notification_provider.dart';
import 'package:mma_flutter/common/component/custom_alert_dialog.dart';
import 'package:mma_flutter/common/component/retry_loading/custom_circular_progess_indicator.dart';
import 'package:mma_flutter/common/component/retry_loading/retry_button.dart';
import 'package:mma_flutter/common/const/colors.dart';
import 'package:mma_flutter/common/model/base_state_model.dart';
import 'package:mma_flutter/fight_event/provider/fight_event_provider.dart';
import 'package:mma_flutter/fighter/provider/fighter_provider.dart';
import 'package:mma_flutter/main.dart';

class NotificationSettingScreen extends ConsumerStatefulWidget {
  static String get routeName => "notification_setting";

  const NotificationSettingScreen({super.key});

  @override
  ConsumerState<NotificationSettingScreen> createState() =>
      _NotificationSettingScreenState();
}

class _NotificationSettingScreenState
    extends ConsumerState<NotificationSettingScreen> {
  late ProviderContainer _container;

  @override
  void initState() {
    super.initState();
    _container = ProviderScope.containerOf(context, listen: false);
  }

  @override
  void dispose() {
    _container.invalidate(notificationProvider);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final alertState = ref.watch(notificationProvider);

    if (alertState is StateError) {
      return _frame(
        body: RetryButton(
          onRetry:
              () => ref.read(notificationProvider.notifier).getPreferences(),
        ),
      );
    }
    if (alertState is! StateData<UserPreferences>) {
      return _frame(body: CustomCircularProgressIndicator());
    }

    final preferences = alertState.data!;
    final isFighterOn = preferences.fighterAlertEnabled;
    final isUpcomingEventOn = preferences.eventAlertEnabled;
    final isWeeklyEventOn = preferences.weeklyEventAlertEnabled;

    return _frame(
      body: Center(
        child: Container(
          color: context.colors.surface,
          width: 362.w,
          child: Column(
            children: [
              _notificationIcon(
                label: '푸시 알림 받기',
                onTap: () {
                  ref
                      .read(notificationProvider.notifier)
                      .updatePreferences(
                        isOn:
                            !(preferences.weeklyEventAlertEnabled ||
                                preferences.eventAlertEnabled ||
                                preferences.fighterAlertEnabled),
                      );
                },
                isOn:
                    (preferences.weeklyEventAlertEnabled ||
                        preferences.eventAlertEnabled ||
                        preferences.fighterAlertEnabled),
              ),
              Container(height: 1.h, color: GREY_COLOR),
              _notificationIcon(
                label: '좋아하는 선수',
                onTap: () {
                  /// 알림 해제 시도할 때
                  if (isFighterOn) {
                    _showAlertDialog(
                      alertTarget: AlertTarget.fighter,
                      isOn: !isFighterOn,
                      userPreferences: alertState.data!,
                    );
                  } else {
                    /// 알림 on 시도할 때
                    ref
                        .read(notificationProvider.notifier)
                        .updateSinglePreference(
                          request: UpdatePreferenceRequest(
                            on: !isFighterOn,
                            alertTarget: AlertTarget.fighter,
                          ),
                          currentPreferences: alertState.data!,
                        );
                  }
                },
                isOn: isFighterOn,
                aboutText: '매주 수요일 6시에 좋아요한 선수의 경기가 이번 주 경기에 포함된 경우, 알림을 보냅니다',
              ),
              _notificationIcon(
                label: '알림 설정한 경기',
                onTap: () {
                  /// 알림 해제 시도할 때
                  if (isUpcomingEventOn) {
                    _showAlertDialog(
                      alertTarget: AlertTarget.upcomingEvent,
                      isOn: !isUpcomingEventOn,
                      userPreferences: alertState.data!,
                    );
                  } else {
                    ref
                        .read(notificationProvider.notifier)
                        .updateSinglePreference(
                          request: UpdatePreferenceRequest(
                            on: !isUpcomingEventOn,
                            alertTarget: AlertTarget.upcomingEvent,
                          ),
                          currentPreferences: alertState.data!,
                        );
                  }
                },
                isOn: isUpcomingEventOn,
                aboutText: '알림 설정한 경기 메인 카드 시작 1시간 전 알림을 보냅니다',
              ),
              _notificationIcon(
                label: '이번 주 경기',
                onTap: () {
                  ref
                      .read(notificationProvider.notifier)
                      .updateSinglePreference(
                        request: UpdatePreferenceRequest(
                          on: !isWeeklyEventOn,
                          alertTarget: null,
                          isWeeklyEvent: true,
                        ),
                        currentPreferences: alertState.data!,
                      );
                },
                isOn: isWeeklyEventOn,
                aboutText: '매주 월요일 오후 6시에 이번 주 경기 일정 알림을 보냅니다',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _frame({required Widget body}) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('푸시 알림', style: context.text.bodyMedium),
      ),
      body: body,
    );
  }

  Widget _notificationIcon({
    required String label,
    required VoidCallback onTap,
    required bool isOn,
    String? aboutText,
  }) {
    return SizedBox(
      height: 52.h,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(label, style: context.text.bodySmall),
              SizedBox(width: 4.w),
              if (aboutText != null)
                Padding(
                  padding: EdgeInsets.only(top: 4.h),
                  child: GestureDetector(
                    child: Icon(
                      Icons.help_outline_sharp,
                      color: MID_GREY_COLOR,
                      size: 17.sp,
                    ),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return CustomAlertDialog(
                            titleMsg: label,
                            contentMsg: aboutText,
                          );
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
          GestureDetector(
            onTap: onTap,
            child: AnimatedContainer(
              height: 18.h,
              width: 37.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.r),
                color: isOn ? BLUE_COLOR : GREY_COLOR,
              ),
              alignment: isOn ? Alignment.centerRight : Alignment.centerLeft,
              duration: Duration(milliseconds: 250),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 3.w),
                child: Container(
                  height: 14.h,
                  width: 14.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: WHITE_COLOR,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAlertDialog({
    required AlertTarget alertTarget,
    required bool isOn,
    required UserPreferences userPreferences,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadiusGeometry.circular(8.r),
          ),
          title: Center(
            child: Text(
              '회원님께서 푸시 알림으로 등록하신 ${alertTarget == AlertTarget.fighter ? '선수' : '경기'} 목록이 모두 초기화됩니다. 진행하시겠습니까?',
              style: context.text.bodyMedium,
            ),
          ),
          backgroundColor: DARK_GREY_COLOR,
          children: [
            Row(
              children: [
                _renderAskingButton(
                  onPressed: () => Navigator.of(context).pop(),
                  label: '취소',
                  bgColor: BLACK_COLOR,
                  right: false,
                ),
                SizedBox(width: 12.w),
                _renderAskingButton(
                  onPressed: () {
                    ref
                        .read(notificationProvider.notifier)
                        .updateSinglePreference(
                          request: UpdatePreferenceRequest(
                            on: isOn,
                            alertTarget: alertTarget,
                          ),
                          currentPreferences: userPreferences,
                        );
                    if (alertTarget == AlertTarget.fighter) {
                      ref.invalidate(fighterDetailProvider);
                    } else if (alertTarget == AlertTarget.upcomingEvent) {
                      ref.invalidate(fightEventProvider);
                    }
                    Navigator.of(context).pop();
                  },
                  label: '확인',
                  bgColor: BLUE_COLOR,
                  right: true,
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _renderAskingButton({
    required VoidCallback onPressed,
    required String label,
    required Color bgColor,
    required bool right,
  }) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.only(
          left: !right ? 20.w : 0.w,
          right: right ? 20.w : 0.w,
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: bgColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadiusGeometry.circular(8.r),
            ),
          ),
          onPressed: onPressed,
          child: Text(
            label,
            style: context.text.bodyMedium?.copyWith(fontSize: 12.sp),
          ),
        ),
      ),
    );
  }
}
