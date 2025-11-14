import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:logger/logger.dart';
import 'package:injectable/injectable.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';
import '../errors/app_error.dart';
import '../config/build_config.dart';
import 'crash_analytics_config.dart';

/// Abstract interface for crash analytics operations
abstract class CrashAnalyticsService {
  /// Initialize crash analytics
  Future<void> initialize();

  /// Record a non-fatal error
  Future<void> recordError(
    dynamic error,
    StackTrace? stackTrace, {
    String? reason,
    Map<String, dynamic>? customKeys,
    bool fatal = false,
  });

  /// Record a custom event
  Future<void> recordEvent(
    String eventName, {
    Map<String, dynamic>? parameters,
  });

  /// Set user identifier for crash reports
  Future<void> setUserId(String userId);

  /// Set custom user properties
  Future<void> setUserProperty(String key, String value);

  /// Set custom keys for crash reports
  Future<void> setCustomKey(String key, dynamic value);

  /// Get custom key value (for internal use)
  Future<dynamic> getCustomKey(String key);

  /// Log a message for debugging
  Future<void> log(String message);

  /// Add breadcrumb for better error context
  Future<void> addBreadcrumb(String message);

  /// Get current breadcrumbs
  List<String> getBreadcrumbs();

  /// Clear breadcrumbs
  Future<void> clearBreadcrumbs();

  /// Start performance trace
  Future<void> startTrace(String traceName);

  /// Stop performance trace
  Future<void> stopTrace(String traceName);

  /// Check if crash analytics is enabled
  bool get isEnabled;

  /// Enable or disable crash analytics
  void setEnabled(bool enabled);
}

/// Implementation of crash analytics service using Firebase Crashlytics
@LazySingleton(as: CrashAnalyticsService)
class CrashAnalyticsServiceImpl implements CrashAnalyticsService {
  final FirebaseCrashlytics _crashlytics;
  final Logger _logger;
  final CrashAnalyticsConfig _config;
  bool _isEnabled = true;
  final List<String> _breadcrumbs = [];
  final Map<String, DateTime> _activeTraces = {};

  CrashAnalyticsServiceImpl(this._crashlytics, this._logger, this._config);

  @override
  Future<void> initialize() async {
    try {
      // Only enable Firebase Crashlytics collection in production/release builds
      final shouldEnable =
          _config.enableCrashReports && BuildConfig.isProduction;

      await _crashlytics.setCrashlyticsCollectionEnabled(shouldEnable);

      if (shouldEnable) {
        _logger.i(
          '✅ Crash analytics initialized - Firebase Crashlytics enabled (PRODUCTION)',
        );
      } else {
        _logger.i(
          'ℹ️ Crash analytics initialized - Firebase Crashlytics disabled (DEBUG/DEVELOPMENT)',
        );
        _logger.d('📝 Errors will be logged locally but not sent to Firebase');
      }

      // Note: Error handling is now managed by CrashAnalyticsErrorBoundary
      // to avoid setState() during build issues
    } catch (e) {
      _logger.e('Failed to initialize crash analytics: $e');
    }
  }

  @override
  Future<void> recordError(
    dynamic error,
    StackTrace? stackTrace, {
    String? reason,
    Map<String, dynamic>? customKeys,
    bool fatal = false,
  }) async {
    if (!_isEnabled) {
      _logger.w('Crash analytics is disabled, not recording error: $error');
      return;
    }

    // Always log errors locally for debugging
    final effectiveStackTrace = stackTrace ?? StackTrace.current;
    final detailedError = error is Exception
        ? error
        : Exception(error.toString());

    _logger.e('❌ Error occurred: $detailedError');
    _logger.e('📚 Reason: $reason');
    _logger.e('🔴 Fatal: $fatal');
    _logger.e('📊 Custom keys: $customKeys');
    _logger.e('📚 Stack trace: $effectiveStackTrace');

    // Only send to Firebase Crashlytics in production/release builds
    if (!BuildConfig.isProduction) {
      _logger.d(
        '🚫 Not sending to Firebase Crashlytics (DEBUG/DEVELOPMENT build)',
      );
      _logger.d('📝 Error logged locally only');
      return;
    }

    try {
      _logger.d(
        '🎯 Recording ${fatal ? 'FATAL' : 'NON-FATAL'} error to Firebase Crashlytics (PRODUCTION)',
      );

      // Set custom keys first
      final allCustomKeys = {
        'fatal': fatal,
        'reason': reason,
        'timestamp': DateTime.now().toIso8601String(),
        'platform': Platform.operatingSystem,
        ...?customKeys,
      };

      for (final entry in allCustomKeys.entries) {
        if (entry.value != null) {
          await _crashlytics.setCustomKey(entry.key, entry.value.toString());
          _logger.d('🔑 Set custom key: ${entry.key} = ${entry.value}');
        }
      }

      // Record the error
      if (fatal) {
        // For fatal errors, use a method that ensures they appear as crashes
        await _crashlytics.recordError(
          detailedError,
          effectiveStackTrace,
          fatal: true,
        );
      } else {
        // For non-fatals, also record but they might appear differently
        await _crashlytics.recordError(
          detailedError,
          effectiveStackTrace,
          fatal: false,
        );
      }

      _logger.i(
        '✅ Error recorded to Firebase Crashlytics successfully (fatal: $fatal)',
      );

      // Force send any pending reports for immediate visibility
      await _crashlytics.sendUnsentReports();
      _logger.d('📤 Pending reports sent to Firebase');
    } catch (e) {
      _logger.e('❌ Failed to record error to Firebase: $e');
      _logger.e('❌ Error details: ${e.toString()}');
    }
  }

