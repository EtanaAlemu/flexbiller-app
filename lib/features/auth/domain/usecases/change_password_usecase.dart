import 'package:injectable/injectable.dart';
import '../repositories/auth_repository.dart';

@injectable
class ChangePasswordUseCase {
  final AuthRepository _authRepository;

  ChangePasswordUseCase(this._authRepository);

  Future<void> call(String oldPassword, String newPassword) async {
    return await _authRepository.changePassword(oldPassword, newPassword);
  }
}
