import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';
import '../widgets/balance_card.dart';
import '../widgets/income_expense_row.dart';
import '../widgets/spending_chart.dart';
import '../widgets/recent_transactions_list.dart';
import '../widgets/savings_progress_card.dart';
import '../widgets/weekly_trend_card.dart';
import '../widgets/empty_dashboard_state.dart';
import '../../../../shared/widgets/loading_shimmer_skeleton.dart';
import '../../../../shared/widgets/fade_in_animation.dart';
import '../../../../shared/widgets/staggered_animation.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  @override
  void initState() {
    super.initState();
    // ✅ FIXED: Use WidgetsBinding to delay context access
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<DashboardBloc>().add(LoadDashboard());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Good ${_getGreeting()} 👋',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              'Finance Overview',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.notification),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No new notifications')),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          if (state is DashboardLoading) {
            return const DashboardLoadingSkeleton();
          }
          if (state is DashboardError) {
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
                        context.read<DashboardBloc>().add(const RefreshDashboard());
                      },
                      icon: const Icon(Iconsax.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }
          if (state is DashboardLoaded) {
            if (state.recentTransactions.isEmpty &&
                state.summary.categoryBreakdown.isEmpty) {
              return const FadeInAnimation(
                child: EmptyDashboardState(),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<DashboardBloc>().add(const RefreshDashboard());
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: StaggeredAnimation(
                  children: [
                    // Balance Card
                    BalanceCard(balance: state.summary.balance),

                    // Income/Expense Row
                    IncomeExpenseRow(
                      totalIncome: state.summary.totalIncome,
                      totalExpense: state.summary.totalExpense,
                    ),

                    // Savings Progress
                    SavingsProgressCard(
                      goal: state.summary.savingsGoal,
                      current: state.summary.savingsProgress,
                    ),

                    // Weekly Trend
                    WeeklyTrendCard(
                      dailyData: _generateWeeklyData(),
                    ),

                    // Spending Breakdown Section
                    _buildSectionTitle(context, 'Spending Breakdown'),

                    // Chart
                    SpendingChart(
                      categoryData: state.summary.categoryBreakdown,
                    ),

                    // Recent Transactions Section
                    _buildSectionTitle(context, 'Recent Transactions'),

                    // Transactions List
                    RecentTransactionsList(
                      transactions: state.recentTransactions,
                    ),

                    // Bottom spacing
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'morning';
    if (hour < 17) return 'afternoon';
    return 'evening';
  }

  Map<String, double> _generateWeeklyData() {
    final data = <String, double>{};
    for (int i = 0; i < 7; i++) {
      data[i.toString()] = 0;
    }
    return data;
  }
}