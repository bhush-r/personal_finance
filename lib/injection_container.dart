import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'features/transactions/data/datasources/transaction_local_datasource.dart';
import 'features/transactions/data/models/transaction_model.dart';
import 'features/transactions/data/repositories/transaction_repository_impl.dart';
import 'features/transactions/domain/repositories/transaction_repository.dart';
import 'features/transactions/domain/usecases/add_transaction.dart';
import 'features/transactions/domain/usecases/delete_transaction.dart';
import 'features/transactions/domain/usecases/get_transactions.dart';
import 'features/transactions/domain/usecases/update_transaction.dart';
import 'features/transactions/domain/usecases/filter_transactions.dart';
import 'features/transactions/domain/usecases/export_transactions.dart';
import 'features/transactions/presentation/bloc/transaction_bloc.dart';
import 'features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'features/dashboard/domain/usecases/get_financial_summary.dart';
import 'features/dashboard/domain/repositories/dashboard_repository.dart';
import 'features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'features/dashboard/data/datasources/dashboard_local_datasource.dart';
import 'features/goals/data/datasources/goal_local_datasource.dart';
import 'features/goals/data/models/goal_model.dart';
import 'features/goals/data/repositories/goal_repository_impl.dart';
import 'features/goals/domain/repositories/goal_repository.dart';
import 'features/goals/domain/usecases/add_goal.dart';
import 'features/goals/domain/usecases/delete_goal.dart';
import 'features/goals/domain/usecases/get_goals.dart';
import 'features/goals/domain/usecases/update_goal.dart';
import 'features/goals/presentation/cubit/goal_cubit.dart';
import 'features/goals/presentation/cubit/saving_streak_cubit.dart';
import 'features/insights/data/datasources/insights_local_datasource.dart';
import 'features/insights/data/repositories/insights_repository_impl.dart';
import 'features/insights/domain/repositories/insights_repository.dart';
import 'features/insights/domain/usecases/get_insights.dart';
import 'features/insights/presentation/cubit/insights_cubit.dart';
import 'features/settings/data/datasources/settings_local_datasource.dart';
import 'features/settings/data/repositories/settings_repository_impl.dart';
import 'features/settings/domain/repositories/settings_repository.dart';
import 'features/settings/domain/usecases/get_preferences.dart';
import 'features/settings/domain/usecases/save_preferences.dart';
import 'features/settings/presentation/cubit/settings_cubit.dart';
import 'shared/services/notification_service.dart';
import 'shared/services/biometric_service.dart';
import 'core/constants/currency_constants.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // ══════════════════════════════════════════════════════════════════════════
  // ╔═══════════════════════════════════════════════════════════════════════╗
  // ║                        EXTERNAL SERVICES                              ║
  // ╚═══════════════════════════════════════════════════════════════════════╝
  // ══════════════════════════════════════════════════════════════════════════

  // SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  // Hive Setup - Register adapters
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(TransactionModelAdapter());
  }
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(GoalModelAdapter());
  }

  // Open Hive boxes
  final transactionBox = await Hive.openBox<TransactionModel>('transactions');
  final goalsBox = await Hive.openBox<GoalModel>('goals');

  sl.registerLazySingleton(() => transactionBox);
  sl.registerLazySingleton<Box<GoalModel>>(() => goalsBox);

  // Notification Service
  sl.registerSingleton<NotificationService>(NotificationService());
  await sl<NotificationService>().initialize();

  // Biometric Service
  sl.registerSingleton<BiometricService>(BiometricService());
  await sl<BiometricService>().initialize();

  // ══════════════════════════════════════════════════════════════════════════
  // ╔═══════════════════════════════════════════════════════════════════════╗
  // ║                     TRANSACTIONS FEATURE                              ║
  // ╚═══════════════════════════════════════════════════════════════════════╝
  // ══════════════════════════════════════════════════════════════════════════

  // Data Sources
  sl.registerLazySingleton<TransactionLocalDataSource>(
        () => TransactionLocalDataSourceImpl(box: sl()),
  );

  // Repositories
  sl.registerLazySingleton<TransactionRepository>(
        () => TransactionRepositoryImpl(localDataSource: sl()),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetTransactions(sl()));
  sl.registerLazySingleton(() => AddTransaction(sl()));
  sl.registerLazySingleton(() => UpdateTransaction(sl()));
  sl.registerLazySingleton(() => DeleteTransaction(sl()));
  sl.registerLazySingleton(() => FilterTransactions(sl()));
  sl.registerLazySingleton(() => ExportTransactions(sl()));

  // BLoC
  sl.registerFactory(() => TransactionBloc(
    getTransactions: sl(),
    addTransaction: sl(),
    updateTransaction: sl(),
    deleteTransaction: sl(),
    filterTransactions: sl(),
  ));


  // ✨ Currency Support
  sl.registerSingleton<CurrencyConstants>(CurrencyConstants());
  // ══════════════════════════════════════════════════════════════════════════
  // ╔═══════════════════════════════════════════════════════════════════════╗
  // ║                     DASHBOARD FEATURE                                 ║
  // ╚═══════════════════════════════════════════════════════════════════════╝
  // ══════════════════════════════════════════════════════════════════════════

  // Data Sources
  sl.registerLazySingleton<DashboardLocalDataSource>(
        () => DashboardLocalDataSourceImpl(box: sl()),
  );

  // Repositories
  sl.registerLazySingleton<DashboardRepository>(
        () => DashboardRepositoryImpl(localDataSource: sl()),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetFinancialSummary(sl()));

  // BLoC
  sl.registerFactory(() => DashboardBloc(
    getFinancialSummary: sl(),
    getTransactions: sl(),
  ));

  // ══════════════════════════════════════════════════════════════════════════
  // ╔═══════════════════════════════════════════════════════════════════════╗
  // ║                       GOALS FEATURE                                   ║
  // ╚═══════════════════════════════════════════════════════════════════════╝
  // ══════════════════════════════════════════════════════════════════════════

  // Data Sources
  sl.registerLazySingleton<GoalLocalDataSource>(
        () => GoalLocalDataSourceImpl(box: sl<Box<GoalModel>>()),
  );

  // Repositories
  sl.registerLazySingleton<GoalRepository>(
        () => GoalRepositoryImpl(localDataSource: sl()),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetGoals(sl()));
  sl.registerLazySingleton(() => AddGoal(sl()));
  sl.registerLazySingleton(() => UpdateGoal(sl()));
  sl.registerLazySingleton(() => DeleteGoal(sl()));

  // Cubits
  sl.registerFactory(() => GoalCubit(
    getGoals: sl(),
    addGoal: sl(),
    updateGoal: sl(),
    deleteGoal: sl(),
  ));

  sl.registerFactory(() => SavingStreakCubit());

  // ══════════════════════════════════════════════════════════════════════════
  // ╔═══════════════════════════════════════════════════════════════════════╗
  // ║                     INSIGHTS FEATURE                                  ║
  // ╚═══════════════════════════════════════════════════════════════════════╝
  // ══════════════════════════════════════════════════════════════════════════

  // Data Sources
  sl.registerLazySingleton<InsightsLocalDataSource>(
        () => InsightsLocalDataSourceImpl(box: sl()),
  );

  // Repositories
  sl.registerLazySingleton<InsightsRepository>(
        () => InsightsRepositoryImpl(localDataSource: sl()),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetInsights(sl()));

  // Cubit
  sl.registerFactory(() => InsightsCubit(
    getInsights: sl(),
  ));

  // ══════════════════════════════════════════════════════════════════════════
  // ╔═══════════════════════════════════════════════════════════════════════╗
  // ║                     SETTINGS FEATURE                                  ║
  // ╚═══════════════════════════════════════════════════════════════════════╝
  // ══════════════════════════════════════════════════════════════════════════

  // Data Sources
  sl.registerLazySingleton<SettingsLocalDataSource>(
        () => SettingsLocalDataSourceImpl(prefs: sl()),
  );

  // Repositories
  sl.registerLazySingleton<SettingsRepository>(
        () => SettingsRepositoryImpl(localDataSource: sl()),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetPreferences(sl()));
  sl.registerLazySingleton(() => SavePreferences(sl()));

  // Cubit
  sl.registerFactory(() => SettingsCubit(
    getPreferences: sl(),
    savePreferences: sl(),
  ));
}