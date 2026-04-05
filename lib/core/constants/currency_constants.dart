import '../../features/settings/domain/entities/currency.dart';

class CurrencyConstants {
  static const List<Currency> supportedCurrencies = [
    // Popular Currencies
    Currency(
      code: 'INR',
      symbol: '₹',
      name: 'Indian Rupee',
      country: 'India',
      exchangeRate: 1.0, // Base currency
    ),
    Currency(
      code: 'USD',
      symbol: '\$',
      name: 'US Dollar',
      country: 'United States',
      exchangeRate: 0.012, // 1 INR = 0.012 USD
    ),
    Currency(
      code: 'EUR',
      symbol: '€',
      name: 'Euro',
      country: 'European Union',
      exchangeRate: 0.011,
    ),
    Currency(
      code: 'GBP',
      symbol: '£',
      name: 'British Pound',
      country: 'United Kingdom',
      exchangeRate: 0.010,
    ),
    Currency(
      code: 'AUD',
      symbol: 'A\$',
      name: 'Australian Dollar',
      country: 'Australia',
      exchangeRate: 0.018,
    ),
    Currency(
      code: 'CAD',
      symbol: 'C\$',
      name: 'Canadian Dollar',
      country: 'Canada',
      exchangeRate: 0.016,
    ),
    Currency(
      code: 'SGD',
      symbol: 'S\$',
      name: 'Singapore Dollar',
      country: 'Singapore',
      exchangeRate: 0.016,
    ),
    Currency(
      code: 'HKD',
      symbol: 'HK\$',
      name: 'Hong Kong Dollar',
      country: 'Hong Kong',
      exchangeRate: 0.094,
    ),
    Currency(
      code: 'JPY',
      symbol: '¥',
      name: 'Japanese Yen',
      country: 'Japan',
      exchangeRate: 1.27,
    ),
    Currency(
      code: 'CHF',
      symbol: 'CHF',
      name: 'Swiss Franc',
      country: 'Switzerland',
      exchangeRate: 0.011,
    ),
  ];

  static Currency getDefaultCurrency() => supportedCurrencies[0]; // INR

  static Currency getCurrencyByCode(String code) {
    try {
      return supportedCurrencies.firstWhere((c) => c.code == code);
    } catch (e) {
      return getDefaultCurrency();
    }
  }

  static List<String> getCurrencyCodes() =>
      supportedCurrencies.map((c) => c.code).toList();

  static List<String> getCurrencySymbols() =>
      supportedCurrencies.map((c) => c.symbol).toList();
}