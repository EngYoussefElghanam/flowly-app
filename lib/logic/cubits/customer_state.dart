part of 'customer_cubit.dart';

sealed class CustomerState extends Equatable {
  const CustomerState();

  @override
  List<Object> get props => [];
}

final class CustomerInitial extends CustomerState {}

final class CustomerLoading extends CustomerState {}

final class CustomerSuccess extends CustomerState {
  final List<CustomerModel> customers;
  const CustomerSuccess(this.customers);
}

final class CustomerError extends CustomerState {
  final String message;
  const CustomerError(this.message);
}
