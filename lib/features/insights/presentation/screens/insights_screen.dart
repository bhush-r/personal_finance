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

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InsightsCubit>().loadInsights();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: const Text("Insights"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: BlocBuilder<InsightsCubit, InsightsState>(
        builder: (context, state) {
          if (state is InsightsLoading) {
            return const InsightsLoadingSkeleton();
          }

          if (state is InsightsError) {
            return Center(child: Text(state.message));
          }

          if (state is InsightsLoaded) {
            final insight = state.insight;

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _card(child: TopCategoryCard(
                  topCategory: insight.topCategory,
                  amount: insight.topCategoryAmount,
                )),

                const SizedBox(height: 16),

                _card(child: WeeklyComparisonCard(
                  thisWeek: insight.thisWeekExpense,
                  lastWeek: insight.lastWeekExpense,
                )),

                const SizedBox(height: 16),

                _sectionTitle("Category Breakdown"),
                _card(child: CategoryBreakdownChart(
                  data: insight.categoryBreakdown,
                )),

                const SizedBox(height: 16),

                _sectionTitle("Monthly Trend"),
                _card(child: MonthlyTrendChart(
                  trend: insight.monthlyTrend,
                )),

                const SizedBox(height: 16),

                _card(child: _avgSpend(insight.averageDailySpend)),
                const SizedBox(height: 80),
              ],
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: child,
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _avgSpend(double amount) {
    return Row(
      children: [
        const Icon(Iconsax.chart_2),
        const SizedBox(width: 10),
        Text("₹${amount.toStringAsFixed(2)}"),
      ],
    );
  }
}