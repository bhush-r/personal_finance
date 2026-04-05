import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../domain/entities/transaction.dart';
import '../bloc/transaction_bloc.dart';
import '../bloc/transaction_event.dart';
import '../bloc/transaction_state.dart';

import '../widgets/empty_transaction_state.dart';
import '../widgets/transaction_filter_bar.dart'
    hide TransactionsLoadingSkeleton, EmptyTransactionState;

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

class _TransactionsScreenState extends State<TransactionsScreen>
    with TickerProviderStateMixin {
  TransactionType? _selectedType;
  String _searchQuery = '';

  late AnimationController _fabController;
  late AnimationController _summaryController;
  final ScrollController _scrollController = ScrollController();
  bool _showFab = true;

  @override
  void initState() {
    super.initState();
    context.read<TransactionBloc>().add(const LoadTransactions());

    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..forward();

    _summaryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scrollController.addListener(_handleScroll);
  }

  void _handleScroll() {
    // Hide FAB when scrolling down, show when scrolling up
    if (_scrollController.position.userScrollDirection == ScrollDirection.reverse) {
      if (_showFab) {
        setState(() => _showFab = false);
        _fabController.reverse();
      }
    } else if (_scrollController.position.userScrollDirection == ScrollDirection.forward) {
      if (!_showFab) {
        setState(() => _showFab = true);
        _fabController.forward();
      }
    }
  }

  @override
  void dispose() {
    _fabController.dispose();
    _summaryController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _applyFilter() {
    HapticFeedback.selectionClick();
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

      // Animated FAB with scale transition
      floatingActionButton: ScaleTransition(
        scale: CurvedAnimation(
          parent: _fabController,
          curve: Curves.easeInOutBack,
        ),
        child: FloatingActionButton.extended(
          backgroundColor: Colors.black,
          elevation: 4,
          onPressed: () {
            HapticFeedback.mediumImpact();
            context.push('/transactions/add');
          },
          icon: const Icon(Iconsax.add),
          label: const Text('Add'),
        ),
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
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Transactions",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),

            /// Animated Sort Menu
            Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              elevation: 0,
              child: PopupMenuButton<String>(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 8,
                offset: const Offset(0, 50),
                onSelected: (value) {
                  HapticFeedback.selectionClick();
                  context.read<TransactionBloc>().add(
                    SortTransactionsEvent(sortBy: value),
                  );
                },
                itemBuilder: (_) => [
                  _buildMenuItem(Iconsax.arrow_down, 'Latest', 'date_desc'),
                  _buildMenuItem(Iconsax.arrow_up, 'Oldest', 'date_asc'),
                  _buildMenuItem(Iconsax.arrow_3, 'High', 'amount_desc'),
                  _buildMenuItem(Iconsax.arrow_down_1, 'Low', 'amount_asc'),
                ],
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: const Icon(Iconsax.sort, size: 22),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<String> _buildMenuItem(IconData icon, String label, String value) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 12),
          Text(label),
        ],
      ),
    );
  }

  Widget _buildFilter() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Padding(
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
      ),
    );
  }

  Widget _buildList() {
    return BlocConsumer<TransactionBloc, TransactionState>(
      listener: (context, state) {
        if (state is TransactionLoaded) {
          _summaryController.forward(from: 0);
        }
      },
      builder: (context, state) {
        if (state is TransactionLoading) {
          return const TransactionsLoadingSkeleton();
        }

        if (state is TransactionLoaded) {
          final txns = state.transactions;

          if (txns.isEmpty) {
            return _buildEmptyState();
          }

          return Column(
            children: [
              _buildSummary(txns),
              Expanded(
                child: _buildTransactionList(txns),
              ),
            ],
          );
        }

        if (state is TransactionError) {
          return _buildErrorState(state.message);
        }

        return const SizedBox();
      },
    );
  }

  Widget _buildTransactionList(List<Transaction> txns) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      itemCount: txns.length,
      itemBuilder: (_, i) {
        final txn = txns[i];

        // Staggered animation
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 300 + (i * 50)),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 30 * (1 - value)),
                child: child,
              ),
            );
          },
          child: TransactionTile(
            transaction: txn,
            onTap: () {
              HapticFeedback.lightImpact();
              context.push('/transactions/add', extra: txn);
            },
            onDelete: () => _showDeleteDialog(txn),
          ),
        );
      },
    );
  }

  void _showDeleteDialog(Transaction txn) {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Transaction'),
        content: const Text('Are you sure you want to delete this transaction?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              HapticFeedback.heavyImpact();
              context.read<TransactionBloc>().add(
                DeleteTransactionEvent(id: txn.id),
              );

              // Show snackbar feedback
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Transaction deleted'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  action: SnackBarAction(
                    label: 'Undo',
                    onPressed: () {
                      // Implement undo logic
                    },
                  ),
                ),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.scale(
            scale: 0.8 + (0.2 * value),
            child: child,
          ),
        );
      },
      child: const EmptyTransactionState(),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.danger, size: 64, color: Colors.red.shade300),
          const SizedBox(height: 16),
          Text(
            'Oops! Something went wrong',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(color: Colors.grey.shade500),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              context.read<TransactionBloc>().add(const LoadTransactions());
            },
            icon: const Icon(Iconsax.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Animated Summary with number transitions
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

    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, -0.3),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _summaryController,
        curve: Curves.easeOutCubic,
      )),
      child: FadeTransition(
        opacity: _summaryController,
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.black, Colors.grey.shade800],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _animatedItem("Balance", balance, Colors.white),
              _animatedItem("Income", income, Colors.green.shade300),
              _animatedItem("Expense", expense, Colors.red.shade300),
            ],
          ),
        ),
      ),
    );
  }

  Widget _animatedItem(String label, double value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: value),
          duration: const Duration(milliseconds: 1000),
          curve: Curves.easeOutCubic,
          builder: (context, animatedValue, child) {
            return Text(
              CurrencyFormatter.format(animatedValue),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: color,
              ),
            );
          },
        ),
      ],
    );
  }
}