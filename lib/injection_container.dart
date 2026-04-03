import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'features/transactions/data/datasources/transaction_local_datasource.dart';
import 'features/transactions/data/models/transaction_model.dart';
import 'features/transactions/data/repositories/transaction_repository_impl.dart';
import 'features/transactions/domain/repositories/transaction_repository.dart';
import 'features/transactions/domain/usecases/add_transaction.dart';
import 'features/transactions/domain/usecases/delete_transaction.dart';
import 'features/transactions/domain/usecases/get_transactions.dart';
import 'features/transactions/domain/usecases/update_transaction.dart';
import 'features/transactions/domain/usecases/filter_transactions.dart';
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
import 'features/goals/domain/usecases/update_goal_progress.dart';
import 'features/goals/presentation/cubit/goal_cubit.dart';
import 'features/insights/data/datasources/insights_local_datasource.dart';
import 'features/insights/data/repositories/insights_repository_impl.dart';
import 'features/insights/domain/repositories/insights_repository.dart';
import 'features/insights/domain/usecases/get_insights.dart';
import 'features/insights/presentation/cubit/insights_cubit.dart';
import 'core/constants/hive_constants.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // --- Hive Adapters ---
  if (!Hive.isAdapterRegistered(HiveConstants.transactionTypeId)) {
    Hive.registerAdapter(TransactionModelAdapter());
  }
  if (!Hive.isAdapterRegistered(HiveConstants.goalTypeId)) {
    Hive.registerAdapter(GoalModelAdapter());
  }

  // --- Hive Boxes ---
  final transactionBox = await Hive.openBox<TransactionModel>(
      HiveConstants.transactionsBox);
  final goalBox =
  await Hive.openBox<GoalModel>(HiveConstants.goalsBox);

  sl.registerLazySingleton(() => transactionBox);
  sl.registerLazySingleton(() => goalBox);

  // --- Features: Transactions ---
  sl.registerFactory(() => TransactionBloc(
    getTransactions: sl(),
    addTransaction: sl(),
    updateTransaction: sl(),
    deleteTransaction: sl(),
    filterTransactions: sl(),
  ));

  sl.registerLazySingleton(() => GetTransactions(sl()));
  sl.registerLazySingleton(() => AddTransaction(sl()));
  sl.registerLazySingleton(() => UpdateTransaction(sl()));
  sl.registerLazySingleton(() => DeleteTransaction(sl()));
  sl.registerLazySingleton(() => FilterTransactions(sl()));

  sl.registerLazySingleton<TransactionRepository>(
          () => TransactionRepositoryImpl(localDataSource: sl()));

  sl.registerLazySingleton<TransactionLocalDataSource>(
          () => TransactionLocalDataSourceImpl(box: sl()));

  // --- Features: Dashboard ---
  sl.registerFactory(() => DashboardBloc(
    getFinancialSummary: sl(),
    getTransactions: sl(),
  ));

  sl.registerLazySingleton(() => GetFinancialSummary(sl()));

  sl.registerLazySingleton<DashboardRepository>(
          () => DashboardRepositoryImpl(localDataSource: sl()));

  sl.registerLazySingleton<DashboardLocalDataSource>(
          () => DashboardLocalDataSourceImpl(box: sl()));

  // --- Features: Goals ---
  sl.registerFactory(() => GoalCubit(
    getGoals: sl(),
    addGoal: sl(),
    deleteGoal: sl(),
    updateGoalProgress: sl(),
  ));

  sl.registerLazySingleton(() => GetGoals(sl()));
  sl.registerLazySingleton(() => AddGoal(sl()));
  sl.registerLazySingleton(() => DeleteGoal(sl()));
  sl.registerLazySingleton(() => UpdateGoalProgress(sl()));

  sl.registerLazySingleton<GoalRepository>(
          () => GoalRepositoryImpl(localDataSource: sl()));

  sl.registerLazySingleton<GoalLocalDataSource>(
          () => GoalLocalDataSourceImpl(box: sl()));

  // --- Features: Insights ---
  sl.registerFactory(() => InsightsCubit(getInsights: sl()));

  sl.registerLazySingleton(() => GetInsights(sl()));

  sl.registerLazySingleton<InsightsRepository>(
          () => InsightsRepositoryImpl(localDataSource: sl()));

  sl.registerLazySingleton<InsightsLocalDataSource>(
          () => InsightsLocalDataSourceImpl(box: sl()));
}