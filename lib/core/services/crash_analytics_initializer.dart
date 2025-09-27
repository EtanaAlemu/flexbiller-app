import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';

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

      // Initialize Crashlytics
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
      _logger.i('Crashlytics collection enabled');

      _logger.i('Crash analytics initialization completed');
    } catch (e) {
      _logger.e('Failed to initialize crash analytics: $e');
      // Don't rethrow - we want the app to continue even if crash analytics fails
    }
  }

  /// Check if Firebase is initialized
  bool get isInitialized => Firebase.apps.isNotEmpty;
}
