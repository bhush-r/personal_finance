import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/saving_streak.dart';
import '../cubit/saving_streak_cubit.dart';
import '../cubit/saving_streak_state.dart';
import '../widgets/streak_card.dart';
import '../widgets/create_streak_dialog.dart';
import '../widgets/streak_stats_header.dart';

class SavingStreakScreen extends StatefulWidget {
  const SavingStreakScreen({super.key});

  @override
  State<SavingStreakScreen> createState() => _SavingStreakScreenState();
}

class _SavingStreakScreenState extends State<SavingStreakScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SavingStreakCubit>().loadStreaks();
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: const Text("Saving Streaks"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: IconButton(
              icon: const Icon(Iconsax.refresh),
              onPressed: () {
                context.read<SavingStreakCubit>().loadStreaks();
              },
              tooltip: "Refresh streaks",
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showCreateStreakDialog();
        },
        backgroundColor: Colors.black,
        icon: const Icon(Iconsax.add, color: Colors.white),
        label: const Text("New Streak"),
      ),
      body: BlocBuilder<SavingStreakCubit, SavingStreakState>(
        builder: (context, state) {
          if (state is SavingStreakLoading) {
            return _buildLoadingState();
          }

          if (state is SavingStreakError) {
            return _buildErrorState(context, state.message);
          }

          if (state is SavingStreakLoaded) {
            if (state.streaks.isEmpty) {
              return _buildEmptyState(context);
            }

            final activeStreaks =
            state.streaks.where((s) => s.status == StreakStatus.active).toList();
            final pausedStreaks =
            state.streaks.where((s) => s.status == StreakStatus.paused).toList();
            final brokenStreaks =
            state.streaks.where((s) => s.status == StreakStatus.broken).toList();

            return FadeTransition(
              opacity: _animationController,
              child: RefreshIndicator(
                onRefresh: () =>
                    context.read<SavingStreakCubit>().loadStreaks(),
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    // ✨ STATS HEADER
                    StreakStatsHeader(streaks: state.streaks),
                    const SizedBox(height: 24),

                    // ✨ ACTIVE STREAKS
                    if (activeStreaks.isNotEmpty) ...[
                      _buildSectionTitle("Active Streaks"),
                      ...List.generate(activeStreaks.length, (index) {
                        return _buildAnimatedStreakCard(
                          index,
                          activeStreaks[index],
                        );
                      }),
                      const SizedBox(height: 24),
                    ],

                    // ✨ PAUSED STREAKS
                    if (pausedStreaks.isNotEmpty) ...[
                      _buildSectionTitle("Paused Streaks"),
                      ...List.generate(pausedStreaks.length, (index) {
                        return _buildAnimatedStreakCard(
                          index,
                          pausedStreaks[index],
                        );
                      }),
                      const SizedBox(height: 24),
                    ],

                    // ✨ BROKEN STREAKS
                    if (brokenStreaks.isNotEmpty) ...[
                      _buildSectionTitle("Broken Streaks"),
                      ...List.generate(brokenStreaks.length, (index) {
                        return _buildAnimatedStreakCard(
                          index,
                          brokenStreaks[index],
                        );
                      }),
                    ],

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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 16,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildAnimatedStreakCard(int index, SavingStreak streak) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 400 + (index * 100)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: StreakCard(
          streak: streak,
          onAddSaving: () {
            _showAddSavingDialog(streak);
          },
          onPause: () {
            context.read<SavingStreakCubit>().pauseStreak(streak.id);
          },
          onResume: () {
            context.read<SavingStreakCubit>().resumeStreak(streak.id);
          },
          onDelete: () {
            _showDeleteDialog(streak);
          },
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ...List.generate(
          3,
              (index) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Container(
              height: 180,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Shimmer.fromColors(
                baseColor: Colors.grey.shade200,
                highlightColor: Colors.grey.shade100,
                child: Container(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Iconsax.warning_2,
            size: 60,
            color: Colors.red.shade400,
          ),
          const SizedBox(height: 20),
          Text(
            "Error Loading Streaks",
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () {
              context.read<SavingStreakCubit>().loadStreaks();
            },
            icon: const Icon(Iconsax.refresh),
            label: const Text("Try Again"),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.orange.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Iconsax.flash_1,
              size: 60,
              color: Colors.orange.shade600,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "No Saving Streaks Yet",
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              "Start a saving streak to build consistent saving habits and track your progress",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: _showCreateStreakDialog,
            icon: const Icon(Iconsax.add),
            label: const Text("Create Your First Streak"),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 30,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateStreakDialog() {
    showDialog(
      context: context,
      builder: (ctx) => CreateStreakDialog(
        onCreate: (title, description, targetAmount) {
          final newStreak = SavingStreak(
            id: const Uuid().v4(),
            title: title,
            description: description,
            currentStreak: 0,
            longestStreak: 0,
            targetAmount: targetAmount,
            totalSaved: 0,
            startDate: DateTime.now(),
            completedDays: 0,
          );

          context.read<SavingStreakCubit>().createStreak(newStreak);
          Navigator.pop(ctx);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: const [
                  Icon(Iconsax.tick_circle, color: Colors.white),
                  SizedBox(width: 12),
                  Expanded(child: Text("Streak created! Let's go 🔥")),
                ],
              ),
              backgroundColor: Colors.green.shade400,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.all(16),
            ),
          );
        },
      ),
    );
  }

  void _showAddSavingDialog(SavingStreak streak) {
    final amounts = [100, 500, 1000, 2000, 5000, 10000];

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Add Savings",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "Streak: ${streak.title}",
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.2,
                children: amounts
                    .map(
                      (amount) => GestureDetector(
                    onTap: () {
                      context
                          .read<SavingStreakCubit>()
                          .updateStreakWithSaving(
                        streak.id,
                        amount.toDouble(),
                      );
                      Navigator.pop(ctx);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: const [
                              Icon(
                                Iconsax.flash_1,
                                color: Colors.white,
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text("Great! Keep it up! 🎉"),
                              ),
                            ],
                          ),
                          backgroundColor: Colors.orange.shade400,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          margin: const EdgeInsets.all(16),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.orange.shade200,
                          width: 1.5,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "₹",
                            style: TextStyle(
                              color: Colors.orange.shade600,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "$amount",
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                    .toList(),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade200,
                    foregroundColor: Colors.black87,
                  ),
                  child: const Text("Cancel"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(SavingStreak streak) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Streak?"),
        content: Text(
          "Are you sure you want to delete '${streak.title}'? This cannot be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              context.read<SavingStreakCubit>().deleteStreak(streak.id);
              Navigator.pop(ctx);
            },
            child: const Text(
              "Delete",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

// ✨ SHIMMER EFFECT
class Shimmer extends StatefulWidget {
  final Color baseColor;
  final Color highlightColor;
  final Widget child;

  const Shimmer.fromColors({
    super.key,
    required this.baseColor,
    required this.highlightColor,
    required this.child,
  });

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment(-1.0 - _shimmerController.value * 2, -0.5),
              end: Alignment(1.0 - _shimmerController.value * 2, 0.5),
              colors: [
                widget.baseColor,
                widget.highlightColor,
                widget.baseColor,
              ],
              stops: const [0.0, 0.5, 1.0],
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}