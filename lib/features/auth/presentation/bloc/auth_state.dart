import '../../domain/entities/user.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final User user;

  AuthSuccess(this.user);
}

class AuthFailure extends AuthState {
  final String message;

  AuthFailure(this.message);
}

class AuthUnauthenticated extends AuthState {}

class ForgotPasswordLoading extends AuthState {}

class ForgotPasswordSuccess extends AuthState {
  final String message;

  ForgotPasswordSuccess(this.message);
}

class ForgotPasswordFailure extends AuthState {
  final String message;

  ForgotPasswordFailure(this.message);
}

class ChangePasswordLoading extends AuthState {}

class ChangePasswordSuccess extends AuthState {
  final String message;

  ChangePasswordSuccess(this.message);
}

class ChangePasswordFailure extends AuthState {
  final String message;

  ChangePasswordFailure(this.message);
}
