import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../services/crash_analytics_service.dart';

/// Mixin for easy breadcrumb tracking in widgets
mixin BreadcrumbTracker on State {
  CrashAnalyticsService? get _crashAnalytics =>
      GetIt.instance.isRegistered<CrashAnalyticsService>()
      ? GetIt.instance<CrashAnalyticsService>()
      : null;

  /// Add a breadcrumb for better error context
  Future<void> addBreadcrumb(String message) async {
    await _crashAnalytics?.addBreadcrumb('${widget.runtimeType}: $message');
  }

  /// Add breadcrumb with custom context
  Future<void> addBreadcrumbWithContext(String message, String context) async {
    await _crashAnalytics?.addBreadcrumb(
      '${widget.runtimeType} ($context): $message',
    );
  }

  /// Add breadcrumb for user actions
  Future<void> addUserActionBreadcrumb(
    String action, {
    Map<String, dynamic>? data,
  }) async {
    final dataStr = data != null ? ' with data: $data' : '';
    await _crashAnalytics?.addBreadcrumb('User action: $action$dataStr');
  }

  /// Add breadcrumb for navigation events
  Future<void> addNavigationBreadcrumb(String from, String to) async {
    await _crashAnalytics?.addBreadcrumb('Navigation: $from -> $to');
  }

  /// Add breadcrumb for API calls
  Future<void> addApiBreadcrumb(
    String method,
    String endpoint, {
    int? statusCode,
  }) async {
    final status = statusCode != null ? ' (${statusCode})' : '';
    await _crashAnalytics?.addBreadcrumb('API $method $endpoint$status');
  }

  /// Add breadcrumb for state changes
  Future<void> addStateBreadcrumb(String fromState, String toState) async {
    await _crashAnalytics?.addBreadcrumb(
      'State change: $fromState -> $toState',
    );
  }

  /// Report error with breadcrumbs
  Future<void> reportErrorWithBreadcrumbs(
    dynamic error, {
    StackTrace? stackTrace,
    String? reason,
    Map<String, dynamic>? customKeys,
    bool fatal = false,
  }) async {
    final breadcrumbs = _crashAnalytics?.getBreadcrumbs() ?? [];
    final enhancedCustomKeys = {
      'breadcrumbs': breadcrumbs.join(' | '),
      'breadcrumb_count': breadcrumbs.length,
      ...?customKeys,
    };

    await _crashAnalytics?.recordError(
      error,
      stackTrace ?? StackTrace.current,
      reason: reason,
      customKeys: enhancedCustomKeys,
      fatal: fatal,
    );

    // Clear breadcrumbs after error report
    await _crashAnalytics?.clearBreadcrumbs();
  }

  /// Get current breadcrumbs
  List<String> getBreadcrumbs() {
    return _crashAnalytics?.getBreadcrumbs() ?? [];
  }

  /// Clear breadcrumbs
  Future<void> clearBreadcrumbs() async {
    await _crashAnalytics?.clearBreadcrumbs();
  }
}
