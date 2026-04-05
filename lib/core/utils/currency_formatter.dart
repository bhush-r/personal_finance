import 'package:intl/intl.dart';

class CurrencyFormatter {
  static String format(double amount, {String currency = '₹'}) {
    final formatter = NumberFormat('#,##,##0.00', 'en_IN');
    return '$currency${formatter.format(amount)}';
  }

  static String formatCompact(double amount, {String currency = '₹'}) {
    if (amount >= 1000000) {
      return '$currency${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '$currency${(amount / 1000).toStringAsFixed(1)}K';
    }
    return '$currency${amount.toStringAsFixed(0)}';
  }

  static String formatSimple(double amount) {
    return amount.toStringAsFixed(2);
  }
}