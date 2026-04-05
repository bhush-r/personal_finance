import 'package:equatable/equatable.dart';

class Currency extends Equatable {
  final String code; // 'INR', 'USD', etc.
  final String symbol; // '₹', '$', etc.
  final String name; // 'Indian Rupee', 'US Dollar'
  final String country; // 'India', 'United States'
  final double exchangeRate; // Exchange rate to USD

  const Currency({
    required this.code,
    required this.symbol,
    required this.name,
    required this.country,
    required this.exchangeRate,
  });

  @override
  List<Object?> get props => [code, symbol, name, country, exchangeRate];
}