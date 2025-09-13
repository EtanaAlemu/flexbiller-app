import 'package:injectable/injectable.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

@injectable
class UpdateUserUseCase {
  final AuthRepository _authRepository;

  UpdateUserUseCase(this._authRepository);

  Future<User> call(User user) async {
    return await _authRepository.updateUser(user);
  }
}
