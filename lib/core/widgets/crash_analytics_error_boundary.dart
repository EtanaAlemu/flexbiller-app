import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import '../services/crash_analytics_service.dart';
import '../errors/app_error.dart';
import '../config/build_config.dart';
import 'package:logger/logger.dart';

/// Error boundary widget that catches and reports errors to crash analytics
class CrashAnalyticsErrorBoundary extends StatefulWidget {
  final Widget child;
  final String? feature;
  final Widget? fallback;

  const CrashAnalyticsErrorBoundary({
    Key? key,
    required this.child,
    this.feature,
    this.fallback,
  }) : super(key: key);

  @override
  State<CrashAnalyticsErrorBoundary> createState() =>
      _CrashAnalyticsErrorBoundaryState();
}

class _CrashAnalyticsErrorBoundaryState
    extends State<CrashAnalyticsErrorBoundary> {
  bool _hasError = false;
  String? _errorMessage;
  final Logger _logger = Logger();

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return widget.fallback ?? _buildErrorWidget();
    }

    return widget.child;
  }

  Widget _buildErrorWidget() {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Material(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Something went wrong',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage ?? 'An unexpected error occurred',
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _resetError,
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _resetError() {
    if (mounted) {
      setState(() {
        _hasError = false;
        _errorMessage = null;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _setupErrorHandling();
  }

  void _setupErrorHandling() {
    // Store original error handlers to preserve existing functionality
    final originalFlutterError = FlutterError.onError;
    final originalPlatformError = PlatformDispatcher.instance.onError;

    FlutterError.onError = (FlutterErrorDetails details) {
      // Call original handler first
      originalFlutterError?.call(details);

      // Schedule state update for next frame
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleError(details.exception, details.stack);
      });
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      // Call original handler first and get its result
      final originalResult = originalPlatformError?.call(error, stack) ?? true;

      // Schedule state update for next frame
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleError(error, stack);
      });

      return originalResult;
    };
  }

  void _handleError(dynamic error, StackTrace? stackTrace) {
    if (!mounted) return;

    // Prevent multiple error states
    if (_hasError) return;

    // Debug logging
    _logger.e('🚨 CrashAnalyticsErrorBoundary caught error: $error');
    _logger.e('🚨 Stack trace: $stackTrace');

    // Check if this is a Provider context error (not a real crash)
    final errorString = error.toString().toLowerCase();
    if (errorString.contains('provider') &&
        errorString.contains('could not find') &&
        errorString.contains('above this')) {
      _logger.w('⚠️ Provider context error detected - not treating as crash');
      // Don't show error boundary for Provider context issues
      // Just report to analytics for debugging
      _reportError(error, stackTrace);
      return;
    }

    setState(() {
      _hasError = true;
      _errorMessage = error.toString().split('\n').first; // First line only
    });

    _reportError(error, stackTrace);
  }

  void _reportError(dynamic error, StackTrace? stackTrace) async {
    try {
      final crashAnalytics =
          GetIt.instance.isRegistered<CrashAnalyticsService>()
          ? GetIt.instance<CrashAnalyticsService>()
          : null;

      _logger.d(
        '🔍 CrashAnalytics service available: ${crashAnalytics != null}',
      );
      _logger.d(
        '🔍 CrashAnalytics enabled: ${crashAnalytics?.isEnabled ?? false}',
      );

      if (crashAnalytics != null) {
        // Always log the error locally
        _logger.e('❌ Error caught by CrashAnalyticsErrorBoundary');
        _logger.e('📚 Error: $error');
        _logger.e('📚 Stack trace: $stackTrace');
        _logger.e('📊 Feature: ${widget.feature ?? 'unknown'}');
        _logger.e('📊 Widget: ${widget.runtimeType}');

        // Add small delay to ensure proper initialization
        await Future.delayed(Duration(milliseconds: 100));

        // Log message (will only send to Firebase in production)
        await crashAnalytics.log('Starting error report...');

        // Record error (will only send to Firebase in production)
        _logger.d(
          BuildConfig.isProduction
              ? '📤 Reporting error to Firebase Crashlytics (PRODUCTION)...'
              : '📝 Logging error locally only (DEBUG/DEVELOPMENT)',
        );

        await crashAnalytics.recordError(
          error,
          stackTrace,
          reason: 'Error caught by CrashAnalyticsErrorBoundary',
          customKeys: {
            'feature': widget.feature ?? 'unknown',
            'widget': widget.runtimeType.toString(),
            'error_boundary': true,
            'timestamp': DateTime.now().toIso8601String(),
          },
          fatal: true,
        );

        // Only send to Firebase in production
        if (BuildConfig.isProduction) {
          // Force send any pending reports
          await FirebaseCrashlytics.instance.sendUnsentReports();
          _logger.d('✅ Error reported to Firebase Crashlytics successfully');
        } else {
          _logger.d(
            '✅ Error logged locally (not sent to Firebase in debug mode)',
          );
        }
      } else {
        _logger.d('❌ CrashAnalytics service not available');
      }
    } catch (e) {
      // Don't let crash analytics errors break the app
      _logger.e('Failed to report error to crash analytics: $e');
    }
  }
}

/// Mixin for widgets that want to easily report errors
mixin CrashAnalyticsMixin<T extends StatefulWidget> on State<T> {
  CrashAnalyticsService? get _crashAnalytics =>
      GetIt.instance.isRegistered<CrashAnalyticsService>()
      ? GetIt.instance<CrashAnalyticsService>()
      : null;

  /// Report an error to crash analytics
  Future<void> reportError(
    dynamic error, {
    StackTrace? stackTrace,
    String? reason,
    Map<String, dynamic>? customKeys,
    bool fatal = false,
  }) async {
    if (_crashAnalytics != null) {
      await _crashAnalytics!.recordError(
        error,
        stackTrace ?? StackTrace.current,
        reason: reason,
        customKeys: {
          'widget': widget.runtimeType.toString(),
          'feature': _getFeatureName(),
          ...?customKeys,
        },
        fatal: fatal,
      );
    }
  }

  /// Report an AppError to crash analytics
  Future<void> reportAppError(
    AppError error, {
    String? reason,
    Map<String, dynamic>? customKeys,
    bool fatal = false,
  }) async {
    await reportError(
      error,
      reason: reason ?? 'AppError: ${error.runtimeType}',
      customKeys: {
        'error_type': error.runtimeType.toString(),
        'error_message': error.message,
        'error_context': error.context ?? 'unknown',
        ...?customKeys,
      },
      fatal: fatal,
    );
  }

  /// Log a message to crash analytics
  Future<void> logMessage(String message) async {
    if (_crashAnalytics != null) {
      await _crashAnalytics!.log('${_getFeatureName()}: $message');
    }
  }

  /// Get the feature name for this widget
  String _getFeatureName() {
    final className = widget.runtimeType.toString();
    if (className.contains('Auth')) return 'auth';
    if (className.contains('Account')) return 'accounts';
    if (className.contains('Subscription')) return 'subscriptions';
    if (className.contains('Dashboard')) return 'dashboard';
    if (className.contains('Tag')) return 'tags';
    return 'unknown';
  }
}

/// Extension for easy error reporting on any widget
extension CrashAnalyticsExtension on Widget {
  /// Wrap widget with crash analytics error boundary
  Widget withCrashAnalytics({String? feature, Widget? fallback}) {
    return CrashAnalyticsErrorBoundary(
      feature: feature,
      fallback: fallback,
      child: this,
    );
  }
}
