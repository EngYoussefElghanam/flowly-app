import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flowly/data/repositories/auth_repository.dart';

part 'staff_state.dart';

class StaffCubit extends Cubit<StaffState> {
  final AuthRepository _authRepo;

  StaffCubit(this._authRepo) : super(StaffInitial());

  Future<void> addStaff({
    required String name,
    required String email,
    required String password,
    required String phone,
    required int ownerId,
  }) async {
    emit(StaffLoading());
    try {
      await _authRepo.createEmployee(
        name: name,
        email: email,
        password: password,
        phone: phone,
        ownerId: ownerId,
      );
      emit(StaffSuccess());
    } catch (e) {
      emit(StaffError(e.toString().replaceAll("Exception: ", "")));
    }
  }
}
