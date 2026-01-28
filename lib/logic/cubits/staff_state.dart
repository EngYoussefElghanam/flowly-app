part of 'staff_cubit.dart';

abstract class StaffState extends Equatable {
  const StaffState();

  @override
  List<Object> get props => [];
}

class StaffInitial extends StaffState {}

class StaffLoading extends StaffState {}

class StaffSuccess extends StaffState {}

class StaffError extends StaffState {
  final String message;
  const StaffError(this.message);

  @override
  List<Object> get props => [message];
}
