import 'package:equatable/equatable.dart';
import '../../domain/entities/insight.dart';

abstract class InsightsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class InsightsInitial extends InsightsState {}

class InsightsLoading extends InsightsState {}

class InsightsLoaded extends InsightsState {
  final Insight insight;
  const InsightsLoaded({required this.insight});

  @override
  List<Object?> get props => [insight];
}

class InsightsError extends InsightsState {
  final String message;
  const InsightsError({required this.message});

  @override
  List<Object?> get props => [message];
}
