import 'package:injectable/injectable.dart';
import 'crash_analytics_service.dart';

/// Mock implementation of crash analytics service for testing
@LazySingleton(as: CrashAnalyticsService, env: ['test'])
class MockCrashAnalyticsService implements CrashAnalyticsService {
  final List<dynamic> recordedErrors = [];
  final List<String> recordedLogs = [];
  final List<String> breadcrumbs = [];
  final Map<String, dynamic> customKeys = {};
  final Map<String, String> userProperties = {};
  String? userId;
  bool enabled = true;

  @override
  Future<void> initialize() async {
    // Mock initialization
  }

  @override
  Future<void> recordError(
    dynamic error,
    StackTrace? stackTrace, {
    String? reason,
    Map<String, dynamic>? customKeys,
    bool fatal = false,
  }) async {
    recordedErrors.add({
      'error': error,
      'stackTrace': stackTrace,
      'reason': reason,
      'customKeys': customKeys,
      'fatal': fatal,
    });
  }

  @override
  Future<void> recordEvent(
    String eventName, {
    Map<String, dynamic>? parameters,
  }) async {
    recordedLogs.add(
      'Event: $eventName${parameters != null ? ' with params: $parameters' : ''}',
    );
  }

  @override
  Future<void> setUserId(String userId) async {
    this.userId = userId;
  }

  @override
  Future<void> setUserProperty(String key, String value) async {
    userProperties[key] = value;
  }

  @override
  Future<void> setCustomKey(String key, dynamic value) async {
    customKeys[key] = value;
  }

  @override
  Future<dynamic> getCustomKey(String key) async {
    return customKeys[key];
  }

  @override
  Future<void> log(String message) async {
    recordedLogs.add('Log: $message');
  }

  @override
  Future<void> addBreadcrumb(String message) async {
    breadcrumbs.add('${DateTime.now().toIso8601String()}: $message');
  }

  @override
  List<String> getBreadcrumbs() {
    return List.unmodifiable(breadcrumbs);
  }

  @override
  Future<void> clearBreadcrumbs() async {
    breadcrumbs.clear();
  }

  @override
  Future<void> startTrace(String traceName) async {
    recordedLogs.add('Trace started: $traceName');
  }

  @override
  Future<void> stopTrace(String traceName) async {
    recordedLogs.add('Trace stopped: $traceName');
  }

  @override
  bool get isEnabled => enabled;

  @override
  void setEnabled(bool enabled) {
    this.enabled = enabled;
  }

  /// Test helper methods
  void reset() {
    recordedErrors.clear();
    recordedLogs.clear();
    breadcrumbs.clear();
    customKeys.clear();
    userProperties.clear();
    userId = null;
    enabled = true;
  }

  bool hasRecordedError(dynamic error) {
    return recordedErrors.any((record) => record['error'] == error);
  }

  bool hasRecordedLog(String message) {
    return recordedLogs.any((log) => log.contains(message));
  }

  bool hasBreadcrumb(String message) {
    return breadcrumbs.any((breadcrumb) => breadcrumb.contains(message));
  }

  int get errorCount => recordedErrors.length;
  int get logCount => recordedLogs.length;
  int get breadcrumbCount => breadcrumbs.length;
}
