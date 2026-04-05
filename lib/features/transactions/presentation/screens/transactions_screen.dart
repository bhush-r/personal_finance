import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../domain/entities/transaction.dart';
import '../bloc/transaction_bloc.dart';
import '../bloc/transaction_event.dart';
import '../bloc/transaction_state.dart';

import '../widgets/empty_transaction_state.dart';
import '../widgets/transaction_filter_bar.dart';
import '../widgets/transaction_tile.dart';

import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/widgets/loading_shimmer_skeleton.dart';
import '../../../../shared/dialogs/delete_confirmation_dialog.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  TransactionType? _selectedType;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    context.read<TransactionBloc>().add(const LoadTransactions());
  }

  void _applyFilter() {
    context.read<TransactionBloc>().add(
      FilterTransactionsEvent(
        type: _selectedType,
        searchQuery: _searchQuery.isEmpty ? null : _searchQuery,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        onPressed: () => context.push('/transactions/add'),
        child: const Icon(Iconsax.add),
      ),

      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildFilter(),
            Expanded(child: _buildList()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Transactions",
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),

          /// 🔥 SORT MENU
          PopupMenuButton<String>(
            onSelected: (value) {
              context.read<TransactionBloc>().add(
                SortTransactionsEvent(sortBy: value),
              );
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'date_desc', child: Text('Latest')),
              const PopupMenuItem(value: 'date_asc', child: Text('Oldest')),
              const PopupMenuItem(value: 'amount_desc', child: Text('High')),
              const PopupMenuItem(value: 'amount_asc', child: Text('Low')),
            ],
            child: const Icon(Iconsax.filter),
          ),
        ],
      ),
    );
  }

  Widget _buildFilter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TransactionFilterBar(
        selectedType: _selectedType,
        searchQuery: _searchQuery,
        onTypeChanged: (type) {
          setState(() => _selectedType = type);
          _applyFilter();
        },
        onSearchChanged: (q) {
          setState(() => _searchQuery = q);
          _applyFilter();
        },
      ),
    );
  }

  Widget _buildList() {
    return BlocBuilder<TransactionBloc, TransactionState>(
      builder: (context, state) {
        if (state is TransactionLoading) {
          return const TransactionsLoadingSkeleton();
        }

        if (state is TransactionLoaded) {
          final txns = state.transactions;

          if (txns.isEmpty) {
            return const EmptyTransactionState();
          }

          return Column(
            children: [
              _buildSummary(txns),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: txns.length,
                  itemBuilder: (_, i) {
                    final txn = txns[i];

                    return TransactionTile(
                      transaction: txn,
                      onTap: () => context.push(
                        '/transactions/add',
                        extra: txn,
                      ),
                      onDelete: () {
                        context.read<TransactionBloc>().add(
                          DeleteTransactionEvent(id: txn.id),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        }

        if (state is TransactionError) {
          return Center(child: Text(state.message));
        }

        return const SizedBox();
      },
    );
  }

  /// 🔥 SUMMARY
  Widget _buildSummary(List<Transaction> txns) {
    double income = 0;
    double expense = 0;

    for (var t in txns) {
      if (t.type == TransactionType.income) {
        income += t.amount;
      } else {
        expense += t.amount;
      }
    }

    final balance = income - expense;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _item("Balance", balance),
          _item("Income", income),
          _item("Expense", expense),
        ],
      ),
    );
  }

  Widget _item(String label, double value) {
    return Column(
      children: [
        Text(label),
        Text(
          CurrencyFormatter.format(value),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}