import 'dart:async';

import 'package:flowly/core/session_manager.dart';
import 'package:flowly/data/repositories/auth_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flowly/data/models/user_model.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepo;
  late final StreamSubscription _sub;
  AuthCubit(this._authRepo) : super(AuthInitial()) {
    _sub = SessionManager.onTokenExpired.listen((_) {
      logout();
    });
  }
  @override
  Future<void> close() {
    _sub.cancel();
    return super.close();
  }

  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    try {
      final user = await _authRepo.login(email, password);
      emit(AuthSuccess(user));
    } catch (e) {
      emit(AuthError("Login failed check your email/password $e"));
    }
  }

  Future<void> checkStatus() async {
    emit(AuthLoading());
    try {
      final user = await _authRepo.autoLogin();
      if (user != null) {
        emit(AuthSuccess(user));
      } else {
        emit(AuthInitial());
      }
    } catch (e) {
      emit(AuthInitial());
    }
  }

  Future<void> logout() async {
    emit(AuthLoading());
    try {
      await _authRepo.logout();
      emit(AuthInitial());
    } catch (e) {
      emit(AuthError("Failed to logout $e"));
    }
  }
}
