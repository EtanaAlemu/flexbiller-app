import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../errors/exceptions.dart';
import '../errors/failures.dart';
import '../errors/error_handler.dart' as ErrorHandlerCore;
import '../utils/error_handler.dart' as ErrorHandlerUtil;

/// Mixin for standardized error handling in BLoCs
/// Provides consistent error handling patterns across all BLoCs
///
/// Usage:
/// ```dart
/// class MyBloc extends Bloc<Event, State> with BlocErrorHandlerMixin {
///   // Use handleException(), handleEitherResult(), etc.
/// }
/// ```
mixin BlocErrorHandlerMixin {
  final Logger _logger = Logger();

  /// Handle Either result from use cases
  /// Returns the success value or null if failure
  /// Automatically logs errors
  ///
  /// [T] is the success type
  T? handleEitherResult<T>(
    Either<Failure, T> result, {
    String? context,
    void Function(String message)? onError,
  }) {
    return result.fold((failure) {
      final message = _getErrorMessage(failure, context: context);
      _logger.e('[$context] Error: $message', error: failure);
      onError?.call(message);
      return null;
    }, (success) => success);
  }

  /// Handle Either<Failure, T> result and emit error state
  /// Returns true if success, false if failure
  bool handleEitherResultWithEmit<T>(
    Either<Failure, T> result,
    void Function(String message) emitError, {
    String? context,
  }) {
    return result.fold((failure) {
      final message = _getErrorMessage(failure, context: context);
      _logger.e('[$context] Error: $message', error: failure);
      emitError(message);
      return false;
    }, (_) => true);
  }

  /// Handle exceptions and convert to user-friendly messages
  String handleException(
    dynamic exception, {
    String? context,
    Map<String, dynamic>? metadata,
  }) {
    _logger.e('[$context] Exception: $exception', error: exception);

    // Try using core ErrorHandler first (returns AppError)
    try {
      if (exception is ServerException ||
          exception is NetworkException ||
          exception is CacheException ||
          exception is AuthException ||
          exception is ValidationException) {
        final appError = ErrorHandlerCore.ErrorHandler.handleException(
          exception,
          context: context,
          metadata: metadata,
        );
        return appError.message;
      }
    } catch (e) {
      // Fall through to util handler
    }

    // Fallback to util ErrorHandler for DioException and other cases
    if (exception is DioException) {
      return ErrorHandlerUtil.ErrorHandler.convertDioExceptionToUserMessage(
        exception,
        context: context,
      );
    }

    // Use util handler for other exceptions
    return ErrorHandlerUtil.ErrorHandler.getUserFriendlyMessage(
      exception,
      context: context,
    );
  }

  /// Get error message from Failure
  String _getErrorMessage(Failure failure, {String? context}) {
    if (failure is ServerFailure) {
      return ErrorHandlerUtil.ErrorHandler.getUserFriendlyMessage(
        failure.message,
        context: context,
      );
    } else if (failure is NetworkFailure) {
      return ErrorHandlerUtil.ErrorHandler.getUserFriendlyMessage(
        failure.message,
        context: context,
      );
    } else if (failure is CacheFailure) {
      return ErrorHandlerUtil.ErrorHandler.getUserFriendlyMessage(
        failure.message,
        context: context,
      );
    } else if (failure is AuthFailure) {
      return ErrorHandlerUtil.ErrorHandler.getUserFriendlyMessage(
        failure.message,
        context: context,
      );
    } else if (failure is ValidationFailure) {
      return ErrorHandlerUtil.ErrorHandler.getUserFriendlyMessage(
        failure.message,
        context: context,
      );
    } else {
      return ErrorHandlerUtil.ErrorHandler.getUserFriendlyMessage(
        failure.message,
        context: context,
      );
    }
  }

  /// Execute async operation with standardized error handling
  Future<T?> executeWithErrorHandling<T>(
    Future<T> Function() operation, {
    String? context,
    void Function(String message)? onError,
  }) async {
    try {
      return await operation();
    } catch (e) {
      final message = handleException(e, context: context);
      _logger.e('[$context] Operation failed: $message', error: e);
      onError?.call(message);
      return null;
    }
  }

  /// Execute async operation that returns Either result
  ///
  /// [T] is the success type
  Future<T?> executeEitherWithErrorHandling<T>(
    Future<Either<Failure, T>> Function() operation, {
    String? context,
    void Function(String message)? onError,
  }) async {
    try {
      final result = await operation();
      return handleEitherResult(result, context: context, onError: onError);
    } catch (e) {
      final message = handleException(e, context: context);
      _logger.e('[$context] Operation failed: $message', error: e);
      onError?.call(message);
      return null;
    }
  }
}
