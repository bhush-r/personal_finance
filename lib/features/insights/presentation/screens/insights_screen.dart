import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../cubit/insights_cubit.dart';
import '../cubit/insights_state.dart';
import '../../domain/entities/insight.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  int _selectedRange = 0;

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
      backgroundColor: const Color(0xFF090D14),
      body: SafeArea(
        child: BlocBuilder<InsightsCubit, InsightsState>(
          builder: (context, state) {
            if (state is InsightsLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is InsightsError) {
              return _ErrorState(
                message: state.message,
                onRetry: () => context.read<InsightsCubit>().refreshInsights(),
              );
            }

            if (state is! InsightsLoaded) {
              return const SizedBox.shrink();
            }

            final insight = state.insight;
            final chartValues = _buildWeekSeries(insight);
            final categoryEntries = insight.categoryBreakdown.entries.toList()
              ..sort((a, b) => b.value.compareTo(a.value));
            final topCategories = categoryEntries.take(5).toList();
            final total = topCategories.fold<double>(0.0, (sum, e) => sum + e.value);
            final change = insight.getWeeklyChange();

            return RefreshIndicator(
              color: const Color(0xFF3B82F6),
              onRefresh: () => context.read<InsightsCubit>().refreshInsights(),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16.0, 10.0, 16.0, 100.0),
                children: [
                  _buildHeader(),
                  const SizedBox(height: 16.0),
                  _RangeSelector(
                    selectedIndex: _selectedRange,
                    onChanged: (value) => setState(() => _selectedRange = value),
                  ),
                  const SizedBox(height: 16.0),
                  _TrendCard(chartValues: chartValues, weeklyChange: change),
                  const SizedBox(height: 14.0),
                  _SummaryInfoCard(
                    changePercent: change,
                    topCategory: insight.topCategory,
                  ),
                  const SizedBox(height: 20.0),
                  const Text(
                    'Category Breakdown',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 34.0,
                    ),
                  ),
                  const SizedBox(height: 14.0),
                  _CategoryBreakdownCard(
                    categories: topCategories,
                    total: total,
                  ),
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
        const Expanded(
          child: Text(
            'Statistics',
            style: TextStyle(
              color: Colors.white,
              fontSize: 40.0,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Container(
          width: 42.0,
          height: 42.0,
          decoration: BoxDecoration(
            color: const Color(0xFF141A24),
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: const Icon(Iconsax.calendar, color: Colors.white70, size: 20.0),
        ),
      ],
    );
  }

  List<double> _buildWeekSeries(Insight insight) {
    // Return daily spending for Mon-Sun (1-7)
    return List.generate(7, (index) => insight.dailySpending[index + 1] ?? 0.0);
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
    const labels = ['Week', 'Month', 'Year', 'Custom'];

    return Row(
      children: List.generate(labels.length, (index) {
        final selected = index == selectedIndex;

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: index == labels.length - 1 ? 0.0 : 8.0),
            child: GestureDetector(
              onTap: () => onChanged(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                decoration: BoxDecoration(
                  color: selected ? const Color(0xFF3B82F6) : const Color(0xFF151C27),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Text(
                  labels[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: selected ? Colors.white : const Color(0xFF9DA6B5),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _TrendCard extends StatelessWidget {
  final List<double> chartValues;
  final double weeklyChange;

  const _TrendCard({
    required this.chartValues,
    required this.weeklyChange,
  });

  @override
  Widget build(BuildContext context) {
    final increased = weeklyChange >= 0.0;

    return Container(
      padding: const EdgeInsets.all(18.0),
      decoration: BoxDecoration(
        color: const Color(0xFF101722),
        borderRadius: BorderRadius.circular(22.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Spending Trends',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Row(
                children: [
                  Icon(
                    increased ? Iconsax.arrow_up_2 : Iconsax.arrow_down_2,
                    color: increased ? const Color(0xFFFB5B63) : const Color(0xFF4D8DFF),
                    size: 14.0,
                  ),
                  const SizedBox(width: 4.0),
                  Text(
                    '${weeklyChange.abs().toStringAsFixed(0)}%',
                    style: TextStyle(
                      color: increased ? const Color(0xFFFB5B63) : const Color(0xFF4D8DFF),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12.0),
          AspectRatio(
            aspectRatio: 1.55,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                borderData: FlBorderData(show: false),
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                        final index = value.toInt();
                        if (index < 0 || index >= days.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 6.0),
                          child: Text(
                            days[index],
                            style: const TextStyle(color: Color(0xFF8D97A9), fontSize: 12.0),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: List.generate(chartValues.length, (index) {
                  final blueShade = index.isEven ? const Color(0xFF6AA8FF) : const Color(0xFF3E82F7);
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: chartValues[index],
                        width: 18.0,
                        borderRadius: BorderRadius.circular(4.0),
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            blueShade,
                            blueShade.withValues(alpha: 0.7),
                          ],
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
          const SizedBox(height: 4.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: chartValues
                .map((amount) => Text(
                      '₹${amount.toStringAsFixed(0)}',
                      style: const TextStyle(color: Color(0xFF8D97A9), fontSize: 12.0),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _SummaryInfoCard extends StatelessWidget {
  final double changePercent;
  final String topCategory;

  const _SummaryInfoCard({
    required this.changePercent,
    required this.topCategory,
  });

  @override
  Widget build(BuildContext context) {
    final increased = changePercent >= 0.0;

    return Container(
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: const Color(0xFF101722),
        borderRadius: BorderRadius.circular(14.0),
      ),
      child: Row(
        children: [
          const Icon(Iconsax.info_circle, color: Color(0xFF4D8DFF), size: 16.0),
          const SizedBox(width: 10.0),
          Expanded(
            child: Text(
              'You spent ${changePercent.abs().toStringAsFixed(0)}% '
              '${increased ? 'more' : 'less'} this week compared to last week. '
              'Your top spending category is ${_formatLabel(topCategory)}.',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14.0,
                height: 1.4,
              ),
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

class _CategoryBreakdownCard extends StatelessWidget {
  final List<MapEntry<String, double>> categories;
  final double total;

  const _CategoryBreakdownCard({
    required this.categories,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFF101722),
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: categories.isEmpty
          ? const Padding(
              padding: EdgeInsets.all(12.0),
              child: Text(
                'No category data available.',
                style: TextStyle(color: Color(0xFF8A93A4)),
              ),
            )
          : Column(
              children: List.generate(categories.length, (index) {
                final category = categories[index];
                final amount = category.value;
                final percent = total > 0.0 ? (amount / total) : 0.0;
                final color = _palette(index);

                return Padding(
                  padding: EdgeInsets.only(bottom: index == categories.length - 1 ? 0.0 : 18.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 32.0,
                            height: 32.0,
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.16),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: Icon(_iconForIndex(index), color: color, size: 16.0),
                          ),
                          const SizedBox(width: 10.0),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _formatLabel(category.key),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16.0,
                                  ),
                                ),
                                Text(
                                  '${(percent * 100.0).toStringAsFixed(0)}% of total',
                                  style: const TextStyle(color: Color(0xFF8F9AAD), fontSize: 12.0),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            CurrencyFormatter.format(amount),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 18.0,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8.0),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(99.0),
                        child: LinearProgressIndicator(
                          value: percent,
                          minHeight: 6.0,
                          backgroundColor: const Color(0xFF1B2430),
                          valueColor: AlwaysStoppedAnimation(color),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
    );
  }

  Color _palette(int index) {
    const colors = [
      Color(0xFFF5B322),
      Color(0xFFA855F7),
      Color(0xFFF76CC7),
      Color(0xFF21C98D),
      Color(0xFF9DE344),
    ];

    return colors[index % colors.length];
  }

  IconData _iconForIndex(int index) {
    const icons = [
      Iconsax.cup,
      Iconsax.car,
      Iconsax.bag,
      Iconsax.receipt,
      Iconsax.music,
    ];

    return icons[index % icons.length];
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

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Iconsax.warning_2, color: Colors.redAccent, size: 42.0),
            const SizedBox(height: 10.0),
            Text(
              message,
              style: const TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 14.0),
            ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