  @override
  Future<void> recordEvent(
    String eventName, {
    Map<String, dynamic>? parameters,
  }) async {
    if (!_isEnabled) return;

    try {
      // Firebase Crashlytics doesn't have event recording like Analytics
      // We'll log it for debugging purposes
      _logger.d(
        'Event: $eventName${parameters != null ? ' with params: $parameters' : ''}',
      );

      // You could integrate with Firebase Analytics here if needed
      // await FirebaseAnalytics.instance.logEvent(name: eventName, parameters: parameters);
    } catch (e) {
      _logger.e('Failed to record event: $e');
    }
  }

  @override
  Future<void> setUserId(String userId) async {
    if (!_isEnabled) return;

    try {
      await _crashlytics.setUserIdentifier(userId);
      _logger.d('User ID set: $userId');
    } catch (e) {
      _logger.e('Failed to set user ID: $e');
    }
  }

  @override
  Future<void> setUserProperty(String key, String value) async {
    if (!_isEnabled) return;

    try {
      await _crashlytics.setCustomKey(key, value);
      _logger.d('User property set: $key = $value');
    } catch (e) {
      _logger.e('Failed to set user property: $e');
    }
  }

  @override
  Future<void> setCustomKey(String key, dynamic value) async {
    if (!_isEnabled) return;

    // Always log locally
    _logger.d('Custom key set: $key = $value');

    // Only send to Firebase in production
    if (!BuildConfig.isProduction) {
      return;
    }

    try {
      await _crashlytics.setCustomKey(key, value);
    } catch (e) {
      _logger.e('Failed to set custom key in Firebase: $e');
    }
  }

  @override
  Future<dynamic> getCustomKey(String key) async {
    // Firebase Crashlytics doesn't provide a way to retrieve custom keys
    // This is a limitation - we'll return null and log a warning
    _logger.w('getCustomKey not supported by Firebase Crashlytics: $key');
    return null;
  }

  @override
  Future<void> log(String message) async {
    if (!_isEnabled) return;

    // Always log locally
    _logger.d('Crash log: $message');

    // Only send to Firebase in production
    if (!BuildConfig.isProduction) {
      return;
    }

    try {
      await _crashlytics.log(message);
    } catch (e) {
      _logger.e('Failed to log message to Firebase: $e');
    }
  }

  @override
  bool get isEnabled => _isEnabled;

  @override
  void setEnabled(bool enabled) {
    _isEnabled = enabled;
    _logger.d('Crash analytics ${enabled ? 'enabled' : 'disabled'}');
  }

  @override
  Future<void> addBreadcrumb(String message) async {
    if (!_isEnabled || !_config.enableBreadcrumbTracking) return;

    try {
      final timestamp = DateTime.now().toIso8601String();
      final breadcrumb = '$timestamp: $message';

      _breadcrumbs.add(breadcrumb);

      // Keep only recent breadcrumbs
      if (_breadcrumbs.length > _config.maxBreadcrumbs) {
        _breadcrumbs.removeRange(
          0,
          _breadcrumbs.length - _config.maxBreadcrumbs,
        );
      }

      // Always log locally
      _logger.d('Breadcrumb added: $message');

      // Only send to Firebase in production
      if (BuildConfig.isProduction) {
        await _crashlytics.log('Breadcrumb: $message');
      }
    } catch (e) {
      _logger.e('Failed to add breadcrumb: $e');
    }
  }

  @override
  List<String> getBreadcrumbs() {
    return List.unmodifiable(_breadcrumbs);
  }

  @override
  Future<void> clearBreadcrumbs() async {
    _breadcrumbs.clear();
    _logger.d('Breadcrumbs cleared');
  }

  @override
  Future<void> startTrace(String traceName) async {
    if (!_isEnabled || !_config.enablePerformanceMonitoring) return;

    try {
      _activeTraces[traceName] = DateTime.now();
      await _crashlytics.log('Trace started: $traceName');
      _logger.d('Performance trace started: $traceName');
    } catch (e) {
      _logger.e('Failed to start trace: $e');
    }
  }

