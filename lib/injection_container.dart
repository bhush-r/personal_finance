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

final sl = GetIt.instance;

Future<void> init() async {
  // --- Features ---

  // BLoCs
  sl.registerFactory(() => TransactionBloc(
    getTransactions: sl(),
    addTransaction: sl(),
    updateTransaction: sl(),
    deleteTransaction: sl(),
    filterTransactions: sl(),
  ));

  sl.registerFactory(() => DashboardBloc(
    getFinancialSummary: sl(),
    getTransactions: sl(),
  ));

  // Use cases
  sl.registerLazySingleton(() => GetTransactions(sl()));
  sl.registerLazySingleton(() => AddTransaction(sl()));
  sl.registerLazySingleton(() => UpdateTransaction(sl()));
  sl.registerLazySingleton(() => DeleteTransaction(sl()));
  sl.registerLazySingleton(() => FilterTransactions(sl()));
  sl.registerLazySingleton(() => GetFinancialSummary(sl()));

  // Repositories
  sl.registerLazySingleton<TransactionRepository>(
        () => TransactionRepositoryImpl(localDataSource: sl()),
  );
  sl.registerLazySingleton<DashboardRepository>(
        () => DashboardRepositoryImpl(localDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<TransactionLocalDataSource>(
        () => TransactionLocalDataSourceImpl(box: sl()),
  );
  sl.registerLazySingleton<DashboardLocalDataSource>(
        () => DashboardLocalDataSourceImpl(box: sl()),
  );

  // --- External ---
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(TransactionModelAdapter());
  }
  final transactionBox = await Hive.openBox<TransactionModel>('transactions');
  sl.registerLazySingleton(() => transactionBox);
}