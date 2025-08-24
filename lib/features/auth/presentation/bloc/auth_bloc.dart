import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/forgot_password_usecase.dart';
import '../../domain/usecases/change_password_usecase.dart';
import '../../domain/usecases/reset_password_usecase.dart';
import '../../../../core/errors/exceptions.dart';

part 'auth_event.dart';
part 'auth_state.dart';

@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase _loginUseCase;
  final ForgotPasswordUseCase _forgotPasswordUseCase;
  final ChangePasswordUseCase _changePasswordUseCase;
  final ResetPasswordUseCase _resetPasswordUseCase;

  AuthBloc({
    required LoginUseCase loginUseCase,
    required ForgotPasswordUseCase forgotPasswordUseCase,
    required ChangePasswordUseCase changePasswordUseCase,
    required ResetPasswordUseCase resetPasswordUseCase,
  }) : _loginUseCase = loginUseCase,
       _forgotPasswordUseCase = forgotPasswordUseCase,
       _changePasswordUseCase = changePasswordUseCase,
       _resetPasswordUseCase = resetPasswordUseCase,
       super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<ForgotPasswordRequested>(_onForgotPasswordRequested);
    on<ChangePasswordRequested>(_onChangePasswordRequested);
    on<ResetPasswordRequested>(_onResetPasswordRequested);
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(LoginLoading());
    try {
      final user = await _loginUseCase(event.email, event.password);
      emit(LoginSuccess(user));
    } on AuthException catch (e) {
      // Handle specific EASYBILL_ADMIN restriction
      if (e.message.contains('EASYBILL_ADMIN users must use the web version')) {
        emit(
          LoginFailure(
            'Access Restricted',
            'EASYBILL_ADMIN users must use the web version. Please login at the web portal.',
            isWebOnlyUser: true,
          ),
        );
      } else {
        emit(LoginFailure('Authentication Failed', e.message));
      }
    } catch (e) {
      emit(LoginFailure('Error', e.toString()));
    }
  }

  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      // TODO: Implement register use case
      // final user = await _registerUseCase(event.email, event.password, event.name);
      // emit(AuthSuccess(user));
      emit(AuthFailure('Register not implemented yet'));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      // TODO: Implement logout use case
      // await _logoutUseCase();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      // TODO: Implement check auth status use case
      // final user = await _getCurrentUserUseCase();
      // if (user != null) {
      //   emit(AuthSuccess(user));
      // } else {
      //   emit(AuthUnauthenticated());
      // }
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onRefreshTokenRequested(
    RefreshTokenRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      // TODO: Implement refresh token use case
      // await _refreshTokenUseCase();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onForgotPasswordRequested(
    ForgotPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(ForgotPasswordLoading());
    try {
      await _forgotPasswordUseCase(event.email);
      emit(
        ForgotPasswordSuccess(
          'Password reset email sent successfully. Please check your email.',
        ),
      );
    } catch (e) {
      emit(ForgotPasswordFailure(e.toString()));
    }
  }

  Future<void> _onChangePasswordRequested(
    ChangePasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(ChangePasswordLoading());
    try {
      await _changePasswordUseCase(event.oldPassword, event.newPassword);
      emit(
        ChangePasswordSuccess(
          'Password changed successfully. Please log in with your new password.',
        ),
      );
    } catch (e) {
      emit(ChangePasswordFailure(e.toString()));
    }
  }

  Future<void> _onResetPasswordRequested(
    ResetPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(ResetPasswordLoading());
    try {
      await _resetPasswordUseCase(event.token, event.newPassword);
      emit(
        ResetPasswordSuccess(
          'Password reset successfully. You can now login with your new password.',
        ),
      );
    } catch (e) {
      emit(ResetPasswordFailure(e.toString()));
    }
  }
}
