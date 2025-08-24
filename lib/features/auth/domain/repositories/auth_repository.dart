import '../entities/user.dart';

import '../../data/models/auth_response.dart';

abstract class AuthRepository {
  Future<User> login(String email, String password);
  Future<User> register(String email, String password, String name);
  Future<void> logout();
  Future<User?> getCurrentUser();
  Future<bool> isAuthenticated();
  Future<AuthResponse> refreshToken();
  Future<void> forgotPassword(String email);
}

