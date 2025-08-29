import '../entities/user.dart';

import '../../data/models/auth_response.dart';

abstract class AuthRepository {
  Future<User> login(String email, String password, {bool rememberMe = false});
  Future<User> register(String email, String password, String name);
  Future<void> logout();
  Future<User?> getCurrentUser();
  Future<bool> isAuthenticated();
  Future<AuthResponse> refreshToken();
  Future<Map<String, dynamic>> getTokenStatus();
  Future<void> forgotPassword(String email);
  Future<void> changePassword(String oldPassword, String newPassword);
  Future<void> resetPassword(String token, String newPassword);
}
