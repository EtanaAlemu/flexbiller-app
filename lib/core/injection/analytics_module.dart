import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import '../services/crash_analytics_service.dart';
import '../services/crash_analytics_config.dart';

/// Dependency injection module for analytics services
@module
abstract class AnalyticsModule {
  @singleton
  CrashAnalyticsConfig crashAnalyticsConfig() {
    // You can inject BuildConfig here if needed
    return CrashAnalyticsConfig.fromBuildMode(
      true,
    ); // Will be replaced with actual build config
  }

  // CrashAnalyticsService is already registered with @LazySingleton in crash_analytics_service.dart

  @singleton
  CrashAnalyticsErrorHandler crashAnalyticsErrorHandler(
    CrashAnalyticsService crashAnalytics,
    Logger logger,
  ) => CrashAnalyticsErrorHandler(crashAnalytics, logger);
}
