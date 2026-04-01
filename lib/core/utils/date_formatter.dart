import 'package:intl/intl.dart';

class DateFormatter {
  static String format(DateTime date) => DateFormat('dd MMM yyyy').format(date);
  static String formatShort(DateTime date) => DateFormat('dd MMM').format(date);
  static String formatMonthYear(DateTime date) => DateFormat('MMM yyyy').format(date);
  static String formatDay(DateTime date) => DateFormat('EEEE').format(date);
  static String groupHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(date.year, date.month, date.day);
    if (d == today) return 'Today';
    if (d == today.subtract(const Duration(days: 1))) return 'Yesterday';
    return DateFormat('dd MMM yyyy').format(date);
  }
}
