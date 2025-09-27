import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:get_it/get_it.dart';
import '../services/crash_analytics_service.dart';

/// Centralized error handling utility for converting technical errors to user-friendly messages
class ErrorHandler {
  /// Converts technical error messages to user-friendly messages
  static String getUserFriendlyMessage(dynamic error, {String? context}) {
    // Report error to crash analytics
    _reportError(error, context: context);

    return _getUserFriendlyMessageInternal(error, context: context);
  }

  /// Internal method for getting user-friendly messages
  static String _getUserFriendlyMessageInternal(
    dynamic error, {
    String? context,
  }) {
    if (error is DioException) {
      return _handleDioException(error, context);
    }

    if (error is String) {
      return _handleStringError(error, context);
    }

    if (error is Exception) {
      return _handleException(error, context);
    }

    // Default fallback
    return _getDefaultMessage(context);
  }

  /// Static method for backward compatibility
  static String getUserFriendlyMessageStatic(dynamic error, {String? context}) {
    return _getUserFriendlyMessageInternal(error, context: context);
  }

  /// Converts DioException to user-friendly message with enhanced 502 handling
  static String convertDioExceptionToUserMessage(
    DioException error, {
    String? context,
  }) {
    // Report error to crash analytics
    _reportError(error, context: context);

    return _handleDioException(error, context);
  }

  /// Report error to crash analytics
  static void _reportError(dynamic error, {String? context}) {
    try {
      final crashAnalytics =
          GetIt.instance.isRegistered<CrashAnalyticsService>()
          ? GetIt.instance<CrashAnalyticsService>()
          : null;

      crashAnalytics?.recordError(
        error,
        StackTrace.current,
        reason: 'Error handled by ErrorHandler',
        customKeys: {
          'context': context ?? 'unknown',
          'error_type': error.runtimeType.toString(),
        },
        fatal: false,
      );
    } catch (e) {
      // Don't let crash analytics errors break the app
      debugPrint('Failed to report error to crash analytics: $e');
    }
  }

  /// Handles DioException errors
  static String _handleDioException(DioException error, String? context) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Request timed out. Please check your internet connection and try again.';

      case DioExceptionType.badResponse:
        return _handleHttpStatusError(error.response?.statusCode, context);

      case DioExceptionType.cancel:
        return 'Request was cancelled. Please try again.';

      case DioExceptionType.connectionError:
        return 'Unable to connect to the server. Please check your internet connection and try again.';

      case DioExceptionType.badCertificate:
        return 'Security certificate error. Please contact support if this persists.';

