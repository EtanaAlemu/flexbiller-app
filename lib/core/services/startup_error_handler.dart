import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// Handles startup errors and provides emergency error handling
class StartupErrorHandler {
  static final Logger _logger = Logger();

  /// Setup global error handlers that work even before DI is ready
  static void setupGlobalErrorHandlers() {
    // Set up basic error handling even before DI is ready
    FlutterError.onError = (FlutterErrorDetails details) {
      _logger.e('Flutter error during initialization: ${details.exception}');
      _logger.e('Stack trace: ${details.stack}');
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      _logger.e('Platform error during initialization: $error');
      _logger.e('Stack trace: $stack');
      return true;
    };
  }

  /// Handle startup errors with emergency fallback
  static Future<void> handleStartupError(
    dynamic error,
    StackTrace stackTrace,
  ) async {
    _logger.e('Critical startup error: $error');
    _logger.e('Stack trace: $stackTrace');

    // Try to report to crash analytics if possible
    try {
      // This will only work if DI is already configured
      // final crashAnalytics = GetIt.instance.isRegistered<CrashAnalyticsService>()
      //     ? GetIt.instance<CrashAnalyticsService>()
      //     : null;
      // await crashAnalytics?.recordError(error, stackTrace, fatal: true);
    } catch (e) {
      _logger.e('Failed to report startup error: $e');
    }
  }

  /// Create emergency error app for critical failures
  static Widget createStartupErrorApp(dynamic error) {
    return MaterialApp(
      title: 'FlexBiller - Error',
      home: Scaffold(
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  'App Failed to Start',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'The application encountered a critical error during startup.',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    border: Border.all(color: Colors.red.shade200),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Error: ${error.toString()}',
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    // Try to restart the app
                    // This is a simplified restart - in production you might want
                    // to use a more sophisticated restart mechanism
                    exit(1);
                  },
                  child: const Text('Restart App'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