  @override
  Future<void> stopTrace(String traceName) async {
    if (!_isEnabled || !_config.enablePerformanceMonitoring) return;

    try {
      final startTime = _activeTraces.remove(traceName);
      if (startTime != null) {
        final duration = DateTime.now().difference(startTime);
        await _crashlytics.log(
          'Trace stopped: $traceName (${duration.inMilliseconds}ms)',
        );
        _logger.d(
          'Performance trace stopped: $traceName (${duration.inMilliseconds}ms)',
        );
      }
    } catch (e) {
      _logger.e('Failed to stop trace: $e');
    }
  }
}

/// Enhanced error handler that integrates with crash analytics
class CrashAnalyticsErrorHandler {
  final CrashAnalyticsService _crashAnalytics;
  final Logger _logger;

  CrashAnalyticsErrorHandler(this._crashAnalytics, this._logger);

  /// Handle and report application errors
  Future<void> handleError(
    dynamic error,
    StackTrace? stackTrace, {
    String? context,
    String? feature,
    Map<String, dynamic>? additionalData,
    bool fatal = false,
  }) async {
    try {
      // Create custom keys for better crash reporting
      final customKeys = <String, dynamic>{
        'timestamp': DateTime.now().toIso8601String(),
        'platform': Platform.operatingSystem,
        'version': Platform.operatingSystemVersion,
      };

      if (context != null) customKeys['context'] = context;
      if (feature != null) customKeys['feature'] = feature;
      if (additionalData != null) customKeys.addAll(additionalData);

      // Determine error category and severity
      final errorInfo = _categorizeError(error);
      customKeys['error_category'] = errorInfo['category'];
      customKeys['error_severity'] = errorInfo['severity'];

      // Record the error
      await _crashAnalytics.recordError(
        error,
        stackTrace,
        reason: errorInfo['reason'],
        customKeys: customKeys,
        fatal: fatal,
      );

      // Log additional context
      await _crashAnalytics.log(
        'Error in ${feature ?? 'unknown feature'}: ${error.toString()}',
      );

      _logger.e('Error handled and reported: ${error.toString()}');
    } catch (e) {
      _logger.e('Failed to handle error reporting: $e');
    }
  }

  /// Handle AppError instances specifically
  Future<void> handleAppError(
    AppError error, {
    String? context,
    String? feature,
    Map<String, dynamic>? additionalData,
    bool fatal = false,
  }) async {
    final customKeys = <String, dynamic>{
      'error_type': error.runtimeType.toString(),
      'error_message': error.message,
      'error_context': error.context ?? 'unknown',
    };

    if (error.originalError != null) {
      customKeys['original_error'] = error.originalError.toString();
    }

    if (additionalData != null) {
      customKeys.addAll(additionalData);
    }

    await handleError(
      error,
      StackTrace.current,
      context: context,
      feature: feature,
      additionalData: customKeys,
      fatal: fatal,
    );
  }

  /// Categorize errors for better reporting
  Map<String, String> _categorizeError(dynamic error) {
    if (error is NetworkError) {
      return {
        'category': 'network',
        'severity': 'medium',
        'reason': 'Network connectivity issue',
      };
    } else if (error is ServerError) {
      return {
        'category': 'server',
        'severity': error.statusCode != null && error.statusCode! >= 500
            ? 'high'
            : 'medium',
        'reason': 'Server error (${error.statusCode})',
      };
    } else if (error is AuthenticationError) {
      return {
        'category': 'authentication',
        'severity': 'high',
        'reason': 'Authentication failed',
      };
    } else if (error is AuthorizationError) {
      return {
        'category': 'authorization',
        'severity': 'high',
        'reason': 'Access denied',
      };
    } else if (error is ValidationError) {
      return {
        'category': 'validation',
        'severity': 'low',
        'reason': 'Input validation failed',
      };
    } else if (error is TimeoutError) {
      return {
        'category': 'timeout',
        'severity': 'medium',
        'reason': 'Operation timed out',
      };
    } else if (error is CacheError) {
      return {
        'category': 'cache',
        'severity': 'low',
        'reason': 'Local storage issue',
      };
    } else if (error is PlatformException) {
      return {
        'category': 'platform',
        'severity': 'medium',
        'reason': 'Native platform error: ${error.code}',
      };
    } else if (error is DatabaseException) {
      return {
        'category': 'database',
        'severity': 'high',
        'reason': 'Database operation failed',
      };
    } else if (error is FormatException) {
      return {
        'category': 'format',
        'severity': 'medium',
        'reason': 'Data format error',
      };
    } else if (error is StateError) {
      return {
        'category': 'state',
        'severity': 'medium',
        'reason': 'Invalid state error',
      };
    } else {
      return {
        'category': 'unknown',
        'severity': 'high',
        'reason': 'Unexpected error occurred',
      };
    }
  }
}
