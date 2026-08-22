import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/financial_summary.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedRange = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<DashboardBloc>().add(const LoadDashboard());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090D14),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/transactions/add'),
        backgroundColor: const Color(0xFF3B82F6),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SafeArea(
        child: BlocBuilder<DashboardBloc, DashboardState>(
          builder: (context, state) {
            if (state is DashboardLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is DashboardError) {
              return _ErrorState(
                message: state.message,
                onRetry: () =>
                    context.read<DashboardBloc>().add(const LoadDashboard()),
              );
            }

            if (state is! DashboardLoaded) {
              return const SizedBox.shrink();
            }

            return RefreshIndicator(
              color: const Color(0xFF3B82F6),
              onRefresh: () async {
                context.read<DashboardBloc>().add(const RefreshDashboard());
              },
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                children: [
                  _buildHeader(),
                  const SizedBox(height: 20),
                  _BalanceCard(summary: state.summary),
                  const SizedBox(height: 18),
                  _RangeSelector(
                    selectedIndex: _selectedRange,
                    onChanged: (value) => setState(() => _selectedRange = value),
                  ),
                  const SizedBox(height: 18),
                  _SpendingByCategoryCard(summary: state.summary),
                  const SizedBox(height: 22),
                  _RecentTransactionsSection(transactions: state.recentTransactions),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Dashboard',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 34,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat('MMMM yyyy').format(DateTime.now()),
                style: const TextStyle(color: Color(0xFF7C8698), fontSize: 15),
              ),
            ],
          ),
        ),
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFF141A24),
            borderRadius: BorderRadius.circular(22),
          ),
          child: const Icon(Iconsax.notification, color: Colors.white70, size: 20),
        ),
      ],
    );
  }
}

class _BalanceCard extends StatelessWidget {
  final FinancialSummary summary;

  const _BalanceCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF4E89FF), Color(0xFF3F76E8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Total Balance',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            CurrencyFormatter.format(summary.balance),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 38,
            ),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              _BalanceMeta(
                label: 'Income',
                amount: summary.totalIncome,
                icon: Iconsax.arrow_up_2,
              ),
              const SizedBox(width: 30),
              _BalanceMeta(
                label: 'Expenses',
                amount: summary.totalExpense,
                icon: Iconsax.arrow_down_2,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BalanceMeta extends StatelessWidget {
  final String label;
  final double amount;
  final IconData icon;

  const _BalanceMeta({
    required this.label,
    required this.amount,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: Colors.white70),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          CurrencyFormatter.format(amount),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 21,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _RangeSelector extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const _RangeSelector({
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    const labels = ['Week', 'Month', 'Year'];

    return Row(
      children: List.generate(labels.length, (index) {
        final selected = index == selectedIndex;
        return Padding(
          padding: const EdgeInsets.only(right: 10),
          child: GestureDetector(
            onTap: () => onChanged(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: selected ? const Color(0xFF3B82F6) : const Color(0xFF151C27),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                labels[index],
                style: TextStyle(
                  color: selected ? Colors.white : const Color(0xFF9AA3B3),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _SpendingByCategoryCard extends StatelessWidget {
  final FinancialSummary summary;

  const _SpendingByCategoryCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    final categoryEntries = summary.categoryBreakdown.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topCategories = categoryEntries.take(4).toList();
    final total = topCategories.fold<double>(0, (sum, e) => sum + e.value);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF101722),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Spending by Category',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 24,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 220,
            child: topCategories.isEmpty
                ? const Center(
                    child: Text(
                      'No spending data available',
                      style: TextStyle(color: Color(0xFF8A93A4)),
                    ),
                  )
                : PieChart(
                    PieChartData(
                      sectionsSpace: 4,
                      centerSpaceRadius: 55,
                      sections: List.generate(topCategories.length, (index) {
                        final item = topCategories[index];
                        final colors = [
                          const Color(0xFF21C98D),
                          const Color(0xFF4B8DF8),
                          const Color(0xFFA855F7),
                          const Color(0xFFF5B322),
                        ];
                        return PieChartSectionData(
                          value: item.value,
                          color: colors[index % colors.length],
                          radius: 48,
                          title: '${((item.value / total) * 100).toStringAsFixed(0)}%',
                          titleStyle: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        );
                      }),
                    ),
                  ),
          ),
          const SizedBox(height: 8),
          ...List.generate(topCategories.length, (index) {
            final item = topCategories[index];
            final colors = [
              const Color(0xFF21C98D),
              const Color(0xFF4B8DF8),
              const Color(0xFFA855F7),
              const Color(0xFFF5B322),
            ];

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 7),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: colors[index % colors.length],
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _formatLabel(item.key),
                      style: const TextStyle(color: Colors.white70, fontSize: 18),
                    ),
                  ),
                  Text(
                    CurrencyFormatter.format(item.value),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  String _formatLabel(String key) {
    final spaced = key.replaceAll('_', ' ');
    return spaced
        .split(' ')
        .map((word) =>
            word.isEmpty ? word : '${word[0].toUpperCase()}${word.substring(1)}')
        .join(' ');
  }
}

class _RecentTransactionsSection extends StatelessWidget {
  final List<Transaction> transactions;

  const _RecentTransactionsSection({required this.transactions});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Transactions',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 32,
              ),
            ),
            TextButton(
              onPressed: () => context.go('/transactions'),
              child: const Text(
                'See All',
                style: TextStyle(
                  color: Color(0xFF4D8DFF),
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (transactions.isEmpty)
          const _EmptyTransactionCard()
        else
          ...transactions.take(3).map(
            (txn) => _RecentTransactionTile(transaction: txn),
          ),
      ],
    );
  }
}

class _RecentTransactionTile extends StatelessWidget {
  final Transaction transaction;

  const _RecentTransactionTile({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.income;
    final amountColor = isIncome ? const Color(0xFF31CC84) : const Color(0xFFFB5B63);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF101722),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: amountColor.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isIncome ? Iconsax.arrow_down_2 : Iconsax.arrow_up_2,
              color: amountColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatLabel(transaction.category.name),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  DateFormat('MMM d, yyyy').format(transaction.date),
                  style: const TextStyle(color: Color(0xFF7E8898), fontSize: 13),
                ),
              ],
            ),
          ),
          Text(
            '${isIncome ? '+' : '-'}${CurrencyFormatter.format(transaction.amount)}',
            style: TextStyle(
              color: amountColor,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  String _formatLabel(String key) {
    final spaced = key.replaceAll('_', ' ');
    return spaced
        .split(' ')
        .map((word) => word.isEmpty
            ? word
            : '${word[0].toUpperCase()}${word.substring(1)}')
        .join(' ');
  }
}

class _EmptyTransactionCard extends StatelessWidget {
  const _EmptyTransactionCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF101722),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Text(
        'No recent transactions yet.',
        style: TextStyle(color: Color(0xFF8A93A4)),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Iconsax.warning_2, color: Colors.redAccent, size: 40),
            const SizedBox(height: 10),
            Text(
              message,
              style: const TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 14),
            ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
