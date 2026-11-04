import 'package:intl/intl.dart';

class DateFormatter {
  // Format DateTime to ISO string "YYYY-MM-DD"
  static String toIsoDate(DateTime date) {
    return date.toIso8601String().split('T').first;
  }

  // Format "YYYY-MM-DD" to human readable "dd MMM yyyy"
  static String formatShortDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (_) {
      return dateStr;
    }
  }

  // Format "YYYY-MM-DD" to full date "EEEE, d MMMM yyyy"
  static String formatFullDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('EEEE, d MMMM yyyy').format(date);
    } catch (_) {
      return dateStr;
    }
  }

  // Get current day name (e.g. "Monday")
  static String getCurrentDayName() {
    return DateFormat('EEEE').format(DateTime.now());
  }

  // Check if a date string is before today (midnight)
  static bool isBeforeToday(String dateStr) {
    try {
      final targetDate = DateTime.parse(dateStr);
      final today = DateTime.now();
      final cleanToday = DateTime(today.year, today.month, today.day);
      final cleanTarget = DateTime(targetDate.year, targetDate.month, targetDate.day);
      return cleanTarget.isBefore(cleanToday);
    } catch (_) {
      return false;
    }
  }
}
