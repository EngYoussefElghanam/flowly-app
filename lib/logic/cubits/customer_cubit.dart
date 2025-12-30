import 'package:flowly/data/repositories/customer_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flowly/data/models/customer_model.dart';

part 'customer_state.dart';

class CustomerCubit extends Cubit<CustomerState> {
  final CustomerRepository _repo;
  CustomerCubit(this._repo) : super(CustomerInitial());
  Future<void> getCustomers(String token) async {
    emit(CustomerLoading());
    try {
      final customers = await _repo.getCustomers(token);
      emit(CustomerSuccess(customers));
    } catch (e) {
      emit(CustomerError("Error fetching customers $e"));
    }
  }
}
