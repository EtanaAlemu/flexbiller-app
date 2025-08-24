import 'package:injectable/injectable.dart';
import '../repositories/auth_repository.dart';

@injectable
class ResetPasswordUseCase {
  final AuthRepository _authRepository;

  ResetPasswordUseCase(this._authRepository);

  Future<void> call(String token, String newPassword) async {
    return await _authRepository.resetPassword(token, newPassword);
  }
}
