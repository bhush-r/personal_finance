import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

// Screens
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/transactions/presentation/screens/transactions_screen.dart';
import '../../features/transactions/presentation/screens/add_edit_transaction_screen.dart';
import '../../features/goals/presentation/screens/goals_screen.dart';
import '../../features/goals/presentation/screens/add_goal_screen.dart';
import '../../features/goals/presentation/screens/saving_streak_screen.dart';
import '../../features/insights/presentation/screens/insights_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';

// Models
import '../../features/goals/domain/entities/goal.dart';

// Layout
import '../../shared/widgets/app_bottom_nav.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _goalsNavigatorKey = GlobalKey<NavigatorState>();

  static final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/dashboard',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppBottomNav(shell: shell),
        branches: [
          /// DASHBOARD
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/dashboard',
                builder: (_, __) => const DashboardScreen(),
              ),
            ],
          ),

          /// TRANSACTIONS
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/transactions',
                builder: (_, __) => const TransactionsScreen(),
                routes: [
                  GoRoute(
                    path: 'add',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (_, state) => AddEditTransactionScreen(
                      transaction: state.extra as dynamic,
                    ),
                  ),
                ],
              ),
            ],
          ),

          /// GOALS WITH STREAKS
          StatefulShellBranch(
            navigatorKey: _goalsNavigatorKey,
            routes: [
              GoRoute(
                path: '/goals',
                builder: (_, __) => const GoalsScreen(),
                routes: [
                  GoRoute(
                    path: 'add',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (_, state) {
                      final type =
                          state.extra as GoalType? ?? GoalType.savings;
                      return AddGoalScreen(goalType: type);
                    },
                  ),
                  GoRoute(
                    path: 'streaks',
                    parentNavigatorKey: _goalsNavigatorKey,
                    builder: (_, __) => const SavingStreakScreen(),
                  ),
                ],
              ),
            ],
          ),

          /// INSIGHTS
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/insights',
                builder: (_, __) => const InsightsScreen(),
              ),
            ],
          ),

          /// SETTINGS
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                builder: (_, __) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}