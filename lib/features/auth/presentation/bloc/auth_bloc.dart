import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/forgot_password_usecase.dart';
import '../../domain/usecases/change_password_usecase.dart';
import '../../domain/usecases/reset_password_usecase.dart';
import '../../domain/usecases/update_user_usecase.dart';
import '../../../../core/errors/exceptions.dart';

part 'auth_event.dart';
part 'auth_state.dart';

@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase _loginUseCase;
  final LogoutUseCase _logoutUseCase;
  final ForgotPasswordUseCase _forgotPasswordUseCase;
  final ChangePasswordUseCase _changePasswordUseCase;
  final ResetPasswordUseCase _resetPasswordUseCase;
  final UpdateUserUseCase _updateUserUseCase;
  final Logger _logger = Logger();

  AuthBloc({
    required LoginUseCase loginUseCase,
    required LogoutUseCase logoutUseCase,
    required ForgotPasswordUseCase forgotPasswordUseCase,
    required ChangePasswordUseCase changePasswordUseCase,
    required ResetPasswordUseCase resetPasswordUseCase,
    required UpdateUserUseCase updateUserUseCase,
  }) : _loginUseCase = loginUseCase,
       _logoutUseCase = logoutUseCase,
       _forgotPasswordUseCase = forgotPasswordUseCase,
       _changePasswordUseCase = changePasswordUseCase,
       _resetPasswordUseCase = resetPasswordUseCase,
       _updateUserUseCase = updateUserUseCase,
       super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<RefreshTokenRequested>(_onRefreshTokenRequested);
    on<ForgotPasswordRequested>(_onForgotPasswordRequested);
    on<ChangePasswordRequested>(_onChangePasswordRequested);
    on<ResetPasswordRequested>(_onResetPasswordRequested);
    on<UpdateUserRequested>(_onUpdateUserRequested);
    on<SetUserAuthenticated>(_onSetUserAuthenticated);
    on<BiometricAuthenticationRequested>(_onBiometricAuthenticationRequested);
    on<BiometricAuthSuccess>(_onBiometricAuthSuccess);
    on<BiometricAuthFailure>(_onBiometricAuthFailure);
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(LoginLoading());
    try {
      final user = await _loginUseCase(
        event.email,
        event.password,
        rememberMe: event.rememberMe,
      );
      emit(LoginSuccess(user));

      // Also emit the user authenticated state
      emit(
        UserAuthenticated(
          isAuthenticated: true,
          method: 'email_password',
          authenticatedAt: DateTime.now(),
        ),
      );
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

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      _logger.i('🔄 Logout requested - Starting logout process');
      
      // Execute logout use case to clear all data and stop background operations
      await _logoutUseCase();
      
      _logger.i('✅ Logout completed successfully');
      emit(AuthUnauthenticated());
    } catch (e) {
      _logger.e('❌ Error during logout: $e');
      // Even if logout fails, we should still emit unauthenticated state
      emit(AuthUnauthenticated());
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

  Future<void> _onSetUserAuthenticated(
    SetUserAuthenticated event,
    Emitter<AuthState> emit,
  ) async {
    emit(
      UserAuthenticated(
        isAuthenticated: event.isAuthenticated,
        method: event.method,
        authenticatedAt: DateTime.now(),
      ),
    );
  }

  Future<void> _onBiometricAuthenticationRequested(
    BiometricAuthenticationRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(BiometricAuthenticationLoading());
  }

  Future<void> _onBiometricAuthSuccess(
    BiometricAuthSuccess event,
    Emitter<AuthState> emit,
  ) async {
    // Update the user authenticated state
    emit(
      UserAuthenticated(
        isAuthenticated: true,
        method: 'biometric',
        authenticatedAt: DateTime.now(),
      ),
    );
  }

  Future<void> _onBiometricAuthFailure(
    BiometricAuthFailure event,
    Emitter<AuthState> emit,
  ) async {
    emit(BiometricAuthenticationFailure(message: event.message));
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
    _logger.i(
      '🔄 Change Password Requested - Starting password change process',
    );
    _logger.d(
      '📝 Change Password Details: Old password length: ${event.oldPassword.length}, New password length: ${event.newPassword.length}',
    );

    emit(ChangePasswordLoading());
    _logger.i('⏳ Change Password Loading State Emitted');

    try {
      _logger.i('🚀 Executing ChangePasswordUseCase...');
      await _changePasswordUseCase(event.oldPassword, event.newPassword);

      _logger.i('✅ Password changed successfully via API');
      emit(
        ChangePasswordSuccess(
          'Password changed successfully. Please log in with your new password.',
        ),
      );
      _logger.i('🎉 ChangePasswordSuccess State Emitted');
    } on AuthException catch (e) {
      _logger.e('❌ AuthException during password change: ${e.message}');
      emit(ChangePasswordFailure(e.message));
      _logger.i('💥 ChangePasswordFailure State Emitted (AuthException)');
    } on ValidationException catch (e) {
      _logger.e('❌ ValidationException during password change: ${e.message}');
      emit(ChangePasswordFailure(e.message));
      _logger.i('💥 ChangePasswordFailure State Emitted (ValidationException)');
    } on NetworkException catch (e) {
      _logger.e('❌ NetworkException during password change: ${e.message}');
      emit(ChangePasswordFailure(e.message));
      _logger.i('💥 ChangePasswordFailure State Emitted (NetworkException)');
    } on ServerException catch (e) {
      _logger.e('❌ ServerException during password change: ${e.message}');
      emit(ChangePasswordFailure(e.message));
      _logger.i('💥 ChangePasswordFailure State Emitted (ServerException)');
    } catch (e) {
      _logger.e('❌ Unexpected error during password change: $e');
      emit(ChangePasswordFailure(e.toString()));
      _logger.i('💥 ChangePasswordFailure State Emitted (Unexpected Error)');
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

  Future<void> _onUpdateUserRequested(
    UpdateUserRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(UpdateUserLoading());
    try {
      final updatedUser = await _updateUserUseCase(event.user);
      emit(
        UpdateUserSuccess(
          user: updatedUser,
          message: 'Profile updated successfully',
        ),
      );
    } catch (e) {
      emit(UpdateUserFailure(e.toString()));
    }
  }
}
