import 'package:logger/logger.dart';
import 'app_error.dart';
import 'failures.dart';
import 'exceptions.dart';

/// Centralized error handling service
class ErrorHandler {
  static final Logger _logger = Logger();

  /// Convert exceptions to user-friendly error messages
  static AppError handleException(
    dynamic exception, {
    String? context,
    Map<String, dynamic>? metadata,
  }) {
    _logger.e('Handling exception: $exception', error: exception);

    if (exception is ServerException) {
      return _handleServerException(exception, context, metadata);
    } else if (exception is NetworkException) {
      return _handleNetworkException(exception, context, metadata);
    } else if (exception is CacheException) {
      return _handleCacheException(exception, context, metadata);
    } else if (exception is AuthException) {
      return _handleAuthException(exception, context, metadata);
    } else if (exception is ValidationException) {
      return _handleValidationException(exception, context, metadata);
    } else {
      return _handleUnknownException(exception, context, metadata);
    }
  }

  /// Convert failures to user-friendly error messages
  static AppError handleFailure(
    Failure failure, {
    String? context,
    Map<String, dynamic>? metadata,
  }) {
    _logger.e('Handling failure: $failure');

    if (failure is ServerFailure) {
      return ServerError(
        message: _getUserFriendlyMessage(failure.message, ErrorCategory.server),
        context: context,
        originalError: failure,
      );
    } else if (failure is NetworkFailure) {
      return NetworkError(
        message: _getUserFriendlyMessage(
          failure.message,
          ErrorCategory.network,
        ),
        context: context,
        originalError: failure,
      );
    } else if (failure is CacheFailure) {
      return CacheError(
        message: _getUserFriendlyMessage(failure.message, ErrorCategory.cache),
        context: context,
        originalError: failure,
      );
    } else if (failure is AuthFailure) {
      return AuthenticationError(
        message: _getUserFriendlyMessage(
          failure.message,
          ErrorCategory.authentication,
        ),
        context: context,
        originalError: failure,
      );
    } else if (failure is ValidationFailure) {
      return ValidationError(
        message: _getUserFriendlyMessage(
          failure.message,
          ErrorCategory.validation,
        ),
        context: context,
        originalError: failure,
      );
    } else {
      return UnknownError(
        message: _getUserFriendlyMessage(
          failure.message,
          ErrorCategory.unknown,
        ),
        context: context,
        originalError: failure,
      );
    }
  }

  /// Handle server exceptions
  static ServerError _handleServerException(
    ServerException exception,
    String? context,
    Map<String, dynamic>? metadata,
  ) {
    String userMessage;

    switch (exception.statusCode) {
      case 400:
        userMessage = 'Invalid request. Please check your input and try again.';
        break;
      case 401:
        userMessage = 'Authentication required. Please log in again.';
        break;
      case 403:
        userMessage = 'You do not have permission to perform this action.';
        break;
      case 404:
        userMessage = _getNotFoundMessage(context);
        break;
      case 409:
        userMessage = _getConflictMessage(context);
        break;
      case 422:
        userMessage = 'Invalid data provided. Please check your input.';
        break;
      case 429:
        userMessage = 'Too many requests. Please wait a moment and try again.';
        break;
      case 500:
        userMessage = 'Server error. Please try again later.';
        break;
      case 502:
      case 503:
      case 504:
        userMessage =
            'Service temporarily unavailable. Please try again later.';
        break;
      default:
        userMessage = 'An error occurred. Please try again.';
    }

    return ServerError(
      message: userMessage,
      statusCode: exception.statusCode,
      context: context,
      originalError: exception,
    );
  }

  /// Handle network exceptions
  static NetworkError _handleNetworkException(
    NetworkException exception,
    String? context,
    Map<String, dynamic>? metadata,
  ) {
    String userMessage;

    if (exception.message.contains('timeout')) {
      userMessage =
          'Request timed out. Please check your connection and try again.';
    } else if (exception.message.contains('connection')) {
      userMessage = 'Unable to connect. Please check your internet connection.';
    } else if (exception.message.contains('host')) {
      userMessage = 'Unable to reach the server. Please try again later.';
    } else {
      userMessage =
          'Network error. Please check your connection and try again.';
    }

    return NetworkError(
      message: userMessage,
      context: context,
      originalError: exception,
    );
  }

