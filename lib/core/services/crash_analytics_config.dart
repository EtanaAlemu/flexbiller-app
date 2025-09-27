/// Configuration for crash analytics system
class CrashAnalyticsConfig {
  final bool enableInDebug;
  final bool enableCrashReports;
  final bool enableAnalytics;
  final int maxBreadcrumbs;
  final Map<String, dynamic> defaultCustomKeys;
  final bool enablePerformanceMonitoring;
  final bool enableBreadcrumbTracking;

  const CrashAnalyticsConfig({
    this.enableInDebug = false,
    this.enableCrashReports = true,
    this.enableAnalytics = true,
    this.maxBreadcrumbs = 100,
    this.defaultCustomKeys = const {},
    this.enablePerformanceMonitoring = true,
    this.enableBreadcrumbTracking = true,
  });

  /// Default production configuration
  static const CrashAnalyticsConfig production = CrashAnalyticsConfig(
    enableInDebug: false,
    enableCrashReports: true,
    enableAnalytics: true,
    maxBreadcrumbs: 100,
    enablePerformanceMonitoring: true,
    enableBreadcrumbTracking: true,
  );

  /// Default debug configuration
  static const CrashAnalyticsConfig debug = CrashAnalyticsConfig(
    enableInDebug: true,
    enableCrashReports: true,
    enableAnalytics: false,
    maxBreadcrumbs: 50,
    enablePerformanceMonitoring: false,
    enableBreadcrumbTracking: true,
  );

  /// Create config based on build mode
  factory CrashAnalyticsConfig.fromBuildMode(bool isDebug) {
    return isDebug ? debug : production;
  }
}

