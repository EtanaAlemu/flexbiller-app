part of 'auth_bloc.dart';

abstract class AuthEvent {}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;
  final bool rememberMe;

  LoginRequested({
    required this.email,
    required this.password,
    this.rememberMe = false,
  });
}

class LogoutRequested extends AuthEvent {}

class CheckAuthStatus extends AuthEvent {}

class RefreshTokenRequested extends AuthEvent {}

class SetUserAuthenticated extends AuthEvent {
  final bool isAuthenticated;
  final String? method; // 'email_password' or 'biometric'

  SetUserAuthenticated({required this.isAuthenticated, this.method});
}

class BiometricAuthenticationRequested extends AuthEvent {
  final String reason;

  BiometricAuthenticationRequested({required this.reason});
}

class BiometricAuthSuccess extends AuthEvent {}

class BiometricAuthFailure extends AuthEvent {
  final String message;

  BiometricAuthFailure({required this.message});
}

class ForgotPasswordRequested extends AuthEvent {
  final String email;

  ForgotPasswordRequested({required this.email});
}

class ChangePasswordRequested extends AuthEvent {
  final String oldPassword;
  final String newPassword;

  ChangePasswordRequested({
    required this.oldPassword,
    required this.newPassword,
  });
}

class ResetPasswordRequested extends AuthEvent {
  final String token;
  final String newPassword;

  ResetPasswordRequested({required this.token, required this.newPassword});
}
