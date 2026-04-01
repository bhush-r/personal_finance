class CurrencyFormatter {
  static String format(double amount) {
    if (amount.abs() >= 100000) {
      return '₹${(amount / 100000).toStringAsFixed(1)}L';
    } else if (amount.abs() >= 1000) {
      return '₹${(amount / 1000).toStringAsFixed(1)}K';
    }
    return '₹${amount.toStringAsFixed(2)}';
  }

  static String formatFull(double amount) => '₹${amount.toStringAsFixed(2)}';
}
