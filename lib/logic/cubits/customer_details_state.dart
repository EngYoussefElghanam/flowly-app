part of 'customer_details_cubit.dart';

sealed class CustomerDetailsState extends Equatable {
  const CustomerDetailsState();

  @override
  List<Object> get props => [];
}

final class CustomerDetailsInitial extends CustomerDetailsState {}

final class CustomerDetailsLoading extends CustomerDetailsState {}

final class CustomerDetailsSuccess extends CustomerDetailsState {
  final CustomerModel customer;
  CustomerDetailsSuccess(this.customer);
}

final class CustomerDetailsError extends CustomerDetailsState {
  final String message;
  CustomerDetailsError(this.message);
}
