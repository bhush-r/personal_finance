import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../domain/entities/saving_streak.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';

class StreakStatsHeader extends StatelessWidget {
  final List<SavingStreak> streaks;

  const StreakStatsHeader({
    super.key,
    required this.streaks,
  });

  @override
  Widget build(BuildContext context) {
    final activeCount =
        streaks.where((s) => s.status == StreakStatus.active).length;
    final totalSaved = streaks.fold<double>(0, (sum, s) => sum + s.totalSaved);
    final longestStreak =
    streaks.fold<int>(0, (max, s) => s.longestStreak > max ? s.longestStreak : max);
    final avgDaily = _calculateAverageDailyAllStreaks();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Iconsax.flash_1,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Your Streak Stats",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.1,
            children: [
              _buildStatCard(
                context,
                icon: Iconsax.flash,
                label: "Active Streaks",
                value: "$activeCount",
                color: Colors.orange,
              ),
              _buildStatCard(
                context,
                icon: Iconsax.award,
                label: "Best Streak",
                value: "$longestStreak days",
                color: Colors.yellow,
              ),
              _buildStatCard(
                context,
                icon: Iconsax.wallet,
                label: "Total Saved",
                value: CurrencyFormatter.format(totalSaved),
                color: Colors.green,
              ),
              _buildStatCard(
                context,
                icon: Iconsax.trend_up,
                label: "Daily Average",
                value: CurrencyFormatter.format(avgDaily),
                color: Colors.blue,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      BuildContext context, {
        required IconData icon,
        required String label,
        required String value,
        required Color color,
      }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 18),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }

  double _calculateAverageDailyAllStreaks() {
    double totalSaved = 0;
    int totalDays = 0;

    for (final streak in streaks) {
      totalSaved += streak.totalSaved;
      totalDays += streak.completedDays;
    }

    if (totalDays == 0) return 0;
    return totalSaved / totalDays;
  }
}