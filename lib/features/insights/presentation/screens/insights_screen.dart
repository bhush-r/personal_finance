import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import '../cubit/insights_cubit.dart';
import '../cubit/insights_state.dart';
import '../widgets/top_category_card.dart';
import '../widgets/weekly_comparison_card.dart';
import '../widgets/category_breakdown_chart.dart';
import '../widgets/monthly_trend_chart.dart';
import '../../../../shared/widgets/loading_shimmer_skeleton.dart';
import '../../../../shared/widgets/fade_in_animation.dart';
import '../../../../shared/widgets/staggered_animation.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  @override
  void initState() {
    super.initState();
    // ✅ FIXED: Use WidgetsBinding to delay Cubit access
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<InsightsCubit>().loadInsights();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Insights',
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      body: BlocBuilder<InsightsCubit, InsightsState>(
        builder: (context, state) {
          if (state is InsightsLoading) {
            return const InsightsLoadingSkeleton();
          }
          if (state is InsightsError) {
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
                        // ✅ FIXED: Proper context access
                        context.read<InsightsCubit>().loadInsights();
                      },
                      icon: const Icon(Iconsax.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }
          if (state is InsightsLoaded) {
            final insight = state.insight;
            return RefreshIndicator(
              onRefresh: () async =>
                  context.read<InsightsCubit>().loadInsights(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: StaggeredAnimation(
                  children: [
                    // Top Category Card
                    TopCategoryCard(
                      topCategory: insight.topCategory,
                      amount: insight.topCategoryAmount,
                    ),

                    // Weekly Comparison
                    WeeklyComparisonCard(
                      thisWeek: insight.thisWeekExpense,
                      lastWeek: insight.lastWeekExpense,
                    ),

                    // Section Title
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Text(
                        'Category Breakdown',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),

                    // Category Breakdown Chart
                    CategoryBreakdownChart(
                      data: insight.categoryBreakdown,
                    ),

                    // Section Title
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Text(
                        'Monthly Trend',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),

                    // Monthly Trend Chart
                    MonthlyTrendChart(trend: insight.monthlyTrend),

                    // Average Daily Spend Card
                    _buildAverageDailySpendCard(
                      context,
                      insight.averageDailySpend,
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

  /// Build average daily spend card
  Widget _buildAverageDailySpendCard(BuildContext context, double amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue.shade200),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Iconsax.chart_2,
                color: Colors.blue.shade600,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Average Daily Spend',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.blue.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '₹${amount.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}