import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'secure_storage_service.dart';

/// Service for managing user notification preferences
@injectable
class NotificationPreferencesService {
  final SecureStorageService _secureStorage;
  final Logger _logger = Logger();

  static const String _emailNotificationsKey = 'notification_pref_email';
  static const String _pushNotificationsKey = 'notification_pref_push';
  static const String _reminderNotificationsKey = 'notification_pref_reminder';

  NotificationPreferencesService(this._secureStorage);

  /// Get email notification preference
  Future<bool> getEmailNotifications() async {
    try {
      final value = await _secureStorage.read(_emailNotificationsKey);
      return value == 'true';
    } catch (e) {
      _logger.e('Error reading email notification preference: $e');
      return true; // Default to enabled
    }
  }

  /// Set email notification preference
  Future<void> setEmailNotifications(bool enabled) async {
    try {
      await _secureStorage.write(_emailNotificationsKey, enabled.toString());
      _logger.d('Email notifications ${enabled ? 'enabled' : 'disabled'}');
    } catch (e) {
      _logger.e('Error saving email notification preference: $e');
      rethrow;
    }
  }

  /// Get push notification preference
  Future<bool> getPushNotifications() async {
    try {
      final value = await _secureStorage.read(_pushNotificationsKey);
      return value == 'true';
    } catch (e) {
      _logger.e('Error reading push notification preference: $e');
      return false; // Default to disabled
    }
  }

  /// Set push notification preference
  Future<void> setPushNotifications(bool enabled) async {
    try {
      await _secureStorage.write(_pushNotificationsKey, enabled.toString());
      _logger.d('Push notifications ${enabled ? 'enabled' : 'disabled'}');
    } catch (e) {
      _logger.e('Error saving push notification preference: $e');
      rethrow;
    }
  }

  /// Get reminder notification preference
  Future<bool> getReminderNotifications() async {
    try {
      final value = await _secureStorage.read(_reminderNotificationsKey);
      return value == 'true';
    } catch (e) {
      _logger.e('Error reading reminder notification preference: $e');
      return true; // Default to enabled
    }
  }

  /// Set reminder notification preference
  Future<void> setReminderNotifications(bool enabled) async {
    try {
      await _secureStorage.write(_reminderNotificationsKey, enabled.toString());
      _logger.d('Reminder notifications ${enabled ? 'enabled' : 'disabled'}');
    } catch (e) {
      _logger.e('Error saving reminder notification preference: $e');
      rethrow;
    }
  }

  /// Clear all notification preferences
  Future<void> clearAllPreferences() async {
    try {
      await _secureStorage.delete(_emailNotificationsKey);
      await _secureStorage.delete(_pushNotificationsKey);
      await _secureStorage.delete(_reminderNotificationsKey);
      _logger.d('All notification preferences cleared');
    } catch (e) {
      _logger.e('Error clearing notification preferences: $e');
      rethrow;
    }
  }
}

