import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forui/forui.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'injection_container.dart' as di;
import 'injection_container.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/transactions/presentation/bloc/transaction_bloc.dart';
import 'features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'features/goals/presentation/cubit/goal_cubit.dart';
import 'features/insights/presentation/cubit/insights_cubit.dart';
import 'features/settings/presentation/cubit/settings_cubit.dart';
import 'core/router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Hive.initFlutter();
  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => sl<AuthBloc>(),
        ),
        BlocProvider<TransactionBloc>(
          create: (_) => sl<TransactionBloc>(),
        ),
        BlocProvider<DashboardBloc>(
          create: (_) => sl<DashboardBloc>(),
        ),
        BlocProvider<GoalCubit>(
          create: (_) => sl<GoalCubit>(),
        ),
        BlocProvider<InsightsCubit>(
          create: (_) => sl<InsightsCubit>(),
        ),
        BlocProvider<SettingsCubit>(
          create: (_) => sl<SettingsCubit>(),
        ),
      ],
      child: Builder(
        builder: (context) {
          final authBloc = context.read<AuthBloc>();
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: 'Personal Finance',
            builder: (context, child) {
              return FTheme(
                data: FThemes.zinc.light.touch,
                child: child ?? const SizedBox(),
              );
            },
            routerConfig: AppRouter.router(authBloc),
          );
        },
      ),
    );
  }
}