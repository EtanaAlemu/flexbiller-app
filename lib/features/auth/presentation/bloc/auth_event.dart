abstract class AuthEvent {}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  LoginRequested({required this.email, required this.password});
}

class RegisterRequested extends AuthEvent {
  final String email;
  final String password;
  final String name;

  RegisterRequested({
    required this.email,
    required this.password,
    required this.name,
  });
}

class LogoutRequested extends AuthEvent {}

class CheckAuthStatus extends AuthEvent {}

class RefreshTokenRequested extends AuthEvent {}

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

  ResetPasswordRequested({
    required this.token,
    required this.newPassword,
  });
}
