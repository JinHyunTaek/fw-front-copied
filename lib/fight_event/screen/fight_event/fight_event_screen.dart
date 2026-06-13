import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:mma_flutter/common/component/retry_loading/custom_circular_progess_indicator.dart';
import 'package:mma_flutter/common/component/retry_loading/retry_button.dart';
import 'package:mma_flutter/common/const/colors.dart';
import 'package:mma_flutter/fight_event/component/card/fight_event_card_header.dart';
import 'package:mma_flutter/fight_event/component/card/fight_event_card_list.dart';
import 'package:mma_flutter/fight_event/provider/fight_event_provider.dart';
import 'package:mma_flutter/fight_event/screen/fight_event/component/fight_event_date_picker.dart';
import 'package:mma_flutter/main.dart';
import 'package:table_calendar/table_calendar.dart';

class FightEventScreen extends ConsumerStatefulWidget {
  const FightEventScreen({super.key});

  @override
  ConsumerState<FightEventScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends ConsumerState<FightEventScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  DateTime? _datePickerDay;

  @override
  Widget build(BuildContext context) {
    final fightDays = ref.watch(fightDaysProvider((_focusedDay.year, _focusedDay.month)));
    final defaultBoxDecoration = BoxDecoration(
      borderRadius: BorderRadius.circular(8.r),
    );

    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: TableCalendar(
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          leftChevronIcon: Icon(
            Icons.chevron_left,
            color: context.colors.onSurface,
          ),
          rightChevronIcon: Icon(
            Icons.chevron_right,
            color: context.colors.onSurface,
          ),
          titleTextStyle: TextStyle(
            color: context.colors.onSurface,
            fontSize: 17.sp,
            fontWeight: FontWeight.w400,
          ),
        ),
        locale: 'ko_KR',
        daysOfWeekHeight: 22.h,
        focusedDay: _focusedDay,
        firstDay: DateTime(1950),
        lastDay: DateTime(DateTime.now().year + 2),
        calendarStyle: CalendarStyle(
          todayDecoration: defaultBoxDecoration,
          outsideDecoration: defaultBoxDecoration.copyWith(
            border: Border.all(color: Colors.transparent),
          ),
          defaultDecoration: defaultBoxDecoration,
          weekendDecoration: defaultBoxDecoration,
          defaultTextStyle: context.text.bodyMedium!,
          weekendTextStyle: context.text.bodyMedium!,
          weekNumberTextStyle: context.text.bodyMedium!,
          todayTextStyle: context.text.bodyMedium!.copyWith(
            fontSize: 15.sp,
            color: BLUE_COLOR,
          ),
          selectedDecoration: defaultBoxDecoration.copyWith(
            color: BLUE_COLOR,
          ),
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: context.text.bodyMedium!.copyWith(
            color: context.colors.subText,
          ),
          weekendStyle: context.text.bodyMedium!.copyWith(
            color: context.colors.subText,
          ),
        ),
        onDaySelected: onDaySelected,
        selectedDayPredicate: selectedDayPredicate,
        onHeaderTapped: (focusedDay) {
          showCupertinoModalPopup(
            context: context,
            builder:
                (_) => FightEventDatePicker(
                  onDateTimeChanged: (val) {
                    _datePickerDay = val;
                  },
                  focusedDay: _focusedDay,
                  datePickerButtonPressed: () {
                    if (_datePickerDay != null) {
                      onDaySelected(_datePickerDay!, _datePickerDay!);
                    }
                  },
                ),
          );
        },
        onPageChanged: (focusedDay) {
          setState(() => _focusedDay = focusedDay);
        },
        eventLoader: (date) {
          final days = fightDays.asData?.value;
          if(days == null) return [];
          return days.contains(date.day) ? [true] : [];
        },
        calendarBuilders: CalendarBuilders(
          markerBuilder: (context, day, events) {
            if(events.isEmpty || day == _selectedDay || day.month != _focusedDay.month) return const SizedBox.shrink();
            return Container(
              width: 4.w,
              height: 4.h,
              decoration: const BoxDecoration(
                color: BLUE_COLOR,
                shape: BoxShape.circle,
              ),
            );
          },
        ),
      ),
    );
  }

  void onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });
    showSchedule();
  }

  bool selectedDayPredicate(DateTime day) {
    return day.isAtSameMomentAs(_selectedDay);
  }

  showSchedule() {
    final dateKey = formatDateKey(_selectedDay);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showModalBottomSheet(
        constraints: BoxConstraints(
          minWidth: MediaQuery.of(context).size.width,
        ),
        backgroundColor: context.colors.box,
        context: context,
        isScrollControlled: true,
        enableDrag: true,
        showDragHandle: true,
        builder: (context) {
          return Consumer(
            builder: (context, ref, child) {
              final state = ref.watch(fightEventProvider(dateKey));
              return DraggableScrollableSheet(
                expand: false,
                initialChildSize: 0.4,
                minChildSize: 0.4,
                maxChildSize: 1.0,
                builder: (context, scrollController) {
                  return state.when(
                    loading: () => CustomCircularProgressIndicator(),
                    error:
                        (_, __) => RetryButton(
                          onRetry:
                              () => ref.invalidate(fightEventProvider(dateKey)),
                        ),
                    data: (data) {
                      if (data == null || data.isEmpty) {
                        return Text(
                          '일정이 없습니다.',
                          style: context.text.bodyMedium?.copyWith(
                            color: context.colors.onSurface,
                          ),
                        );
                      }
                      return SafeArea(
                        child: SingleChildScrollView(
                          controller: scrollController,
                          physics: AlwaysScrollableScrollPhysics(),
                          child: SizedBox(
                            width: 362.w,
                            child: Column(
                              children:
                                  data
                                      .map(
                                        (event) => Column(
                                          children: [
                                            FightEventCardHeader(
                                              eventId: event.id,
                                              eventName: event.name,
                                              displayDate: event.displayDate,
                                              isUpcoming: event.upcoming,
                                              useAlertIcon: event.upcoming && event.mainCardDateTimeInfo != null,
                                              fightEventScreen: true,
                                            ),
                                            FightEventCardList(fe: event),
                                          ],
                                        ),
                                      )
                                      .toList(),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      );
    });
  }
}

String formatDateKey(DateTime date) => DateFormat('yyyy-MM-dd').format(date);
