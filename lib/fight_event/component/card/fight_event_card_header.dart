import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mma_flutter/alert/model/update_alert_request.dart';
import 'package:mma_flutter/alert/repository/alert_repository.dart';
import 'package:mma_flutter/common/const/colors.dart';
import 'package:mma_flutter/common/utils/date_utils.dart';
import 'package:mma_flutter/fight_event/provider/fight_event_alert_provider.dart';
import 'package:mma_flutter/main.dart';

class FightEventCardHeader extends ConsumerWidget {
  final int eventId;
  final String eventName;
  final DateTime displayDate;
  final bool isUpcoming;
  final bool useAlertIcon; // only available in FightEventScreen
  final bool fightEventScreen;

  const FightEventCardHeader({
    super.key,
    required this.eventId,
    required this.eventName,
    required this.displayDate,
    required this.isUpcoming,
    this.useAlertIcon = false,
    this.fightEventScreen = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOn = ref.watch(eventAlertStatusProvider(eventId));

    return Padding(
      padding: EdgeInsets.only(top: 8.h, bottom: 4.h),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  _renderShortEventName(eventName),
                  style: context.text.bodySmall?.copyWith(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                  softWrap: true,
                  textAlign:
                      fightEventScreen ? TextAlign.center : TextAlign.start,
                ),
              ),
              if (useAlertIcon)
                GestureDetector(
                  onTap: () {
                    ref
                        .read(alertRepositoryProvider)
                        .updateSingleAlert(
                          request: UpdateAlertRequest(
                            targetId: eventId,
                            on: !isOn,
                            alertTarget: AlertTarget.upcomingEvent,
                          ),
                        );
                    ref.read(eventAlertStatusProvider(eventId).notifier).state =
                        !isOn;
                  },
                  child: Icon(
                    isOn ? FontAwesomeIcons.solidBell : FontAwesomeIcons.bell,
                    color: GREY_COLOR,
                    size: 24.sp,
                  ),
                ),
            ],
          ),
          Align(
            alignment:
                fightEventScreen ? Alignment.center : Alignment.centerLeft,
            child: Text(
              CustomDateUtils.formatDateWithYear(displayDate),
              style: context.text.bodySmall?.copyWith(
                color: context.colors.subText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _renderShortEventName(String eventName) {
    String keyword = 'UFC Fight Night';
    return eventName.contains(keyword)
        ? eventName.replaceAll(keyword, 'UFN')
        : eventName;
  }
}
