import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/analytics/analytics_service.dart';
import 'core/network/network_info.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

import 'features/transactions/data/datasources/transaction_local_datasource.dart';
import 'features/transactions/data/datasources/transaction_remote_datasource.dart';
import 'features/transactions/data/models/transaction_model.dart';
import 'features/transactions/data/repositories/transaction_repository_impl.dart';
import 'features/transactions/domain/repositories/transaction_repository.dart';
import 'features/transactions/domain/usecases/add_transaction.dart';
import 'features/transactions/domain/usecases/delete_transaction.dart';
import 'features/transactions/domain/usecases/export_transactions.dart';
import 'features/transactions/domain/usecases/filter_transactions.dart';
import 'features/transactions/domain/usecases/get_transactions.dart';
import 'features/transactions/domain/usecases/update_transaction.dart';
import 'features/transactions/presentation/bloc/transaction_bloc.dart';

import 'features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'features/dashboard/domain/usecases/get_financial_summary.dart';
import 'features/dashboard/domain/repositories/dashboard_repository.dart';
import 'features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'features/dashboard/data/datasources/dashboard_local_datasource.dart';

import 'features/goals/data/datasources/goal_local_datasource.dart';
import 'features/goals/data/datasources/goal_remote_datasource.dart';
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

final sl = GetIt.instance;

Future<void> init() async {
  // 1. Core & External Services
  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
  sl.registerLazySingleton<GoogleSignIn>(() => GoogleSignIn());
  sl.registerLazySingleton<AnalyticsService>(() => AnalyticsService());
  sl.registerLazySingleton<Connectivity>(() => Connectivity());
  sl.registerLazySingleton<InternetConnectionChecker>(() => InternetConnectionChecker());
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl(), sl()));

  sl.registerSingleton<NotificationService>(NotificationService());
  sl.registerSingleton<BiometricService>(BiometricService());

  // Auth Dependencies
  sl.registerLazySingleton<AuthRepository>(
        () => AuthRepositoryImpl(
      firebaseAuth: sl(),
      googleSignIn: sl(),
      firestore: sl(),
    ),
  );

// Register AuthBloc Factory
  sl.registerFactory<AuthBloc>(
        () => AuthBloc(authRepository: sl()),
  );

  // 3. Storage & Hive
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

  if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(TransactionModelAdapter());
  if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(GoalModelAdapter());

  final transactionBox = await Hive.openBox<TransactionModel>('transactions');
  final goalsBox = await Hive.openBox<GoalModel>('goals');

  sl.registerLazySingleton<Box<TransactionModel>>(() => transactionBox);
  sl.registerLazySingleton<Box<GoalModel>>(() => goalsBox);

  // 4. Transactions Feature
  sl.registerLazySingleton<TransactionLocalDataSource>(
        () => TransactionLocalDataSourceImpl(box: sl()),
  );
  sl.registerLazySingleton<TransactionRemoteDataSource>(
        () => TransactionRemoteDataSourceImpl(firestoreDb: sl(), auth: sl()),
  );
  sl.registerLazySingleton<TransactionRepository>(
        () => TransactionRepositoryImpl(
      localDataSource: sl(),
      remoteDataSource: sl(),
      networkInfo: sl(),
      analytics: sl(),
    ),
  );
  sl.registerLazySingleton<GetTransactions>(() => GetTransactions(sl()));
  sl.registerLazySingleton<AddTransaction>(() => AddTransaction(sl()));
  sl.registerLazySingleton<UpdateTransaction>(() => UpdateTransaction(sl()));
  sl.registerLazySingleton<DeleteTransaction>(() => DeleteTransaction(sl()));
  sl.registerLazySingleton<FilterTransactions>(() => FilterTransactions(sl()));
  sl.registerLazySingleton<ExportTransactions>(() => ExportTransactions(sl()));

  sl.registerLazySingleton<TransactionBloc>(
        () => TransactionBloc(
      getTransactions: sl(),
      addTransaction: sl(),
      updateTransaction: sl(),
      deleteTransaction: sl(),
      filterTransactions: sl(),
    ),
  );

  // 5. Dashboard Feature
  sl.registerLazySingleton<DashboardLocalDataSource>(
        () => DashboardLocalDataSourceImpl(box: sl()),
  );
  sl.registerLazySingleton<DashboardRepository>(
        () => DashboardRepositoryImpl(localDataSource: sl()),
  );
  sl.registerLazySingleton<GetFinancialSummary>(() => GetFinancialSummary(sl()));
  sl.registerFactory<DashboardBloc>(
        () => DashboardBloc(
      getFinancialSummary: sl(),
      getTransactions: sl(),
      transactionBloc: sl(),
    ),
  );

  // 6. Goals Feature
  sl.registerLazySingleton<GoalLocalDataSource>(
        () => GoalLocalDataSourceImpl(box: sl()),
  );
  sl.registerLazySingleton<GoalRemoteDataSource>(
        () => GoalRemoteDataSourceImpl(firestore: sl(), auth: sl()),
  );
  sl.registerLazySingleton<GoalRepository>(
        () => GoalRepositoryImpl(
      localDataSource: sl(),
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );
  sl.registerLazySingleton<GetGoals>(() => GetGoals(sl()));
  sl.registerLazySingleton<AddGoal>(() => AddGoal(sl()));
  sl.registerLazySingleton<UpdateGoal>(() => UpdateGoal(sl()));
  sl.registerLazySingleton<DeleteGoal>(() => DeleteGoal(sl()));

  sl.registerFactory<GoalCubit>(
        () => GoalCubit(
      getGoals: sl(),
      addGoal: sl(),
      updateGoal: sl(),
      deleteGoal: sl(),
    ),
  );
  sl.registerFactory<SavingStreakCubit>(() => SavingStreakCubit());

  // 7. Insights Feature
  sl.registerLazySingleton<InsightsLocalDataSource>(
        () => InsightsLocalDataSourceImpl(box: sl()),
  );
  sl.registerLazySingleton<InsightsRepository>(
        () => InsightsRepositoryImpl(localDataSource: sl()),
  );
  sl.registerLazySingleton<GetInsights>(() => GetInsights(sl()));
  sl.registerFactory<InsightsCubit>(() => InsightsCubit(getInsights: sl()));

  // 8. Settings Feature
  sl.registerLazySingleton<SettingsLocalDataSource>(
        () => SettingsLocalDataSourceImpl(prefs: sl()),
  );
  sl.registerLazySingleton<SettingsRepository>(
        () => SettingsRepositoryImpl(localDataSource: sl()),
  );
  sl.registerLazySingleton<GetPreferences>(() => GetPreferences(sl()));
  sl.registerLazySingleton<SavePreferences>(() => SavePreferences(sl()));
  sl.registerFactory<SettingsCubit>(
        () => SettingsCubit(
      getPreferences: sl(),
      savePreferences: sl(),
      authRepository: sl(),
    ),
  );
}