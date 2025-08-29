import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import '../constants/app_constants.dart';

@injectable
class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService(this._storage);

  // Write data to secure storage
  Future<void> write(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  // Read data from secure storage
  Future<String?> read(String key) async {
    return await _storage.read(key: key);
  }

  // Delete data from secure storage
  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  // Check if key exists
  Future<bool> containsKey(String key) async {
    return await _storage.containsKey(key: key);
  }

  // Clear all data
  Future<void> clear() async {
    await _storage.deleteAll();
  }

  // Get all keys
  Future<List<String>> getAllKeys() async {
    return await _storage.readAll().then((map) => map.keys.toList());
  }

  // Auth token specific methods
  Future<void> saveAuthToken(String token) async {
    await write(AppConstants.authTokenKey, token);
  }

  Future<String?> getAuthToken() async {
    return await read(AppConstants.authTokenKey);
  }

  Future<void> saveRefreshToken(String token) async {
    await write(AppConstants.refreshTokenKey, token);
  }

  Future<String?> getRefreshToken() async {
    return await read(AppConstants.refreshTokenKey);
  }

  Future<void> clearAuthTokens() async {
    await delete(AppConstants.authTokenKey);
    await delete(AppConstants.refreshTokenKey);
    await delete(AppConstants.tokenExpirationKey);
  }

  // Token expiration methods
  Future<void> saveTokenExpiration(int expiresIn) async {
    // Calculate expiration timestamp (current time + expires_in seconds)
    final expirationTimestamp =
        DateTime.now().millisecondsSinceEpoch + (expiresIn * 1000);
    await write(
      AppConstants.tokenExpirationKey,
      expirationTimestamp.toString(),
    );
  }

  Future<DateTime?> getTokenExpiration() async {
    final timestamp = await read(AppConstants.tokenExpirationKey);
    if (timestamp != null) {
      return DateTime.fromMillisecondsSinceEpoch(int.parse(timestamp));
    }
    return null;
  }

  Future<bool> isTokenExpired() async {
    final expiration = await getTokenExpiration();
    if (expiration == null) return true;

    // Check if current time is past expiration (with 30 second buffer)
    final now = DateTime.now();
    final bufferTime = Duration(seconds: 30);
    return now.isAfter(expiration.subtract(bufferTime));
  }

  Future<bool> hasValidToken() async {
    final token = await getAuthToken();
    if (token == null) return false;

    return !await isTokenExpired();
  }

  // Debug method to get token information
  Future<Map<String, dynamic>> getTokenInfo() async {
    final token = await getAuthToken();
    final refreshToken = await getRefreshToken();
    final expiration = await getTokenExpiration();
    final isExpired = await isTokenExpired();

    return {
      'hasAccessToken': token != null,
      'hasRefreshToken': refreshToken != null,
      'expirationTime': expiration?.toIso8601String(),
      'isExpired': isExpired,
      'currentTime': DateTime.now().toIso8601String(),
      'timeUntilExpiration': expiration != null
          ? expiration.difference(DateTime.now()).inSeconds
          : null,
    };
  }

  // User data methods
  Future<void> saveUserId(String userId) async {
    await write(AppConstants.userIdKey, userId);
  }

  Future<String?> getUserId() async {
    return await read(AppConstants.userIdKey);
  }

  Future<void> saveUserEmail(String email) async {
    await write(AppConstants.userEmailKey, email);
  }

  Future<String?> getUserEmail() async {
    return await read(AppConstants.userEmailKey);
  }
}