      case DioExceptionType.unknown:
        return _handleUnknownDioError(error, context);
    }
  }

  /// Handles HTTP status code errors
  static String _handleHttpStatusError(int? statusCode, String? context) {
    switch (statusCode) {
      case 400:
        return 'Invalid request. Please check your input and try again.';
      case 401:
        return 'You are not authorized. Please log in again.';
      case 403:
        return 'Access denied. You don\'t have permission to perform this action.';
      case 404:
        return _getNotFoundMessage(context);
      case 409:
        return 'Conflict detected. The resource may have been modified by another user.';
      case 422:
        return 'Invalid data provided. Please check your input and try again.';
      case 429:
        return 'Too many requests. Please wait a moment and try again.';
      case 500:
        return 'The server is temporarily unavailable. Please try again later.';
      case 502:
      case 503:
      case 504:
        return 'Service temporarily unavailable. Please try again later.';
      default:
        return 'An unexpected server error occurred. Please try again later.';
    }
  }

  /// Handles unknown Dio errors
  static String _handleUnknownDioError(DioException error, String? context) {
    final message = error.message?.toLowerCase() ?? '';

    if (message.contains('socketexception') ||
        message.contains('networkexception') ||
        message.contains('connection')) {
      return 'Network error. Please check your internet connection and try again.';
    }

    if (message.contains('timeout')) {
      return 'Request timed out. Please try again.';
    }

    if (message.contains('certificate') || message.contains('ssl')) {
      return 'Security certificate error. Please contact support if this persists.';
    }

    return _getDefaultMessage(context);
  }

  /// Handles string-based errors
  static String _handleStringError(String error, String? context) {
    final lowerError = error.toLowerCase();

    // Handle server response errors
    if (lowerError.contains('status code of 500')) {
      return 'The server is temporarily unavailable. Please try again later.';
    }

    if (lowerError.contains('status code of 502')) {
      return 'Service temporarily unavailable. Our servers are experiencing issues. Please try again in a few minutes.';
    }

    if (lowerError.contains('status code of 503')) {
      return 'Service temporarily unavailable. Please try again later.';
    }

    if (lowerError.contains('status code of 504')) {
      return 'Request timeout. The server is taking too long to respond. Please try again.';
    }

    if (lowerError.contains('status code of 404')) {
      return _getNotFoundMessage(context);
    }

    if (lowerError.contains('status code of 401')) {
      return 'You are not authorized. Please log in again.';
    }

    if (lowerError.contains('status code of 403')) {
      return 'Access denied. You don\'t have permission to perform this action.';
    }

    // Handle connection errors
    if (lowerError.contains('connection_error') ||
        lowerError.contains('failed to communicate with server')) {
      return 'Unable to connect to the server. Please check your internet connection and try again.';
    }

    if (lowerError.contains('socketexception') ||
        lowerError.contains('networkexception')) {
      return 'Network error. Please check your internet connection and try again.';
    }

    // Handle timeout errors
    if (lowerError.contains('timeoutexception') ||
        lowerError.contains('timeout')) {
      return 'Request timed out. Please try again.';
    }

    // Handle specific business logic errors
    if (lowerError.contains('could not find a plan matching spec')) {
      return 'There was an issue with the subscription data. Please contact support if this persists.';
    }

    if (lowerError.contains('invalid credentials') ||
        lowerError.contains('authentication failed')) {
      return 'Invalid login credentials. Please check your email and password.';
    }

    if (lowerError.contains('account not found')) {
      return 'Account not found. Please check the account details and try again.';
    }

    if (lowerError.contains('subscription not found')) {
      return 'Subscription not found. Please refresh and try again.';
    }

    if (lowerError.contains('invoice not found')) {
      return 'Invoice not found. Please refresh and try again.';
    }

    if (lowerError.contains('payment failed')) {
      return 'Payment processing failed. Please check your payment method and try again.';
    }

    if (lowerError.contains('validation error') ||
        lowerError.contains('invalid input')) {
      return 'Invalid data provided. Please check your input and try again.';
    }

    // Handle generic errors
    if (lowerError.contains('exception:') || lowerError.contains('error:')) {
      return 'An unexpected error occurred. Please try again or contact support if the problem continues.';
    }

    return _getDefaultMessage(context);
  }

  /// Handles general exceptions
  static String _handleException(Exception error, String? context) {
    final message = error.toString().toLowerCase();

    if (message.contains('timeout')) {
      return 'Request timed out. Please try again.';
    }

    if (message.contains('network') || message.contains('connection')) {
      return 'Network error. Please check your internet connection and try again.';
    }

    if (message.contains('format') || message.contains('parse')) {
      return 'Data format error. Please refresh and try again.';
    }

    return _getDefaultMessage(context);
  }

  /// Gets context-specific not found messages
  static String _getNotFoundMessage(String? context) {
    switch (context?.toLowerCase()) {
      case 'subscriptions':
        return 'No subscriptions found for this account.';
      case 'invoices':
        return 'No invoices found for this account.';
      case 'payments':
        return 'No payments found for this account.';
      case 'accounts':
        return 'No accounts found.';
      case 'user':
        return 'User not found.';
      default:
        return 'The requested resource was not found.';
    }
  }

  /// Gets default error message based on context
  static String _getDefaultMessage(String? context) {
    switch (context?.toLowerCase()) {
      case 'subscriptions':
        return 'Failed to load subscriptions. Please try again.';
      case 'invoices':
        return 'Failed to load invoices. Please try again.';
      case 'payments':
        return 'Failed to load payments. Please try again.';
      case 'accounts':
        return 'Failed to load accounts. Please try again.';
      case 'auth':
      case 'login':
        return 'Authentication failed. Please try again.';
      case 'create':
      case 'save':
        return 'Failed to save data. Please try again.';
      case 'update':
        return 'Failed to update data. Please try again.';
      case 'delete':
        return 'Failed to delete data. Please try again.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }

  /// Gets a retry action message based on context
  static String getRetryMessage(String? context) {
    switch (context?.toLowerCase()) {
      case 'subscriptions':
        return 'Retry loading subscriptions';
      case 'invoices':
        return 'Retry loading invoices';
      case 'payments':
        return 'Retry loading payments';
      case 'accounts':
        return 'Retry loading accounts';
      case 'auth':
      case 'login':
        return 'Try again';
      case 'create':
      case 'save':
        return 'Try saving again';
      case 'update':
        return 'Try updating again';
      case 'delete':
        return 'Try deleting again';
      default:
        return 'Try again';
    }
  }

  /// Checks if an error is retryable
  static bool isRetryable(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.connectionError:
        case DioExceptionType.unknown:
          return true;
        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          return statusCode != null && statusCode >= 500;
        case DioExceptionType.cancel:
        case DioExceptionType.badCertificate:
          return false;
      }
    }

    if (error is String) {
      final lowerError = error.toLowerCase();
      return lowerError.contains('timeout') ||
          lowerError.contains('connection') ||
          lowerError.contains('network') ||
          lowerError.contains('status code of 5');
    }

    return true; // Default to retryable for unknown errors
  }
}
