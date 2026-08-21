import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forui/forui.dart';
import 'package:iconsax/iconsax.dart';

import '../cubit/insights_cubit.dart';
import '../cubit/insights_state.dart';

import '../widgets/top_category_card.dart';
import '../widgets/weekly_comparison_card.dart';
import '../widgets/category_breakdown_chart.dart';
import '../widgets/monthly_trend_chart.dart';
import '../widgets/expense_summary_card.dart';
import '../widgets/insights_header.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({
    super.key,
  });

  @override
  State<InsightsScreen> createState() =>
      _InsightsScreenState();
}

class _InsightsScreenState
    extends State<InsightsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(
        milliseconds: 600,
      ),
      vsync: this,
    );

    WidgetsBinding.instance.addPostFrameCallback(
          (_) {
        if (!mounted) return;

        context
            .read<InsightsCubit>()
            .loadInsights();

        _animationController.forward();
      },
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
      const Color(0xFFF7F8FA),

      appBar: AppBar(
        title: const Text(
          'Insights',
        ),
        backgroundColor:
        Colors.transparent,
        elevation: 0,

        actions: [
          Padding(
            padding: const EdgeInsets.only(
              right: 16,
            ),

            child: FButton.icon(
              onPress: () {
                context
                    .read<InsightsCubit>()
                    .refreshInsights();
              },

              child: const Icon(
                Iconsax.refresh,
              ),
            ),
          ),
        ],
      ),

      body: BlocBuilder<
          InsightsCubit,
          InsightsState>(
        builder: (
            context,
            state,
            ) {
          // --------------------------------------------------------------
          // LOADING
          // --------------------------------------------------------------

          if (state is InsightsLoading) {
            return _buildLoadingState();
          }

          // --------------------------------------------------------------
          // ERROR
          // --------------------------------------------------------------

          if (state is InsightsError) {
            return _buildErrorState(
              context,
              state.message,
            );
          }

          // --------------------------------------------------------------
          // LOADED
          // --------------------------------------------------------------

          if (state is InsightsLoaded) {
            final insight = state.insight;

            return FadeTransition(
              opacity: _animationController,

              child: RefreshIndicator(
                onRefresh: () {
                  return context
                      .read<InsightsCubit>()
                      .refreshInsights();
                },

                child: ListView(
                  padding:
                  const EdgeInsets.all(16),

                  physics:
                  const BouncingScrollPhysics(),

                  children: [
                    // ------------------------------------------------------
                    // HEADER
                    // ------------------------------------------------------

                    InsightsHeader(
                      insight: insight,
                    ),

                    const SizedBox(
                      height: 20,
                    ),

                    // ------------------------------------------------------
                    // TOP CATEGORY
                    // ------------------------------------------------------

                    _buildSectionTitle(
                      'Top Spending Category',
                    ),

                    _buildAnimatedCard(
                      0,

                      child:
                      TopCategoryCard(
                        topCategory:
                        insight.topCategory,
                        amount:
                        insight.topCategoryAmount,
                      ),
                    ),

                    const SizedBox(
                      height: 16,
                    ),

                    // ------------------------------------------------------
                    // WEEKLY COMPARISON
                    // ------------------------------------------------------

                    _buildSectionTitle(
                      'Weekly Comparison',
                    ),

                    _buildAnimatedCard(
                      1,

                      child:
                      WeeklyComparisonCard(
                        thisWeek:
                        insight.thisWeekExpense,
                        lastWeek:
                        insight.lastWeekExpense,
                      ),
                    ),

                    const SizedBox(
                      height: 16,
                    ),

                    // ------------------------------------------------------
                    // DAILY AVERAGE
                    // ------------------------------------------------------

                    _buildSectionTitle(
                      'Daily Average',
                    ),

                    _buildAnimatedCard(
                      2,

                      child:
                      ExpenseSummaryCard(
                        averageDailySpend:
                        insight.averageDailySpend,
                        thisWeekExpense:
                        insight.thisWeekExpense,
                      ),
                    ),

                    const SizedBox(
                      height: 16,
                    ),

                    // ------------------------------------------------------
                    // CATEGORY BREAKDOWN
                    // ------------------------------------------------------

                    _buildSectionTitle(
                      'Spending by Category',
                    ),

                    _buildAnimatedCard(
                      3,

                      child:
                      CategoryBreakdownChart(
                        data:
                        insight.categoryBreakdown,
                      ),
                    ),

                    const SizedBox(
                      height: 16,
                    ),

                    // ------------------------------------------------------
                    // MONTHLY TREND
                    // ------------------------------------------------------

                    _buildSectionTitle(
                      'Monthly Trend',
                    ),

                    _buildAnimatedCard(
                      4,

                      child:
                      MonthlyTrendChart(
                        trend:
                        insight.monthlyTrend,
                      ),
                    ),

                    const SizedBox(
                      height: 80,
                    ),
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

  // ==========================================================================
  // LOADING STATE
  // ==========================================================================

  Widget _buildLoadingState() {
    return ListView(
      padding: const EdgeInsets.all(16),

      children: [
        FCard(
          child: const SizedBox(
            height: 80,
            child: _ShimmerBox(),
          ),
        ),

        const SizedBox(
          height: 16,
        ),

        ...List.generate(
          4,
              (index) {
            return Padding(
              padding:
              const EdgeInsets.only(
                bottom: 16,
              ),

              child: FCard(
                child: const SizedBox(
                  height: 200,
                  child: _ShimmerBox(),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // ==========================================================================
  // ERROR STATE
  // ==========================================================================

  Widget _buildErrorState(
      BuildContext context,
      String message,
      ) {
    return Center(
      child: Padding(
        padding:
        const EdgeInsets.all(24),

        child: FCard(
          child: Padding(
            padding:
            const EdgeInsets.all(24),

            child: Column(
              mainAxisSize:
              MainAxisSize.min,

              children: [
                Container(
                  padding:
                  const EdgeInsets.all(20),

                  decoration:
                  BoxDecoration(
                    color:
                    Colors.red.shade100,
                    shape:
                    BoxShape.circle,
                  ),

                  child: Icon(
                    Iconsax.warning_2,
                    size: 50,
                    color:
                    Colors.red.shade600,
                  ),
                ),

                const SizedBox(
                  height: 20,
                ),

                Text(
                  'Unable to Load Insights',

                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),

                const SizedBox(
                  height: 10,
                ),

                Text(
                  message,

                  textAlign:
                  TextAlign.center,

                  style: TextStyle(
                    color:
                    Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(
                  height: 24,
                ),

                FButton(
                  onPress: () {
                    context
                        .read<InsightsCubit>()
                        .loadInsights();
                  },

                  prefix: const Icon(
                    Iconsax.refresh,
                    size: 18,
                  ),

                  child: const Text(
                    'Try Again',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // SECTION TITLE
  // ==========================================================================

  Widget _buildSectionTitle(
      String title,
      ) {
    return Padding(
      padding:
      const EdgeInsets.only(
        bottom: 12,
      ),

      child: Text(
        title,

        style: const TextStyle(
          fontWeight:
          FontWeight.w700,
          fontSize: 16,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  // ==========================================================================
  // ANIMATED CARD
  // ==========================================================================

  Widget _buildAnimatedCard(
      int index, {
        required Widget child,
      }) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(
        begin: 0,
        end: 1,
      ),

      duration: Duration(
        milliseconds:
        400 + (index * 100),
      ),

      curve:
      Curves.easeOutCubic,

      builder: (
          context,
          value,
          childWidget,
          ) {
        return Transform.translate(
          offset: Offset(
            0,
            30 * (1 - value),
          ),

          child: Opacity(
            opacity: value,
            child: childWidget,
          ),
        );
      },

      child: FCard(
        child: child,
      ),
    );
  }
}

// =============================================================================
// SHIMMER BOX
// =============================================================================

class _ShimmerBox extends StatefulWidget {
  const _ShimmerBox();

  @override
  State<_ShimmerBox> createState() =>
      _ShimmerBoxState();
}

class _ShimmerBoxState
    extends State<_ShimmerBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      duration:
      const Duration(
        milliseconds: 1500,
      ),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,

      builder: (
          context,
          child,
          ) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment(
                -1.0 -
                    _ctrl.value * 2,
                -0.5,
              ),

              end: Alignment(
                1.0 -
                    _ctrl.value * 2,
                0.5,
              ),

              colors: [
                Colors.grey.shade200,
                Colors.grey.shade100,
                Colors.grey.shade200,
              ],

              stops: const [
                0.0,
                0.5,
                1.0,
              ],
            ).createShader(bounds);
          },

          child: Container(
            color: Colors.white,
          ),
        );
      },
    );
  }
}