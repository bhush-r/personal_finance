import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'features/goals/presentation/cubit/goal_cubit.dart';
import 'features/goals/presentation/cubit/saving_streak_cubit.dart';
import 'features/insights/presentation/cubit/insights_cubit.dart';
import 'features/transactions/presentation/bloc/transaction_bloc.dart';
import 'injection_container.dart' as di;
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'features/settings/presentation/cubit/settings_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Object? startupError;

  try {
    await Firebase.initializeApp();
    await Hive.initFlutter();
    await di.init();
  } catch (e, stackTrace) {
    debugPrint('Startup initialization failed: $e');
    debugPrintStack(stackTrace: stackTrace);
    startupError = e;
  }

  runApp(MyApp(startupError: startupError));
}

class MyApp extends StatelessWidget {
  final Object? startupError;

  const MyApp({super.key, this.startupError});

  @override
  Widget build(BuildContext context) {
    if (startupError != null) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Unable to start app. Please check Firebase/Hive setup and restart.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ),
      );
    }

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        BlocProvider(create: (_) => di.sl<AuthBloc>()..add(AuthCheckRequested())),
        BlocProvider(create: (_) => di.sl<TransactionBloc>()),
        BlocProvider(create: (_) => di.sl<DashboardBloc>()),
        BlocProvider(create: (_) => di.sl<GoalCubit>()),
        BlocProvider(create: (_) => di.sl<SavingStreakCubit>()),
        BlocProvider(create: (_) => di.sl<InsightsCubit>()),
        BlocProvider(create: (_) => di.sl<SettingsCubit>()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp.router(
            title: 'Finance Companion',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: themeProvider.themeMode,
            routerConfig: AppRouter.router,
          );
        },
      ),
    );
  }
}
