extension DateExtension on DateTime {
  bool isSameDay(DateTime other) =>
      year == other.year && month == other.month && day == other.day;

  bool isSameWeek(DateTime other) {
    final thisMon = subtract(Duration(days: weekday - 1));
    final otherMon = other.subtract(Duration(days: other.weekday - 1));
    return thisMon.isSameDay(otherMon);
  }

  bool isSameMonth(DateTime other) =>
      year == other.year && month == other.month;

  DateTime get startOfDay => DateTime(year, month, day);

  DateTime get startOfMonth => DateTime(year, month, 1);

  DateTime get startOfWeek => subtract(Duration(days: weekday - 1));
}
