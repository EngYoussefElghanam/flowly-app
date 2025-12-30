part of 'add_customer_cubit.dart';

sealed class AddCustomerState extends Equatable {
  const AddCustomerState();

  @override
  List<Object> get props => [];
}

final class AddCustomerInitial extends AddCustomerState {}

final class AddCustomerLoading extends AddCustomerState {}

final class AddCustomerSuccess extends AddCustomerState {}

final class AddCustomerError extends AddCustomerState {
  final String message;
  AddCustomerError(this.message);
}