  /// Handle cache exceptions
  static CacheError _handleCacheException(
    CacheException exception,
    String? context,
    Map<String, dynamic>? metadata,
  ) {
    return CacheError(
      message: 'Unable to access local data. Please try again.',
      context: context,
      originalError: exception,
    );
  }

  /// Handle authentication exceptions
  static AuthenticationError _handleAuthException(
    AuthException exception,
    String? context,
    Map<String, dynamic>? metadata,
  ) {
    return AuthenticationError(
      message: 'Authentication failed. Please log in again.',
      context: context,
      originalError: exception,
    );
  }

  /// Handle validation exceptions
  static ValidationError _handleValidationException(
    ValidationException exception,
    String? context,
    Map<String, dynamic>? metadata,
  ) {
    return ValidationError(
      message: 'Invalid data provided. Please check your input and try again.',
      context: context,
      originalError: exception,
    );
  }

  /// Handle unknown exceptions
  static UnknownError _handleUnknownException(
    dynamic exception,
    String? context,
    Map<String, dynamic>? metadata,
  ) {
    return UnknownError(
      message: 'An unexpected error occurred. Please try again.',
      context: context,
      originalError: exception,
    );
  }

  /// Get user-friendly message based on error category
  static String _getUserFriendlyMessage(
    String technicalMessage,
    ErrorCategory category,
  ) {
    switch (category) {
      case ErrorCategory.network:
        return 'Unable to connect. Please check your internet connection.';
      case ErrorCategory.server:
        return 'Service temporarily unavailable. Please try again later.';
      case ErrorCategory.authentication:
        return 'Authentication required. Please log in again.';
      case ErrorCategory.authorization:
        return 'You do not have permission to perform this action.';
      case ErrorCategory.validation:
        return 'Invalid data provided. Please check your input.';
      case ErrorCategory.businessLogic:
        return 'Unable to complete this action. Please try again.';
      case ErrorCategory.timeout:
        return 'Request timed out. Please try again.';
      case ErrorCategory.cache:
        return 'Unable to access local data. Please try again.';
      case ErrorCategory.unknown:
        return 'An unexpected error occurred. Please try again.';
    }
  }

  /// Get context-specific not found message
  static String _getNotFoundMessage(String? context) {
    switch (context) {
      case 'search':
        return 'Search service is temporarily unavailable. Please try again later.';
      case 'product':
        return 'Product not found. It may have been deleted.';
      case 'products':
        return 'Products service is temporarily unavailable. Please try again later.';
      default:
        return 'The requested resource was not found.';
    }
  }

  /// Get context-specific conflict message
  static String _getConflictMessage(String? context) {
    switch (context) {
      case 'product':
        return 'A product with this name already exists. Please choose a different name.';
      case 'delete':
        return 'Cannot delete this item. It may be in use by other records.';
      default:
        return 'This action conflicts with existing data. Please try again.';
    }
  }

  /// Get error severity based on error type
  static ErrorSeverity getErrorSeverity(AppError error) {
    if (error is ServerError) {
      switch (error.statusCode) {
        case 400:
        case 422:
          return ErrorSeverity.medium;
        case 401:
        case 403:
          return ErrorSeverity.high;
        case 404:
          return ErrorSeverity.medium;
        case 500:
        case 502:
        case 503:
        case 504:
          return ErrorSeverity.critical;
        default:
          return ErrorSeverity.medium;
      }
    } else if (error is NetworkError) {
      return ErrorSeverity.high;
    } else if (error is AuthenticationError) {
      return ErrorSeverity.critical;
    } else if (error is AuthorizationError) {
      return ErrorSeverity.high;
    } else if (error is ValidationError) {
      return ErrorSeverity.low;
    } else if (error is TimeoutError) {
      return ErrorSeverity.medium;
    } else if (error is CacheError) {
      return ErrorSeverity.low;
    } else {
      return ErrorSeverity.medium;
    }
  }

  /// Check if error is retryable
  static bool isRetryable(AppError error) {
    if (error is ServerError) {
      return error.statusCode != null &&
          error.statusCode! >= 500 &&
          error.statusCode! < 600;
    } else if (error is NetworkError) {
      return true;
    } else if (error is TimeoutError) {
      return true;
    } else if (error is CacheError) {
      return true;
    }
    return false;
  }
}
