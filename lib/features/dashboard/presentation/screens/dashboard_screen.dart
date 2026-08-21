import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:go_router/go_router.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';
import '../widgets/balance_card.dart';
import '../widgets/income_expense_row.dart';
import '../widgets/recent_transactions_list.dart';
import '../widgets/savings_progress_card.dart';
import '../widgets/weekly_trend_card.dart';
import '../../../../shared/widgets/loading_shimmer_skeleton.dart';
import '../../../../shared/widgets/fade_in_animation.dart';
import '../../../../shared/widgets/staggered_animation.dart';
import '../../../../core/theme/app_colors.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Trigger event to load dashboard summary
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<DashboardBloc>().add(const LoadDashboardSummary());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          if (state is DashboardLoading) {
            return const DashboardLoadingSkeleton();
          }
          if (state is DashboardError) {
            return _buildErrorState(state.message);
          }
          if (state is DashboardLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<DashboardBloc>().add(const LoadDashboardSummary());
              },
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  _buildAppBar(context),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        const SizedBox(height: 12),

                        // Glassmorphic Balance Card
                        FadeInAnimation(
                          child: BalanceCard(balance: state.summary.balance),
                        ),
                        const SizedBox(height: 24),

                        // Quick Actions Bar
                        const _QuickActions(),
                        const SizedBox(height: 24),

                        // Income/Expense Overview
                        StaggeredAnimation(
                          children: [
                            IncomeExpenseRow(
                              totalIncome: state.summary.totalIncome,
                              totalExpense: state.summary.totalExpense,
                            ),
                            const SizedBox(height: 24),

                            // AI Smart Insight Card
                            _buildInsightCard(context),
                            const SizedBox(height: 24),

                            _buildSectionHeader(context, 'Weekly Trend', Iconsax.chart_21),
                            const SizedBox(height: 12),
                            WeeklyTrendCard(dailyData: _generateWeeklyData()),
                            const SizedBox(height: 24),

                            _buildSectionHeader(context, 'Savings Progress', Iconsax.status_up),
                            const SizedBox(height: 12),
                            SavingsProgressCard(
                              goal: state.summary.savingsGoal,
                              current: state.summary.savingsProgress,
                            ),
                            const SizedBox(height: 24),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildSectionHeader(context, 'Recent Transactions', Iconsax.document_text),
                                TextButton(
                                  onPressed: () => context.go('/transactions'),
                                  child: const Text('View All'),
                                ),
                              ],
                            ),
                            RecentTransactionsList(transactions: state.recentTransactions),
                            const SizedBox(height: 100), // Bottom padding for scrolling
                          ],
                        ),
                      ]),
                    ),
                  ),
                ],
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 100.0,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        title: Text(
          'Finance Companion',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            fontSize: 18,
          ),
        ),
        background: Container(color: AppColors.background),
      ),
      actions: [
        IconButton(
          icon: const Icon(Iconsax.notification, color: AppColors.textPrimary),
          onPressed: () {},
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: AppColors.primary),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildInsightCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, Color(0xFF818CF8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Iconsax.magic_star5, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'SMART TIP',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'You spent 15% less on food this week. Keep it up!',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Iconsax.danger, size: 64, color: AppColors.expense),
          const SizedBox(height: 16),
          Text(message),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.read<DashboardBloc>().add(const LoadDashboardSummary()),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Map<String, double> _generateWeeklyData() {
    return {'0': 1200, '1': 450, '2': 800, '3': 600, '4': 1100, '5': 550, '6': 920};
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _ActionItem(label: 'Add', icon: Iconsax.add, color: AppColors.primary, onTap: () => context.push('/transactions/add')),
        _ActionItem(label: 'Goals', icon: Iconsax.flag, color: AppColors.warning, onTap: () => context.go('/goals')),
        _ActionItem(label: 'Insight', icon: Iconsax.status_up, color: AppColors.savings, onTap: () => context.go('/insights')),
        _ActionItem(label: 'Export', icon: Iconsax.export, color: AppColors.secondary, onTap: () {}),
      ],
    );
  }
}

class _ActionItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionItem({required this.label, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}