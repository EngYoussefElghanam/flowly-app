part of 'customer_stats_cubit.dart';

sealed class CustomerStatsState extends Equatable {
  const CustomerStatsState();

  @override
  List<Object> get props => [];
}

final class CustomerStatsInitial extends CustomerStatsState {}

final class CustomerStatsLoading extends CustomerStatsState {}

final class CustomerStatsLoaded extends CustomerStatsState {
  final String totalSpent;
  final String favoriteItem;
  final int totalOrders;
  const CustomerStatsLoaded(
    this.totalSpent,
    this.favoriteItem,
    this.totalOrders,
  );
}

final class CustomerStatsError extends CustomerStatsState {
  final String message;
  const CustomerStatsError(this.message);
}
