import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import '../../../../core/bloc/bloc_error_handler_mixin.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/forgot_password_usecase.dart';
import '../../domain/usecases/change_password_usecase.dart';
import '../../domain/usecases/reset_password_usecase.dart';
import '../../domain/usecases/update_user_usecase.dart';
import '../../domain/usecases/refresh_token_usecase.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../../../core/errors/exceptions.dart';

part 'auth_event.dart';
part 'auth_state.dart';

@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> with BlocErrorHandlerMixin {
  final LoginUseCase _loginUseCase;
  final LogoutUseCase _logoutUseCase;
  final ForgotPasswordUseCase _forgotPasswordUseCase;
  final ChangePasswordUseCase _changePasswordUseCase;
  final ResetPasswordUseCase _resetPasswordUseCase;
  final UpdateUserUseCase _updateUserUseCase;
  final RefreshTokenUseCase _refreshTokenUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final Logger _logger = Logger();

  AuthBloc({
    required LoginUseCase loginUseCase,
    required LogoutUseCase logoutUseCase,
    required ForgotPasswordUseCase forgotPasswordUseCase,
    required ChangePasswordUseCase changePasswordUseCase,
    required ResetPasswordUseCase resetPasswordUseCase,
    required UpdateUserUseCase updateUserUseCase,
    required RefreshTokenUseCase refreshTokenUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
  }) : _loginUseCase = loginUseCase,
       _logoutUseCase = logoutUseCase,
       _forgotPasswordUseCase = forgotPasswordUseCase,
       _changePasswordUseCase = changePasswordUseCase,
       _resetPasswordUseCase = resetPasswordUseCase,
       _updateUserUseCase = updateUserUseCase,
       _refreshTokenUseCase = refreshTokenUseCase,
       _getCurrentUserUseCase = getCurrentUserUseCase,
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
        final userFriendlyMessage = handleException(e, context: 'login');
        emit(LoginFailure('Authentication Failed', userFriendlyMessage));
      }
    } catch (e) {
      final userFriendlyMessage = handleException(e, context: 'login');
      emit(LoginFailure('Error', userFriendlyMessage));
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
      handleException(e, context: 'logout');
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
      _logger.d('🔍 Checking authentication status...');
      final user = await _getCurrentUserUseCase();
      if (user != null) {
        _logger.i('✅ User is authenticated: ${user.email}');
        emit(AuthSuccess(user));
      } else {
        _logger.d('ℹ️ No authenticated user found');
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      final message = handleException(e, context: 'check_auth_status');
      emit(AuthFailure(message));
    }
  }

  Future<void> _onRefreshTokenRequested(
    RefreshTokenRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      _logger.i('🔄 Refreshing authentication token...');

      // Call refresh token use case
      await _refreshTokenUseCase();

      _logger.i('✅ Token refreshed successfully');

      // Get the updated user after token refresh
      // The repository should have updated the user data with the new token
      final user = await _getCurrentUserUseCase();

      if (user != null) {
        _logger.i('✅ User authenticated after token refresh: ${user.email}');
        emit(AuthSuccess(user));
      } else {
        _logger.w('⚠️ No user found after token refresh');
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      final message = handleException(e, context: 'token_refresh');
      emit(AuthFailure(message));
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
      final userFriendlyMessage = handleException(
        e,
        context: 'forgot_password',
      );
      emit(ForgotPasswordFailure(userFriendlyMessage));
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
    } catch (e) {
      final userFriendlyMessage = handleException(
        e,
        context: 'change_password',
      );
      emit(ChangePasswordFailure(userFriendlyMessage));
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
      final userFriendlyMessage = handleException(e, context: 'reset_password');
      emit(ResetPasswordFailure(userFriendlyMessage));
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
      final userFriendlyMessage = handleException(e, context: 'update_user');
      emit(UpdateUserFailure(userFriendlyMessage));
    }
  }
}
