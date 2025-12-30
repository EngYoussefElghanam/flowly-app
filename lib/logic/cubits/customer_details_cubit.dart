import 'package:flowly/data/models/customer_model.dart';
import 'package:flowly/data/repositories/customer_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'customer_details_state.dart';

class CustomerDetailsCubit extends Cubit<CustomerDetailsState> {
  final CustomerRepository _repo;
  CustomerDetailsCubit(this._repo) : super(CustomerDetailsInitial());
  Future<void> getCustomerDetails(int id, String token) async {
    emit(CustomerDetailsLoading());
    try {
      final customer = await _repo.getCustomerDetails(id, token);
      emit(CustomerDetailsSuccess(customer));
    } catch (e) {
      emit(CustomerDetailsError('Error Getting details : $e'));
    }
  }
}
