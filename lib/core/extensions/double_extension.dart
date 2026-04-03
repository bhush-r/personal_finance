extension DoubleExtension on double {
  String get toCurrency => '₹${toStringAsFixed(2)}';
  String get toCurrencyCompact {
    if (abs() >= 100000) return '₹${(this / 100000).toStringAsFixed(1)}L';
    if (abs() >= 1000) return '₹${(this / 1000).toStringAsFixed(1)}K';
    return '₹${toStringAsFixed(0)}';
  }
}