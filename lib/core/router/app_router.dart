import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/transactions/presentation/screens/transactions_screen.dart';
import '../../features/transactions/presentation/screens/add_edit_transaction_screen.dart';
import '../../features/goals/presentation/screens/goals_screen.dart';
import '../../features/goals/presentation/screens/add_goal_screen.dart';
import '../../features/goals/presentation/screens/saving_streak_screen.dart';
import '../../features/insights/presentation/screens/insights_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../shared/widgets/app_bottom_nav.dart';
import '../../features/goals/domain/entities/goal.dart';
import '../../features/transactions/domain/entities/transaction.dart';

class AppRouter {
  static GoRouter router(AuthBloc authBloc) {
    return GoRouter(
      initialLocation: '/',
      refreshListenable: GoRouterRefreshStream(authBloc.stream),
      redirect: (context, state) {
        final authState = authBloc.state;
        final isLoggingIn = state.matchedLocation == '/login';

        if (authState is Unauthenticated && !isLoggingIn) {
          return '/login';
        }

        if (authState is Authenticated && isLoggingIn) {
          return '/';
        }

        return null;
      },
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            return AppBottomNav(shell: navigationShell);
          },
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/',
                  builder: (context, state) => const DashboardScreen(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/transactions',
                  builder: (context, state) => const TransactionsScreen(),
                  routes: [
                    GoRoute(
                      path: 'add',
                      builder: (context, state) => AddEditTransactionScreen(
                        transaction: state.extra as Transaction?,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            // ... inside StatefulShellBranch for /goals
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/goals',
                  builder: (context, state) => const GoalsScreen(),
                  routes: [
                    GoRoute(
                      path: 'add',
                      builder: (context, state) {
                        // Retrieve goalType passed via context.push('/goals/add', extra: GoalType.savings)
                        final goalType = state.extra as GoalType? ?? GoalType.savings;
                        return AddGoalScreen(goalType: goalType);
                      },
                    ),
                    GoRoute(
                      path: 'streak',
                      builder: (context, state) => const SavingStreakScreen(),
                    ),
                  ],
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/insights',
                  builder: (context, state) => const InsightsScreen(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/settings',
                  builder: (context, state) => const SettingsScreen(),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

/// Listenable adapter that converts a Dart Stream to Listenable for GoRouter
class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
          (_) => notifyListeners(),
    );
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
