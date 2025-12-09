class DateTimeHelper {
  static bool isRestaurantOpen(String openTime, String closeTime, List<String> openDays) {
    DateTime now = DateTime.now();

    final today = _getDayName(now.weekday);
    if (!openDays.contains(today)) return false;

    final open = _parseTime(openTime, now);
    DateTime close = _parseTime(closeTime, now);

    // لو وقت الإغلاق قبل وقت الفتح => يمتد لليوم التالي
    if (close.isBefore(open)) {
      close = close.add(const Duration(days: 1));

      // لو الوقت الحالي قبل الفتح => بعد منتصف الليل
      if (now.isBefore(open)) {
        now = now.add(const Duration(days: 1)); // تعديل حقيقي
      }
    }

    return now.isAfter(open) && now.isBefore(close);
  }

  static String _getDayName(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Monday';
      case DateTime.tuesday:
        return 'Tuesday';
      case DateTime.wednesday:
        return 'Wednesday';
      case DateTime.thursday:
        return 'Thursday';
      case DateTime.friday:
        return 'Friday';
      case DateTime.saturday:
        return 'Saturday';
      case DateTime.sunday:
        return 'Sunday';
      default:
        return '';
    }
  }

  static DateTime _parseTime(String time, DateTime baseDate) {
    final parts = time.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    return DateTime(baseDate.year, baseDate.month, baseDate.day, hour, minute);
  }
}
