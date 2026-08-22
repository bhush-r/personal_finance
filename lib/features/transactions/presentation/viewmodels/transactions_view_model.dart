import 'package:flutter/foundation.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/usecases/add_transaction.dart';
import '../../domain/usecases/delete_transaction.dart';
import '../../domain/usecases/filter_transactions.dart';
import '../../domain/usecases/get_transactions.dart';
import '../../domain/usecases/update_transaction.dart';

/// Presentation state for the transactions feature.
///
/// Views only render this state and forward user intents here. The view model
/// talks to use cases, keeping widgets independent from data sources.
class TransactionsViewModel extends ChangeNotifier {
  final GetTransactions _getTransactions;
  final AddTransaction _addTransaction;
  final UpdateTransaction _updateTransaction;
  final DeleteTransaction _deleteTransaction;
  final FilterTransactions _filterTransactions;

  TransactionsViewModel({
    required GetTransactions getTransactions,
    required AddTransaction addTransaction,
    required UpdateTransaction updateTransaction,
    required DeleteTransaction deleteTransaction,
    required FilterTransactions filterTransactions,
  })  : _getTransactions = getTransactions,
        _addTransaction = addTransaction,
        _updateTransaction = updateTransaction,
        _deleteTransaction = deleteTransaction,
        _filterTransactions = filterTransactions;

  List<Transaction> _transactions = const [];
  List<Transaction> get transactions => List.unmodifiable(_transactions);
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  String? _errorMessage;
  String? get errorMessage => _errorMessage;
  TransactionType? _selectedType;
  TransactionType? get selectedType => _selectedType;
  String _searchQuery = '';
  String get searchQuery => _searchQuery;
  String _sortBy = 'date_desc';

  double get income => _transactions
      .where((item) => item.type == TransactionType.income)
      .fold(0, (total, item) => total + item.amount);
  double get expenses => _transactions
      .where((item) => item.type == TransactionType.expense)
      .fold(0, (total, item) => total + item.amount);
  double get balance => income - expenses;

  Future<void> load() async {
    _setLoading(true);
    final result = await _getTransactions(NoParams());
    result.fold(
      (failure) => _errorMessage = failure.message,
      (items) {
        _transactions = items;
        _errorMessage = null;
        _applySort(notify: false);
      },
    );
    _setLoading(false);
  }

  Future<void> setType(TransactionType? type) async {
    _selectedType = type;
    await _applyFilters();
  }

  Future<void> setSearchQuery(String query) async {
    _searchQuery = query;
    await _applyFilters();
  }

  void sortBy(String value) {
    _sortBy = value;
    _applySort();
  }

  Future<String?> save(Transaction transaction, {required bool isEditing}) async {
    _setLoading(true);
    final result = isEditing
        ? await _updateTransaction(UpdateTransactionParams(transaction: transaction))
        : await _addTransaction(AddTransactionParams(transaction: transaction));
    String? error;
    result.fold((failure) => error = failure.message, (_) {});
    if (error == null) {
      await load();
    } else {
      _errorMessage = error;
      _setLoading(false);
    }
    return error;
  }

  Future<String?> delete(String id) async {
    _setLoading(true);
    final result = await _deleteTransaction(DeleteTransactionParams(id: id));
    String? error;
    result.fold((failure) => error = failure.message, (_) {});
    if (error == null) {
      await load();
    } else {
      _errorMessage = error;
      _setLoading(false);
    }
    return error;
  }

  Future<void> _applyFilters() async {
    _setLoading(true);
    final result = await _filterTransactions(FilterTransactionsParams(
      type: _selectedType,
      searchQuery: _searchQuery.trim().isEmpty ? null : _searchQuery.trim(),
    ));
    result.fold(
      (failure) => _errorMessage = failure.message,
      (items) {
        _transactions = items;
        _errorMessage = null;
        _applySort(notify: false);
      },
    );
    _setLoading(false);
  }

  void _applySort({bool notify = true}) {
    _transactions = [..._transactions]..sort((a, b) {
      switch (_sortBy) {
        case 'date_asc': return a.date.compareTo(b.date);
        case 'amount_desc': return b.amount.compareTo(a.amount);
        case 'amount_asc': return a.amount.compareTo(b.amount);
        default: return b.date.compareTo(a.date);
      }
    });
    if (notify) notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
