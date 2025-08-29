import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import '../repositories/auth_repository.dart';

@injectable
class ChangePasswordUseCase {
  final AuthRepository _authRepository;
  final Logger _logger = Logger();

  ChangePasswordUseCase(this._authRepository);

  Future<void> call(String oldPassword, String newPassword) async {
    _logger.i('🔐 ChangePasswordUseCase.execute() - Starting password change');
    _logger.d(
      '📝 UseCase Input: Old password length: ${oldPassword.length}, New password length: ${newPassword.length}',
    );

    try {
      _logger.i('📡 Calling AuthRepository.changePassword()...');
      await _authRepository.changePassword(oldPassword, newPassword);
      _logger.i('✅ ChangePasswordUseCase completed successfully');
    } catch (e) {
      _logger.e('❌ ChangePasswordUseCase failed: $e');
      rethrow;
    }
  }
}
