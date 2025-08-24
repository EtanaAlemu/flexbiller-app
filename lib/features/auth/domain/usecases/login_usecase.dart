import 'package:injectable/injectable.dart';
import '../repositories/auth_repository.dart';
import '../entities/user.dart';

@injectable
class LoginUseCase {
  final AuthRepository repository;
  
  LoginUseCase(this.repository);
  
  Future<User> call(String email, String password) async {
    return await repository.login(email, password);
  }
}
