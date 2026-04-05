import 'package:intl/intl.dart';
import '../../constants/currency_constants.dart';
import '../constants/currency_constants.dart';

class CurrencyFormatter {
  static String format(
      double amount, {
        String? currencyCode,
      }) {
    // Get currency symbol from code
    final currency = currencyCode != null
        ? CurrencyConstants.getCurrencyByCode(currencyCode)
        : CurrencyConstants.getDefaultCurrency();

    final formatter = NumberFormat('#,##,##0.00', 'en_IN');
    return '${currency.symbol}${formatter.format(amount)}';
  }

  static String formatCompact(
      double amount, {
        String? currencyCode,
      }) {
    final currency = currencyCode != null
        ? CurrencyConstants.getCurrencyByCode(currencyCode)
        : CurrencyConstants.getDefaultCurrency();

    if (amount >= 1000000) {
      return '${currency.symbol}${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${currency.symbol}${(amount / 1000).toStringAsFixed(1)}K';
    }
    return '${currency.symbol}${amount.toStringAsFixed(0)}';
  }

  static String formatSimple(double amount) {
    return amount.toStringAsFixed(2);
  }

  /// Convert between currencies
  static double convertCurrency(
      double amount,
      String fromCurrency,
      String toCurrency,
      ) {
    final from = CurrencyConstants.getCurrencyByCode(fromCurrency);
    final to = CurrencyConstants.getCurrencyByCode(toCurrency);

    // Convert to USD first, then to target currency
    final amountInUSD = amount * from.exchangeRate;
    return amountInUSD / to.exchangeRate;
  }

  /// Get exchange rate between two currencies
  static double getExchangeRate(String from, String to) {
    final fromCurr = CurrencyConstants.getCurrencyByCode(from);
    final toCurr = CurrencyConstants.getCurrencyByCode(to);

    return (fromCurr.exchangeRate / toCurr.exchangeRate);
  }
}