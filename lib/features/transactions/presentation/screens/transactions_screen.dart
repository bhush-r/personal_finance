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
import '../../../../shared/widgets/loading_shimmer_skeleton.dart';
import '../../../../shared/dialogs/delete_confirmation_dialog.dart';
import '../../../../shared/widgets/fade_in_animation.dart';

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
    // ✅ FIXED: Use WidgetsBinding to delay BLoC access
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<TransactionBloc>().add(const LoadTransactions());
      }
    });
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
      appBar: AppBar(
        title: Text(
          'Transactions',
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/transactions/add', extra: null),
        child: const Icon(Iconsax.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TransactionFilterBar(
              selectedType: _selectedType,
              searchQuery: _searchQuery,
              onTypeChanged: (type) {
                setState(() => _selectedType = type);
                _applyFilter();
              },
              onSearchChanged: (query) {
                setState(() => _searchQuery = query);
                _applyFilter();
              },
            ),
          ),
          Expanded(
            child: BlocListener<TransactionBloc, TransactionState>(
              listener: (context, state) {
                if (state is TransactionOperationSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
                if (state is TransactionError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: BlocBuilder<TransactionBloc, TransactionState>(
                builder: (context, state) {
                  if (state is TransactionLoading) {
                    return const TransactionsLoadingSkeleton();
                  }
                  if (state is TransactionError) {
                    return Center(
                      child: FadeInAnimation(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Iconsax.warning_2,
                              size: 64,
                              color: Colors.red.shade300,
                            ),
                            const SizedBox(height: 16),
                            Text(state.message),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: () {
                                context.read<TransactionBloc>()
                                    .add(const LoadTransactions());
                              },
                              icon: const Icon(Iconsax.refresh),
                              label: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  if (state is TransactionLoaded) {
                    if (state.transactions.isEmpty) {
                      return const FadeInAnimation(
                        child: EmptyTransactionState(),
                      );
                    }
                    final grouped = _groupByDate(state.transactions);
                    return RefreshIndicator(
                      onRefresh: () async {
                        context.read<TransactionBloc>().add(
                          const LoadTransactions(),
                        );
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: grouped.length,
                        itemBuilder: (context, i) {
                          final entry = grouped[i];
                          if (entry is String) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Text(
                                entry,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            );
                          } else {
                            final txn = entry as Transaction;
                            return FadeInAnimation(
                              child: TransactionTile(
                                transaction: txn,
                                onTap: () => context.push(
                                  '/transactions/add',
                                  extra: txn,
                                ),
                                onDelete: () {
                                  showDeleteConfirmation(
                                    context: context,
                                    title: 'Delete Transaction',
                                    message:
                                    'Are you sure you want to delete this transaction? This action cannot be undone.',
                                    itemName:
                                    '${txn.category.name} - ₹${txn.amount}',
                                    onConfirm: () {
                                      context.read<TransactionBloc>().add(
                                        DeleteTransactionEvent(id: txn.id),
                                      );
                                    },
                                  );
                                },
                              ),
                            );
                          }
                        },
                      ),
                    );
                  }
                  return const EmptyTransactionState();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Group transactions by date
  List<dynamic> _groupByDate(List<Transaction> transactions) {
    final List<dynamic> result = [];
    String? lastHeader;
    for (final t in transactions) {
      final header = DateFormatter.groupHeader(t.date);
      if (header != lastHeader) {
        result.add(header);
        lastHeader = header;
      }
      result.add(t);
    }
    return result;
  }
}