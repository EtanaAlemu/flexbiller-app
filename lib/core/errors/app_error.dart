import 'package:equatable/equatable.dart';

/// Base class for all application errors
abstract class AppError extends Equatable {
  final String message;
  final String? context;
  final dynamic originalError;

  const AppError({required this.message, this.context, this.originalError});

  @override
  List<Object?> get props => [message, context, originalError];
}

/// Network-related errors
class NetworkError extends AppError {
  const NetworkError({
    required String message,
    String? context,
    dynamic originalError,
  }) : super(message: message, context: context, originalError: originalError);
}

/// Server-related errors
class ServerError extends AppError {
  final int? statusCode;

  const ServerError({
    required String message,
    this.statusCode,
    String? context,
    dynamic originalError,
  }) : super(message: message, context: context, originalError: originalError);

  @override
  List<Object?> get props => [message, statusCode, context, originalError];
}

/// Authentication-related errors
class AuthenticationError extends AppError {
  const AuthenticationError({
    required String message,
    String? context,
    dynamic originalError,
  }) : super(message: message, context: context, originalError: originalError);
}

/// Authorization-related errors
class AuthorizationError extends AppError {
  const AuthorizationError({
    required String message,
    String? context,
    dynamic originalError,
  }) : super(message: message, context: context, originalError: originalError);
}

/// Validation-related errors
class ValidationError extends AppError {
  final Map<String, List<String>>? fieldErrors;

  const ValidationError({
    required String message,
    this.fieldErrors,
    String? context,
    dynamic originalError,
  }) : super(message: message, context: context, originalError: originalError);

  @override
  List<Object?> get props => [message, fieldErrors, context, originalError];
}

/// Business logic errors
class BusinessLogicError extends AppError {
  const BusinessLogicError({
    required String message,
    String? context,
    dynamic originalError,
  }) : super(message: message, context: context, originalError: originalError);
}

/// Timeout errors
class TimeoutError extends AppError {
  const TimeoutError({
    required String message,
    String? context,
    dynamic originalError,
  }) : super(message: message, context: context, originalError: originalError);
}

/// Cache/storage errors
class CacheError extends AppError {
  const CacheError({
    required String message,
    String? context,
    dynamic originalError,
  }) : super(message: message, context: context, originalError: originalError);
}

/// Unknown/unexpected errors
class UnknownError extends AppError {
  const UnknownError({
    required String message,
    String? context,
    dynamic originalError,
  }) : super(message: message, context: context, originalError: originalError);
}

/// Error categories for better error handling
enum ErrorCategory {
  network,
  server,
  authentication,
  authorization,
  validation,
  businessLogic,
  timeout,
  cache,
  unknown,
}

/// Error severity levels
enum ErrorSeverity {
  low, // Minor issues that don't affect core functionality
  medium, // Issues that affect some functionality
  high, // Issues that significantly impact user experience
  critical, // Issues that prevent core functionality
}

/// Error context for better error handling
class ErrorContext {
  final String feature;
  final String? action;
  final Map<String, dynamic>? metadata;

  const ErrorContext({required this.feature, this.action, this.metadata});

  @override
  String toString() {
    return 'ErrorContext(feature: $feature, action: $action, metadata: $metadata)';
  }
}
