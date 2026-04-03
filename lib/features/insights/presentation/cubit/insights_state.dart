import 'package:equatable/equatable.dart';
import '../../domain/entities/insight.dart';

abstract class InsightsState extends Equatable {
  const InsightsState();

  @override
  List<Object?> get props => [];
}

class InsightsInitial extends InsightsState {
  const InsightsInitial();
}

class InsightsLoading extends InsightsState {
  const InsightsLoading();
}

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