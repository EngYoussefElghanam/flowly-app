import 'package:flowly/data/models/staff_model.dart';
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
    required String token,
    required int ownerId,
  }) async {
    emit(StaffLoading());
    try {
      await _authRepo.createEmployee(
        name: name,
        email: email,
        password: password,
        phone: phone,
        token: token,
        ownerId: ownerId,
      );
      emit(StaffVerifying(email));
    } catch (e) {
      emit(StaffError(e.toString().replaceAll("Exception: ", "")));
    }
  }

  Future<void> verifyStaff(String email, String code, String token) async {
    emit(StaffLoading());
    try {
      await _authRepo.verifyStaff(code, email);
      final employees = await _authRepo.getEmployees(token);
      emit(StaffSuccess(employees));
    } catch (e) {
      emit(StaffError(e.toString().replaceAll("Exception: ", "")));
    }
  }

  Future<void> getEmployees(String token) async {
    emit(StaffLoading());
    try {
      final List<StaffModel> employees = await _authRepo.getEmployees(token);
      emit(StaffSuccess(employees));
    } catch (e) {
      emit(StaffError(e.toString().replaceAll("Exception: ", "")));
    }
  }

  Future<void> deleteEmployee(String token, int intendedId) async {
    emit(StaffLoading());
    try {
      await _authRepo.deleteUser(token, intendedId);
      final List<StaffModel> employees = await _authRepo.getEmployees(token);
      emit(StaffSuccess(employees));
    } catch (e) {
      emit(StaffError(e.toString().replaceAll("Exception: ", "")));
    }
  }
}
