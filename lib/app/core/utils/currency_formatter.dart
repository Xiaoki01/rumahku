import 'package:intl/intl.dart';

class CurrencyFormatter {
  static String format(dynamic value) {
    if (value == null) return 'Rp 0';

    try {
      final number = value is String ? double.parse(value) : value;
      final formatter = NumberFormat.currency(
        locale: 'id_ID',
        symbol: 'Rp ',
        decimalDigits: 0,
      );
      return formatter.format(number);
    } catch (e) {
      return 'Rp 0';
    }
  }
}
