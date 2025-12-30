import 'package:flowly/data/repositories/customer_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'add_customer_state.dart';

class AddCustomerCubit extends Cubit<AddCustomerState> {
  final CustomerRepository _repo;
  AddCustomerCubit(this._repo) : super(AddCustomerInitial());
  Future<void> addCustomer({
    required String token,
    required String name,
    required String phone,
    required String city,
    required String address,
  }) async {
    emit(AddCustomerLoading());
    try {
      await _repo.createCustomer(
        token: token,
        name: name,
        phone: phone,
        city: city,
        address: address,
      );
      emit(AddCustomerSuccess());
    } catch (e) {
      emit(AddCustomerError("Error adding customer $e"));
    }
  }
}
