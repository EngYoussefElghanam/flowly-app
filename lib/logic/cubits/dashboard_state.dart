part of 'dashboard_cubit.dart';

sealed class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object> get props => [];
}

final class DashboardInitial extends DashboardState {}

final class DashboardLoading extends DashboardState {}

final class DashboardSuccess extends DashboardState {
  final DashboardStatsModel stats;
  const DashboardSuccess(this.stats);
}

final class DashboardError extends DashboardState {
  final String message;
  const DashboardError(this.message);
}
