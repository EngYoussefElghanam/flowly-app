part of 'marketing_cubit.dart';

sealed class MarketingState extends Equatable {
  const MarketingState();

  @override
  List<Object> get props => [];
}

final class MarketingInitial extends MarketingState {}

final class MarketingLoading extends MarketingState {}

final class MarketingLoaded extends MarketingState {
  final List<MarketingOpportunity> opportunities;
  const MarketingLoaded(this.opportunities);
}

final class MarketingError extends MarketingState {
  final String message;
  const MarketingError(this.message);
}

//New state for enhancing readability
final class MarketingEmpty extends MarketingState {}
