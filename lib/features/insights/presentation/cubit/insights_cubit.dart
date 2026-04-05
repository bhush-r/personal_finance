import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/get_insights.dart';
import 'insights_state.dart';

class InsightsCubit extends Cubit<InsightsState> {
  final GetInsights getInsights;

  InsightsCubit({required this.getInsights}) : super(const InsightsInitial());

  /// Load insights data
  Future<void> loadInsights() async {
    emit(const InsightsLoading());
    try {
      final result = await getInsights(NoParams());
      result.fold(
            (failure) => emit(InsightsError(message: failure.message)),
            (insights) => emit(InsightsLoaded(insight: insights)),
      );
    } catch (e) {
      emit(InsightsError(message: e.toString()));
    }
  }

  /// Refresh insights with haptic feedback
  Future<void> refreshInsights() async {
    await loadInsights();
  }
}