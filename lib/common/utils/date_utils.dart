import 'dart:developer';

class CustomDateUtils {
  static DateTime stringToDateTime(String value) {
    return DateTime.parse(value);
  }

  static String formatDurationToHHMM(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  }

  static String formatDurationToMMSS(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes분 $seconds초';
  }

  static String formatDateWithYear(DateTime datetime) {
    return '${datetime.year}.${datetime.month.toString().padLeft(2, '0')}.${datetime.day.toString().padLeft(2, '0')}';
  }

  static String formatDateWithoutYear(DateTime datetime) {
    return '${datetime.month.toString().padLeft(2, '0')}.${datetime.day.toString().padLeft(2, '0')}';
  }

  static String formatDateTime(DateTime datetime) {
    return '${datetime.month.toString().padLeft(2, '0')}.${datetime.day.toString().padLeft(2, '0')} ${datetime.hour.toString().padLeft(2, '0')}:${datetime.minute.toString().padLeft(2, '0')}';
  }

  static bool isBettingRestricted(DateTime eventDate) {
    final nowKst = DateTime.now().toUtc().add(const Duration(hours: 9));
    final todayKst = DateTime(nowKst.year, nowKst.month, nowKst.day);
    final eventDay = DateTime(eventDate.year, eventDate.month, eventDate.day);
    return _isThisWeek(eventDay, todayKst) && _isTodayWeekend(todayKst);
  }

  static bool _isThisWeek(DateTime date, DateTime todayKst) {
    // previousOrSame(MONDAY): weekday 1=월 ~ 7=일
    final startOfWeek = todayKst.subtract(Duration(days: todayKst.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    return !date.isBefore(startOfWeek) && !date.isAfter(endOfWeek);
  }

  static bool _isTodayWeekend(DateTime todayKst) {
    return todayKst.weekday == DateTime.saturday ||
        todayKst.weekday == DateTime.sunday;
  }
}
