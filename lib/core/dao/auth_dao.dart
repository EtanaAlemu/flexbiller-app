class AuthDao {
  // Login request body
  static Map<String, dynamic> loginBody(String email, String password) {
    return {
      'email': email,
      'password': password,
    };
  }

  // Register request body
  static Map<String, dynamic> registerBody(String email, String password, String name) {
    return {
      'email': email,
      'password': password,
      'name': name,
    };
  }

  // Refresh token request body
  static Map<String, dynamic> refreshTokenBody(String refreshToken) {
    return {
      'refreshToken': refreshToken,
    };
  }

  // Forgot password request body
  static Map<String, dynamic> forgotPasswordBody(String email) {
    return {
      'email': email,
    };
  }

  // Change password request body
  static Map<String, dynamic> changePasswordBody(String oldPassword, String newPassword) {
    return {
      'oldPassword': oldPassword,
      'newPassword': newPassword,
    };
  }

  // Reset password request body
  static Map<String, dynamic> resetPasswordBody(String token, String newPassword) {
    return {
      'token': token,
      'password': newPassword,
    };
  }
}
