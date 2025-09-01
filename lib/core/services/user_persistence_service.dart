import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import '../../features/auth/data/datasources/user_local_data_source.dart';
import '../../features/auth/domain/entities/user.dart';

@injectable
class UserPersistenceService {
  final UserLocalDataSource _userLocalDataSource;
  final Logger _logger = Logger();

  UserPersistenceService(this._userLocalDataSource);

  /// Save user to local database
  Future<void> saveUser(User user) async {
    try {
      _logger.d('Saving user to local database: ${user.email}');
      await _userLocalDataSource.saveUser(user);
      _logger.d('User saved successfully to local database');
    } catch (e) {
      _logger.e('Error saving user to local database: $e');
      rethrow;
    }
  }

  /// Update existing user in local database
  Future<void> updateUser(User user) async {
    try {
      _logger.d('Updating user in local database: ${user.email}');
      await _userLocalDataSource.updateUser(user);
      _logger.d('User updated successfully in local database');
    } catch (e) {
      _logger.e('Error updating user in local database: $e');
      rethrow;
    }
  }

  /// Get user by ID from local database
  Future<User?> getUserById(String userId) async {
    try {
      _logger.d('Retrieving user from local database by ID: $userId');
      final user = await _userLocalDataSource.getUserById(userId);
      if (user != null) {
        _logger.d(
          'User retrieved successfully from local database: ${user.email}',
        );
      } else {
        _logger.d('User not found in local database: $userId');
      }
      return user;
    } catch (e) {
      _logger.e('Error retrieving user from local database: $e');
      return null;
    }
  }

  /// Get user by email from local database
  Future<User?> getUserByEmail(String email) async {
    try {
      _logger.d('Retrieving user from local database by email: $email');
      final user = await _userLocalDataSource.getUserByEmail(email);
      if (user != null) {
        _logger.d(
          'User retrieved successfully from local database: ${user.email}',
        );
      } else {
        _logger.d('User not found in local database: $email');
      }
      return user;
    } catch (e) {
      _logger.e('Error retrieving user from local database: $e');
      return null;
    }
  }

  /// Get all users from local database
  Future<List<User>> getAllUsers() async {
    try {
      _logger.d('Retrieving all users from local database');
      final users = await _userLocalDataSource.getAllUsers();
      _logger.d('Retrieved ${users.length} users from local database');
      return users;
    } catch (e) {
      _logger.e('Error retrieving all users from local database: $e');
      return [];
    }
  }

  /// Delete user from local database
  Future<void> deleteUser(String userId) async {
    try {
      _logger.d('Deleting user from local database: $userId');
      await _userLocalDataSource.deleteUser(userId);
      _logger.d('User deleted successfully from local database');
    } catch (e) {
      _logger.e('Error deleting user from local database: $e');
      rethrow;
    }
  }

  /// Save auth token to local database
  Future<void> saveAuthToken(
    String userId,
    String accessToken,
    String refreshToken,
    DateTime expiresAt,
  ) async {
    try {
      _logger.d('Saving auth token to local database for user: $userId');
      await _userLocalDataSource.saveAuthToken(
        userId,
        accessToken,
        refreshToken,
        expiresAt,
      );
      _logger.d('Auth token saved successfully to local database');
    } catch (e) {
      _logger.e('Error saving auth token to local database: $e');
      rethrow;
    }
  }

  /// Update auth token in local database
  Future<void> updateAuthToken(
    String userId,
    String accessToken,
    String refreshToken,
    DateTime expiresAt,
  ) async {
    try {
      _logger.d('Updating auth token in local database for user: $userId');
      await _userLocalDataSource.updateAuthToken(
        userId,
        accessToken,
        refreshToken,
        expiresAt,
      );
      _logger.d('Auth token updated successfully in local database');
    } catch (e) {
      _logger.e('Error updating auth token in local database: $e');
      rethrow;
    }
  }

  /// Get auth token by user ID from local database
  Future<Map<String, dynamic>?> getAuthTokenByUserId(String userId) async {
    try {
      _logger.d('Retrieving auth token from local database for user: $userId');
      final tokenData = await _userLocalDataSource.getAuthTokenByUserId(userId);
      if (tokenData != null) {
        _logger.d('Auth token retrieved successfully from local database');
      } else {
        _logger.d('Auth token not found in local database for user: $userId');
      }
      return tokenData;
    } catch (e) {
      _logger.e('Error retrieving auth token from local database: $e');
      return null;
    }
  }

  /// Delete auth token from local database
  Future<void> deleteAuthToken(String userId) async {
    try {
      _logger.d('Deleting auth token from local database for user: $userId');
      await _userLocalDataSource.deleteAuthToken(userId);
      _logger.d('Auth token deleted successfully from local database');
    } catch (e) {
      _logger.e('Error deleting auth token from local database: $e');
      rethrow;
    }
  }

  /// Clear all user data from local database
  Future<void> clearAllUserData() async {
    try {
      _logger.d('Clearing all user data from local database');
      await _userLocalDataSource.clearAllData();
      _logger.d('All user data cleared successfully from local database');
    } catch (e) {
      _logger.e('Error clearing all user data from local database: $e');
      rethrow;
    }
  }

  /// Check if user exists in local database
  Future<bool> userExists(String userId) async {
    try {
      final user = await getUserById(userId);
      return user != null;
    } catch (e) {
      _logger.e('Error checking if user exists: $e');
      return false;
    }
  }

  /// Check if user exists by email in local database
  Future<bool> userExistsByEmail(String email) async {
    try {
      final user = await getUserByEmail(email);
      return user != null;
    } catch (e) {
      _logger.e('Error checking if user exists by email: $e');
      return false;
    }
  }

  /// Get user count in local database
  Future<int> getUserCount() async {
    try {
      final users = await getAllUsers();
      return users.length;
    } catch (e) {
      _logger.e('Error getting user count: $e');
      return 0;
    }
  }

  /// Update user's last activity timestamp
  Future<void> updateUserLastActivity(String userId) async {
    try {
      final user = await getUserById(userId);
      if (user != null) {
        final updatedUser = user.copyWith(updatedAt: DateTime.now());
        await updateUser(updatedUser);
        _logger.d('User last activity updated: $userId');
      }
    } catch (e) {
      _logger.e('Error updating user last activity: $e');
    }
  }

  /// Get users by role from local database
  Future<List<User>> getUsersByRole(String role) async {
    try {
      final allUsers = await getAllUsers();
      final filteredUsers = allUsers
          .where((user) => user.role == role)
          .toList();
      _logger.d('Retrieved ${filteredUsers.length} users with role: $role');
      return filteredUsers;
    } catch (e) {
      _logger.e('Error getting users by role: $e');
      return [];
    }
  }

  /// Search users by name or email in local database
  Future<List<User>> searchUsers(String query) async {
    try {
      final allUsers = await getAllUsers();
      final lowercaseQuery = query.toLowerCase();

      final filteredUsers = allUsers.where((user) {
        return user.name.toLowerCase().contains(lowercaseQuery) ||
            user.email.toLowerCase().contains(lowercaseQuery) ||
            (user.firstName?.toLowerCase().contains(lowercaseQuery) ?? false) ||
            (user.lastName?.toLowerCase().contains(lowercaseQuery) ?? false);
      }).toList();

      _logger.d('Found ${filteredUsers.length} users matching query: $query');
      return filteredUsers;
    } catch (e) {
      _logger.e('Error searching users: $e');
      return [];
    }
  }
}
