import 'package:injectable/injectable.dart';
import '../repositories/auth_repository.dart';
import '../entities/user.dart';

@injectable
class GetCurrentUserUseCase {
  final AuthRepository _repository;

  GetCurrentUserUseCase(this._repository);

  Future<User?> call() async {
    return await _repository.getCurrentUser();
  }
}

