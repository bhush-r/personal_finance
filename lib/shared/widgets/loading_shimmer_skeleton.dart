import 'package:flutter/material.dart';
import 'shimmer_loader.dart';

class DashboardLoadingSkeleton extends StatelessWidget {
  const DashboardLoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Balance Card
          ShimmerLoader(
            height: 120,
            borderRadius: BorderRadius.circular(16),
          ),
          const SizedBox(height: 16),

          // Income/Expense Row
          Row(
            children: [
              Expanded(
                child: ShimmerLoader(
                  height: 80,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ShimmerLoader(
                  height: 80,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Savings Progress
          ShimmerLoader(
            height: 140,
            borderRadius: BorderRadius.circular(12),
          ),
          const SizedBox(height: 24),

          // Weekly Trend
          ShimmerLoader(
            height: 240,
            borderRadius: BorderRadius.circular(12),
          ),
          const SizedBox(height: 24),

          // Section Title
          ShimmerLoader(
            height: 20,
            width: 180,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 12),

          // Chart
          ShimmerLoader(
            height: 200,
            borderRadius: BorderRadius.circular(12),
          ),
          const SizedBox(height: 24),

          // Recent Transactions
          ShimmerLoader(
            height: 20,
            width: 200,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 12),
          ...List.generate(
            5,
                (index) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ShimmerLoader(
                height: 60,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TransactionsLoadingSkeleton extends StatelessWidget {
  const TransactionsLoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              ShimmerLoader(
                height: 48,
                borderRadius: BorderRadius.circular(12),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ShimmerLoader(
                      height: 32,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ShimmerLoader(
                      height: 32,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: 8,
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ShimmerLoader(
                height: 70,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class GoalsLoadingSkeleton extends StatelessWidget {
  const GoalsLoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: ShimmerLoader(
                  height: 40,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ShimmerLoader(
                  height: 40,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ShimmerLoader(
                  height: 40,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ...List.generate(
            5,
                (index) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: ShimmerLoader(
                height: 140,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class InsightsLoadingSkeleton extends StatelessWidget {
  const InsightsLoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        children: [
          // Top Category Card
          ShimmerLoader(
            height: 80,
            borderRadius: BorderRadius.circular(12),
          ),
          const SizedBox(height: 16),

          // Weekly Comparison
          ShimmerLoader(
            height: 120,
            borderRadius: BorderRadius.circular(12),
          ),
          const SizedBox(height: 24),

          // Section Title
          ShimmerLoader(
            height: 20,
            width: 200,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 12),

          // Chart
          ShimmerLoader(
            height: 250,
            borderRadius: BorderRadius.circular(12),
          ),
          const SizedBox(height: 24),

          // Section Title
          ShimmerLoader(
            height: 20,
            width: 180,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 12),

          // Chart
          ShimmerLoader(
            height: 250,
            borderRadius: BorderRadius.circular(12),
          ),
        ],
      ),
    );
  }
}