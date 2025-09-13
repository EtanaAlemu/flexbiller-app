import 'dart:async';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import '../network/network_info.dart';
import '../models/repository_response.dart';
import '../errors/exceptions.dart';

/// Background synchronization service for handling offline operations
/// Implements retry logic with exponential backoff and conflict resolution
class SyncService {
  final NetworkInfo _networkInfo;
  final Logger _logger = Logger();

  // Sync queue for offline operations
  final _syncQueue = StreamController<SyncOperation>.broadcast();
  late final StreamSubscription _syncSubscription;

  // Retry configuration
  final RetryConfig _retryConfig = const RetryConfig();

  // Track failed operations for retry
  final List<SyncOperation> _failedOperations = [];
  Timer? _retryTimer;

  SyncService(this._networkInfo) {
    _initSyncQueue();
  }

  void _initSyncQueue() {
    _syncSubscription = _syncQueue.stream
        .asyncMap((operation) async {
          try {
            await _executeWithRetry(operation);
            _logger.d('Sync operation completed successfully');
          } catch (e) {
            _logger.e('Sync operation failed after all retries: $e');
            _failedOperations.add(operation);
            _scheduleRetry();
          }
        })
        .listen((_) {});
  }

  /// Add an operation to the sync queue
  void queueOperation(SyncOperation operation) {
    _syncQueue.add(operation);
    _logger.d('📥 SyncService: Operation queued for sync');
  }

  /// Execute an operation with retry logic
  Future<void> _executeWithRetry(SyncOperation operation) async {
    int attempts = 0;
    Exception? lastException;

    _logger.d('🚀 SyncService: Starting operation execution');

    while (attempts < _retryConfig.maxAttempts) {
      try {
        // Check network connectivity before attempting
        if (!await _networkInfo.isConnected) {
          throw NetworkException('No network connection available');
        }

        _logger.d(
          '🔄 SyncService: Executing operation, attempt ${attempts + 1}',
        );
        await operation();
        _logger.d('Operation executed successfully on attempt ${attempts + 1}');
        return;
      } catch (e) {
        lastException = e is Exception ? e : Exception(e.toString());
        attempts++;

        if (attempts < _retryConfig.maxAttempts) {
          final delay = _retryConfig.getDelayForAttempt(attempts);
          _logger.w(
            'Operation failed on attempt $attempts, retrying in ${delay.inSeconds}s: $e',
          );
          await Future.delayed(delay);
        }
      }
    }

    throw lastException ?? Exception('Operation failed after all retries');
  }

  /// Schedule retry for failed operations
  void _scheduleRetry() {
    if (_retryTimer?.isActive == true) return;

    _retryTimer = Timer(const Duration(minutes: 5), () async {
      if (await _networkInfo.isConnected && _failedOperations.isNotEmpty) {
        _logger.d('Retrying ${_failedOperations.length} failed operations');
        final operations = List<SyncOperation>.from(_failedOperations);
        _failedOperations.clear();

        for (final operation in operations) {
          queueOperation(operation);
        }
      }
    });
  }

  /// Force sync all pending operations
  Future<void> forceSync() async {
    if (!await _networkInfo.isConnected) {
      _logger.w('Cannot force sync: no network connection');
      return;
    }

    _logger.d('Force syncing all pending operations');
    final operations = List<SyncOperation>.from(_failedOperations);
    _failedOperations.clear();

    for (final operation in operations) {
      try {
        await operation();
        _logger.d('Force sync operation completed successfully');
      } catch (e) {
        _logger.e('Force sync operation failed: $e');
        _failedOperations.add(operation);
      }
    }
  }

  /// Get sync status
  SyncStatus getStatus() {
    return SyncStatus(
      pendingOperations: _failedOperations.length,
      isConnected: false, // Will be updated by network info
      lastSyncTime: DateTime.now(),
    );
  }

  /// Clear all pending operations
  void clearPendingOperations() {
    _failedOperations.clear();
    _retryTimer?.cancel();
    _logger.d('Cleared all pending operations');
  }

  /// Dispose resources
  void dispose() {
    _syncQueue.close();
    _syncSubscription.cancel();
    _retryTimer?.cancel();
    _failedOperations.clear();
  }
}

/// Sync status information
class SyncStatus {
  final int pendingOperations;
  final bool isConnected;
  final DateTime lastSyncTime;

  const SyncStatus({
    required this.pendingOperations,
    required this.isConnected,
    required this.lastSyncTime,
  });

  bool get hasPendingOperations => pendingOperations > 0;
  bool get isFullySynced => pendingOperations == 0 && isConnected;
}

// NetworkException is imported from core/errors/exceptions.dart
