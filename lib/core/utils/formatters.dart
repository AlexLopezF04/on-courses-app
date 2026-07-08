import 'package:intl/intl.dart';

class Formatters {
  /// Formatea un número double a formato de moneda estadounidense (USD $12.34).
  static String formatCurrency(double amount) {
    final formatter = NumberFormat.simpleCurrency(decimalDigits: 2, name: 'USD');
    return formatter.format(amount);
  }

  /// Convierte una cadena de fecha ISO (del backend) a un formato legible local (DD/MM/AAAA HH:MM).
  static String formatDate(String dateStr) {
    try {
      final dateTime = DateTime.parse(dateStr);
      final formatter = DateFormat('dd/MM/yyyy HH:mm');
      return formatter.format(dateTime.toLocal());
    } catch (_) {
      return dateStr;
    }
  }
}
