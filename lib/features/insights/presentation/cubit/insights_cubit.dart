import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_insights.dart';
import '../../../../core/usecases/usecase.dart';
import 'insights_state.dart';

class InsightsCubit extends Cubit<InsightsState> {
  final GetInsights getInsights;

  InsightsCubit({required this.getInsights}) : super(InsightsInitial());

  Future<void> loadInsights() async {
    emit(InsightsLoading());
    final result = await getInsights(NoParams());
    result.fold(
      (failure) => emit(InsightsError(message: failure.message)),
      (insight) => emit(InsightsLoaded(insight: insight)),
    );
  }
}
