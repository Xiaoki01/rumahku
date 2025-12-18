import 'package:intl/intl.dart';

class DateFormatter {
  static String formatDate(String? date) {
    if (date == null || date.isEmpty) return '-';
    try {
      final parsed = DateTime.parse(date);
      return DateFormat('dd MMM yyyy', 'id_ID').format(parsed);
    } catch (e) {
      return date;
    }
  }

  static String formatDateTime(String? dateTime) {
    if (dateTime == null || dateTime.isEmpty) return '-';
    try {
      final parsed = DateTime.parse(dateTime);
      return DateFormat('dd MMM yyyy HH:mm', 'id_ID').format(parsed);
    } catch (e) {
      return dateTime;
    }
  }
}
