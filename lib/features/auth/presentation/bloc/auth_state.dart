part of 'auth_bloc.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class LoginLoading extends AuthState {}

class LoginSuccess extends AuthState {
  final User user;

  LoginSuccess(this.user);
}

class LoginFailure extends AuthState {
  final String title;
  final String message;
  final bool isWebOnlyUser;

  LoginFailure(this.title, this.message, {this.isWebOnlyUser = false});
}

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

class ResetPasswordLoading extends AuthState {}

class ResetPasswordSuccess extends AuthState {
  final String message;

  ResetPasswordSuccess(this.message);
}

class ResetPasswordFailure extends AuthState {
  final String message;

  ResetPasswordFailure(this.message);
}
