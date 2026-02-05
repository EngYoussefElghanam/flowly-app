part of 'auth_cubit.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

final class AuthInitial extends AuthState {}

final class AuthLoading extends AuthState {}

final class AuthVerifying extends AuthState {
  final String email;
  const AuthVerifying(this.email);
}

final class AuthSuccess extends AuthState {
  final UserModel user;
  const AuthSuccess(this.user);
}

final class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
}
