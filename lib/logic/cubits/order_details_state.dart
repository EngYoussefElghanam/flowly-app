part of 'order_details_cubit.dart';

sealed class OrderDetailsState extends Equatable {
  const OrderDetailsState();
  @override
  List<Object> get props => [];
}

final class OrderDetailsInitial extends OrderDetailsState {}

final class OrderDetailsLoading
    extends OrderDetailsState {} // Renamed to CamelCase

final class OrderDetailsSuccess extends OrderDetailsState {
  final OrderModel orderDetails;

  // 🆕 Add this flag
  final bool isUpdatingStatus;

  const OrderDetailsSuccess(this.orderDetails, {this.isUpdatingStatus = false});

  // Helper to copy state while changing the flag
  OrderDetailsSuccess copyWith({
    OrderModel? orderDetails,
    bool? isUpdatingStatus,
  }) {
    return OrderDetailsSuccess(
      orderDetails ?? this.orderDetails,
      isUpdatingStatus: isUpdatingStatus ?? this.isUpdatingStatus,
    );
  }

  @override
  List<Object> get props => [orderDetails, isUpdatingStatus];
}

final class OrderDetailsError extends OrderDetailsState {
  final String message;
  const OrderDetailsError(this.message);
}
