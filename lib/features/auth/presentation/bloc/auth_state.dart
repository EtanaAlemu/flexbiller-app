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

class UserAuthenticated extends AuthState {
  final bool isAuthenticated;
  final String? method; // 'email_password' or 'biometric'
  final DateTime authenticatedAt;

  UserAuthenticated({
    required this.isAuthenticated,
    this.method,
    required this.authenticatedAt,
  });
}

class BiometricAuthenticationLoading extends AuthState {}

class BiometricAuthenticationSuccess extends AuthState {
  final DateTime authenticatedAt;

  BiometricAuthenticationSuccess({required this.authenticatedAt});
}

class BiometricAuthenticationFailure extends AuthState {
  final String message;

  BiometricAuthenticationFailure({required this.message});
}

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

class UpdateUserLoading extends AuthState {}

class UpdateUserSuccess extends AuthState {
  final User user;
  final String message;

  UpdateUserSuccess({required this.user, required this.message});
}

class UpdateUserFailure extends AuthState {
  final String message;

  UpdateUserFailure(this.message);
}
