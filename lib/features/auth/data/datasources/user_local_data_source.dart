import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import '../../../../core/services/database_service.dart';
import '../../../../core/services/user_session_service.dart';
import '../../domain/entities/user.dart';

abstract class UserLocalDataSource {
  Future<void> saveUser(User user);
  Future<void> updateUser(User user);
  Future<User?> getUserById(String userId);
  Future<User?> getUserByEmail(String email);
  Future<List<User>> getAllUsers();
  Future<void> deleteUser(String userId);
  Future<void> deleteAllUsers();
  Future<void> saveAuthToken(
    String userId,
    String accessToken,
    String refreshToken,
    DateTime expiresAt,
  );
  Future<void> updateAuthToken(
    String userId,
    String accessToken,
    String refreshToken,
    DateTime expiresAt,
  );
  Future<Map<String, dynamic>?> getAuthTokenByUserId(String userId);
  Future<void> deleteAuthToken(String userId);
  Future<void> clearAllData();
}

@Injectable(as: UserLocalDataSource)
class UserLocalDataSourceImpl implements UserLocalDataSource {
  final DatabaseService _databaseService;
  final UserSessionService _userSessionService;
  final Logger _logger = Logger();

  UserLocalDataSourceImpl(this._databaseService, this._userSessionService);

  @override
  Future<void> saveUser(User user) async {
    try {
      _logger.d('Saving user to local database: ${user.email}');

      final userData = {
        'id': user.id,
        'email': user.email,
        'name': user.name,
        'role': user.role,
        'phone': user.phone,
        'tenant_id': user.tenantId,
        'role_id': user.roleId,
        'api_key': user.apiKey,
        'api_secret': user.apiSecret,
        'email_verified': user.emailVerified == true ? 1 : 0,
        'first_name': user.firstName,
        'last_name': user.lastName,
        'company': user.company,
        'department': user.department,
        'location': user.location,
        'position': user.position,
        'session_id': user.sessionId,
        'is_anonymous': user.isAnonymous == true ? 1 : 0,
        'created_at': user.createdAt.toIso8601String(),
        'updated_at': user.updatedAt.toIso8601String(),
      };

      await _databaseService.insertUser(userData);

      // Set the current user context after saving
      await _userSessionService.setCurrentUser(user);

      _logger.d('User saved successfully to local database: ${user.email}');
    } catch (e) {
      _logger.e('Error saving user to local database: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateUser(User user) async {
    try {
      _logger.d('Updating user in local database: ${user.email}');

      final userData = {
        'email': user.email,
        'name': user.name,
        'role': user.role,
        'phone': user.phone,
        'tenant_id': user.tenantId,
        'role_id': user.roleId,
        'api_key': user.apiKey,
        'api_secret': user.apiSecret,
        'email_verified': user.emailVerified == true ? 1 : 0,
        'first_name': user.firstName,
        'last_name': user.lastName,
        'company': user.company,
        'department': user.department,
        'location': user.location,
        'position': user.position,
        'session_id': user.sessionId,
        'is_anonymous': user.isAnonymous == true ? 1 : 0,
        'updated_at': DateTime.now().toIso8601String(),
      };

      await _databaseService.updateUser(user.id, userData);
      _logger.d('User updated successfully in local database: ${user.email}');
    } catch (e) {
      _logger.e('Error updating user in local database: $e');
      rethrow;
    }
  }

  @override
  Future<User?> getUserById(String userId) async {
    try {
      _logger.d('Retrieving user from local database by ID: $userId');

      final userData = await _databaseService.getUserById(userId);
      if (userData == null) {
        _logger.d('User not found in local database: $userId');
        return null;
      }

      final user = _mapDatabaseRowToUser(userData);
      _logger.d(
        'User retrieved successfully from local database: ${user.email}',
      );
      return user;
    } catch (e) {
      _logger.e('Error retrieving user from local database: $e');
      rethrow;
    }
  }

  @override
  Future<User?> getUserByEmail(String email) async {
    try {
      _logger.d('Retrieving user from local database by email: $email');

      final userData = await _databaseService.getUserByEmail(email);
      if (userData == null) {
        _logger.d('User not found in local database: $email');
        return null;
      }

      final user = _mapDatabaseRowToUser(userData);
      _logger.d(
        'User retrieved successfully from local database: ${user.email}',
      );
      return user;
    } catch (e) {
      _logger.e('Error retrieving user from local database: $e');
      rethrow;
    }
  }

  @override
  Future<List<User>> getAllUsers() async {
    try {
      _logger.d('Retrieving all users from local database');

      final usersData = await _databaseService.getAllUsers();
      final users = usersData.map(_mapDatabaseRowToUser).toList();

      _logger.d('Retrieved ${users.length} users from local database');
      return users;
    } catch (e) {
      _logger.e('Error retrieving all users from local database: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteUser(String userId) async {
    try {
      _logger.d('Deleting user from local database: $userId');

      await _databaseService.deleteUser(userId);
      _logger.d('User deleted successfully from local database: $userId');
    } catch (e) {
      _logger.e('Error deleting user from local database: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteAllUsers() async {
    try {
      _logger.d('Deleting all users from local database');

      await _databaseService.deleteAllUsers();
      _logger.d('All users deleted successfully from local database');
    } catch (e) {
      _logger.e('Error deleting all users from local database: $e');
      rethrow;
    }
  }

  @override
  Future<void> saveAuthToken(
    String userId,
    String accessToken,
    String refreshToken,
    DateTime expiresAt,
  ) async {
    try {
      _logger.d('Saving auth token to local database for user: $userId');

      final tokenData = {
        'user_id': userId,
        'access_token': accessToken,
        'refresh_token': refreshToken,
        'expires_at': expiresAt.toIso8601String(),
        'created_at': DateTime.now().toIso8601String(),
      };

      await _databaseService.insertAuthToken(tokenData);
      _logger.d(
        'Auth token saved successfully to local database for user: $userId',
      );
    } catch (e) {
      _logger.e('Error saving auth token to local database: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateAuthToken(
    String userId,
    String accessToken,
    String refreshToken,
    DateTime expiresAt,
  ) async {
    try {
      _logger.d('Updating auth token in local database for user: $userId');

      final tokenData = {
        'access_token': accessToken,
        'refresh_token': refreshToken,
        'expires_at': expiresAt.toIso8601String(),
      };

      await _databaseService.updateAuthToken(userId, tokenData);
      _logger.d(
        'Auth token updated successfully in local database for user: $userId',
      );
    } catch (e) {
      _logger.e('Error updating auth token in local database: $e');
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>?> getAuthTokenByUserId(String userId) async {
    try {
      _logger.d('Retrieving auth token from local database for user: $userId');

      final tokenData = await _databaseService.getAuthTokenByUserId(userId);
      if (tokenData == null) {
        _logger.d('Auth token not found in local database for user: $userId');
        return null;
      }

      _logger.d(
        'Auth token retrieved successfully from local database for user: $userId',
      );
      return tokenData;
    } catch (e) {
      _logger.e('Error retrieving auth token from local database: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteAuthToken(String userId) async {
    try {
      _logger.d('Deleting auth token from local database for user: $userId');

      await _databaseService.deleteAuthToken(userId);
      _logger.d(
        'Auth token deleted successfully from local database for user: $userId',
      );
    } catch (e) {
      _logger.e('Error deleting auth token from local database: $e');
      rethrow;
    }
  }

  @override
  Future<void> clearAllData() async {
    try {
      _logger.d('Clearing all data from local database');

      await _databaseService.deleteAllUsers();
      await _databaseService.deleteAllAuthTokens();

      // Clear the current user session
      await _userSessionService.clearCurrentUser();

      _logger.d('All data cleared successfully from local database');
    } catch (e) {
      _logger.e('Error clearing all data from local database: $e');
      rethrow;
    }
  }

  // Helper method to map database row to User entity
  User _mapDatabaseRowToUser(Map<String, dynamic> row) {
    return User(
      id: row['id'] as String,
      email: row['email'] as String,
      name: row['name'] as String,
      role: row['role'] as String,
      createdAt: DateTime.parse(row['created_at'] as String),
      updatedAt: DateTime.parse(row['updated_at'] as String),
      phone: row['phone'] as String?,
      tenantId: row['tenant_id'] as String?,
      roleId: row['role_id'] as String?,
      apiKey: row['api_key'] as String?,
      apiSecret: row['api_secret'] as String?,
      emailVerified: (row['email_verified'] as int?) == 1,
      firstName: row['first_name'] as String?,
      lastName: row['last_name'] as String?,
      company: row['company'] as String?,
      department: row['department'] as String?,
      location: row['location'] as String?,
      position: row['position'] as String?,
      sessionId: row['session_id'] as String?,
      isAnonymous: (row['is_anonymous'] as int?) == 1,
    );
  }
}
