import 'package:injectable/injectable.dart';
import '../repositories/auth_repository.dart';
import '../entities/user.dart';

@injectable
class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<User> call(
    String email,
    String password, {
    bool rememberMe = false,
  }) async {
    return await repository.login(email, password, rememberMe: rememberMe);
  }
}
