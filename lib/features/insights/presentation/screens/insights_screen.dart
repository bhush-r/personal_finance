import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/insights_cubit.dart';
import '../cubit/insights_state.dart';
import '../widgets/top_category_card.dart';
import '../widgets/weekly_comparison_card.dart';
import '../widgets/category_breakdown_chart.dart';
import '../widgets/monthly_trend_chart.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<InsightsCubit>().loadInsights();
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
            return const Center(child: CircularProgressIndicator());
          }
          if (state is InsightsError) {
            return Center(child: Text(state.message));
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TopCategoryCard(
                      topCategory: insight.topCategory,
                      amount: insight.topCategoryAmount,
                    ),
                    const SizedBox(height: 16),
                    WeeklyComparisonCard(
                      thisWeek: insight.thisWeekExpense,
                      lastWeek: insight.lastWeekExpense,
                    ),
                    const SizedBox(height: 24),
                    Text('Category Breakdown',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    CategoryBreakdownChart(
                        data: insight.categoryBreakdown),
                    const SizedBox(height: 24),
                    Text('Monthly Trend',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    MonthlyTrendChart(trend: insight.monthlyTrend),
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
}
