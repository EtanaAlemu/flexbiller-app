import 'package:injectable/injectable.dart';
import '../repositories/auth_repository.dart';
import '../../data/models/auth_response.dart';

@injectable
class RefreshTokenUseCase {
  final AuthRepository _repository;

  RefreshTokenUseCase(this._repository);

  Future<AuthResponse> call() async {
    return await _repository.refreshToken();
  }
}

