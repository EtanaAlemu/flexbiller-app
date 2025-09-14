import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import '../../features/auth/domain/entities/user.dart';
import 'secure_storage_service.dart';

/// Service to manage the current user session context
/// This service tracks which user is currently active and provides
/// user-specific data isolation for local storage operations
@injectable
class UserSessionService {
  final SecureStorageService _secureStorage;
  final Logger _logger = Logger();

  // Current user context
  User? _currentUser;
  String? _currentUserId;

  UserSessionService(this._secureStorage);

  /// Get the currently active user
  User? get currentUser => _currentUser;

  /// Get the currently active user ID
  String? get currentUserId => _currentUserId;

  /// Check if a user is currently active
  bool get hasActiveUser => _currentUser != null && _currentUserId != null;

  /// Set the current user context
  Future<void> setCurrentUser(User user) async {
    try {
      _logger.d('Setting current user: ${user.email} (ID: ${user.id})');
      print('DEBUG: setCurrentUser called with user: ${user.email}');

      _currentUser = user;
      _currentUserId = user.id;

      // Store current user ID in secure storage for persistence across app restarts
      await _secureStorage.write('current_user_id', user.id);

      _logger.d('Current user set successfully: ${user.email}');
    } catch (e) {
      _logger.e('Error setting current user: $e');
      rethrow;
    }
  }

  /// Clear the current user context (logout)
  Future<void> clearCurrentUser() async {
    try {
      _logger.d('Clearing current user context');

      _currentUser = null;
      _currentUserId = null;

      // Remove current user ID from secure storage
      await _secureStorage.delete('current_user_id');

      _logger.d('Current user context cleared');
    } catch (e) {
      _logger.e('Error clearing current user context: $e');
      rethrow;
    }
  }

  /// Restore current user context from secure storage
  /// This is called during app initialization to restore the last active user
  Future<void> restoreCurrentUserContext() async {
    try {
      _logger.d('Restoring current user context from secure storage');
      print('DEBUG: restoreCurrentUserContext called');

      final userId = await _secureStorage.read('current_user_id');
      if (userId != null) {
        _currentUserId = userId;
        _logger.d('Restored current user ID: $userId');

        // Note: We only restore the user ID here. The full User object
        // will be loaded by the auth repository when needed.
        // This is intentional for security reasons - we don't store
        // the full user object in secure storage.
      } else {
        _logger.d('No current user ID found in secure storage');
      }
    } catch (e) {
      _logger.e('Error restoring current user context: $e');
      // Don't rethrow - this is not critical for app startup
    }
  }

  /// Get current user info for debugging
  Map<String, dynamic> getCurrentUserInfo() {
    return {
      'hasActiveUser': hasActiveUser,
      'currentUserId': _currentUserId,
      'currentUserEmail': _currentUser?.email,
      'currentUserName': _currentUser?.name,
    };
  }

  /// Validate that we have an active user context
  void validateUserContext() {
    if (!hasActiveUser) {
      throw Exception(
        'No active user context. User must be logged in to perform this operation.',
      );
    }
  }

  /// Get current user ID with validation
  String getCurrentUserIdOrThrow() {
    validateUserContext();
    return _currentUserId!;
  }

  /// Get current user ID without throwing exception (returns null if no user)
  String? getCurrentUserIdOrNull() {
    print(
      'DEBUG: getCurrentUserIdOrNull called - hasActiveUser: $hasActiveUser, currentUserId: $_currentUserId',
    );
    return _currentUserId;
  }
}
