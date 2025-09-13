import 'package:equatable/equatable.dart';

/// Standardized response wrapper for repository operations
/// Provides consistent handling of success, error, and loading states
class RepositoryResponse<T> extends Equatable {
  final T? data;
  final Exception? exception;
  final bool isLoading;
  final String? message;

  const RepositoryResponse._({
    this.data,
    this.exception,
    this.isLoading = false,
    this.message,
  });

  /// Create a successful response with data
  factory RepositoryResponse.success(T data, {String? message}) =>
      RepositoryResponse._(data: data, message: message);

  /// Create an error response with exception
  factory RepositoryResponse.error({
    T? data,
    Exception? exception,
    String? message,
  }) =>
      RepositoryResponse._(data: data, exception: exception, message: message);

  /// Create a loading response with optional existing data
  factory RepositoryResponse.loading([T? data, String? message]) =>
      RepositoryResponse._(data: data, isLoading: true, message: message);

  /// Check if the response is successful
  bool get isSuccess => exception == null && !isLoading;

  /// Check if the response has an error
  bool get hasError => exception != null;

  /// Check if the response is in loading state
  bool get isInProgress => isLoading;

  /// Get the error message
  String get errorMessage =>
      exception?.toString() ?? message ?? 'Unknown error';

  /// Get the data or throw if there's an error
  T get requireData {
    if (hasError) {
      throw exception!;
    }
    if (data == null) {
      throw StateError('No data available');
    }
    return data!;
  }

  /// Map the data to another type
  RepositoryResponse<R> map<R>(R Function(T) mapper) {
    if (hasError) {
      return RepositoryResponse<R>.error(
        exception: exception,
        message: message,
      );
    }
    if (isLoading) {
      return RepositoryResponse<R>.loading(
        data != null ? mapper(data as T) : null,
        message,
      );
    }
    return RepositoryResponse<R>.success(mapper(data as T), message: message);
  }

  /// Chain another operation
  RepositoryResponse<R> flatMap<R>(RepositoryResponse<R> Function(T) mapper) {
    if (hasError || isLoading) {
      return RepositoryResponse<R>.error(
        exception: exception,
        message: message,
      );
    }
    return mapper(data as T);
  }

  @override
  List<Object?> get props => [data, exception, isLoading, message];

  @override
  String toString() {
    if (isLoading) {
      return 'RepositoryResponse.loading(data: $data, message: $message)';
    }
    if (hasError) {
      return 'RepositoryResponse.error(exception: $exception, message: $message)';
    }
    return 'RepositoryResponse.success(data: $data, message: $message)';
  }
}

/// Type definition for sync operations
typedef SyncOperation = Future<void> Function();

/// Sync operation result
class SyncResult extends Equatable {
  final bool success;
  final Exception? error;
  final String? message;
  final DateTime timestamp;

  const SyncResult({
    required this.success,
    this.error,
    this.message,
    required this.timestamp,
  });

  factory SyncResult.success({String? message}) =>
      SyncResult(success: true, message: message, timestamp: DateTime.now());

  factory SyncResult.failure(Exception error, {String? message}) => SyncResult(
    success: false,
    error: error,
    message: message,
    timestamp: DateTime.now(),
  );

  @override
  List<Object?> get props => [success, error, message, timestamp];
}

/// Retry configuration for sync operations
class RetryConfig extends Equatable {
  final int maxAttempts;
  final Duration initialDelay;
  final double backoffMultiplier;
  final Duration maxDelay;

  const RetryConfig({
    this.maxAttempts = 3,
    this.initialDelay = const Duration(seconds: 1),
    this.backoffMultiplier = 2.0,
    this.maxDelay = const Duration(minutes: 5),
  });

  Duration getDelayForAttempt(int attempt) {
    final delay = Duration(
      milliseconds:
          (initialDelay.inMilliseconds * (backoffMultiplier * attempt)).round(),
    );
    return delay > maxDelay ? maxDelay : delay;
  }

  @override
  List<Object?> get props => [
    maxAttempts,
    initialDelay,
    backoffMultiplier,
    maxDelay,
  ];
}
