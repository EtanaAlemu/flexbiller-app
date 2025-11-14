import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import '../config/build_config.dart';

/// Service responsible for initializing Firebase and crash analytics
@LazySingleton()
class CrashAnalyticsInitializer {
  final Logger _logger;

  CrashAnalyticsInitializer(this._logger);

  /// Initialize Firebase and crash analytics
  Future<void> initialize() async {
    try {
      _logger.i('Initializing Firebase...');

      // Initialize Firebase
      await Firebase.initializeApp();
      _logger.i('Firebase initialized successfully');

      // Only enable Crashlytics collection in production/release builds
      final shouldEnable = BuildConfig.isProduction;
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(
        shouldEnable,
      );

      if (shouldEnable) {
        _logger.i('✅ Crashlytics collection enabled (PRODUCTION)');
      } else {
        _logger.i('ℹ️ Crashlytics collection disabled (DEBUG/DEVELOPMENT)');
        _logger.d('📝 Errors will be logged locally but not sent to Firebase');
      }

      _logger.i('Crash analytics initialization completed');
    } catch (e) {
      _logger.e('Failed to initialize crash analytics: $e');
      // Don't rethrow - we want the app to continue even if crash analytics fails
    }
  }

  /// Check if Firebase is initialized
  bool get isInitialized => Firebase.apps.isNotEmpty;
}
