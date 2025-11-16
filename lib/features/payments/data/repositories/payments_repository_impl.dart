import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';

import '../../../../../core/errors/failures.dart';
import '../../../../../core/network/network_info.dart';
import '../../domain/entities/payment.dart';
import '../../domain/repositories/payments_repository.dart';
import '../datasources/local/payments_local_data_source.dart';
import '../datasources/remote/payments_remote_data_source.dart';

@LazySingleton(as: PaymentsRepository)
class PaymentsRepositoryImpl implements PaymentsRepository {
  final PaymentsRemoteDataSource _remoteDataSource;
  final PaymentsLocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;
  final Logger _logger;

  PaymentsRepositoryImpl({
    required PaymentsRemoteDataSource remoteDataSource,
    required PaymentsLocalDataSource localDataSource,
    required NetworkInfo networkInfo,
    required Logger logger,
  }) : _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource,
       _networkInfo = networkInfo,
       _logger = logger;

  @override
  Future<Either<Failure, List<Payment>>> getPayments() async {
    try {
      _logger.d('PaymentsRepository: Starting getPayments()');

      // First, try to get cached payments immediately (local-first approach)
      _logger.d('PaymentsRepository: Attempting to get cached payments');
      final cachedPayments = await _localDataSource.getCachedPayments();
      _logger.d(
        'PaymentsRepository: Retrieved ${cachedPayments.length} cached payments',
      );

      if (cachedPayments.isNotEmpty) {
        _logger.d(
          'PaymentsRepository: Found cached payments, returning immediately',
        );
        // Return cached data immediately
        final payments = cachedPayments
            .map((model) => model.toEntity())
            .toList();

        // Then sync with remote in background if online
        _logger.d(
          'PaymentsRepository: Checking network connectivity for background sync',
        );
        if (await _networkInfo.isConnected) {
          _logger.d(
            'PaymentsRepository: Network connected, starting background sync',
          );
          _syncPaymentsInBackground();
        } else {
          _logger.d(
            'PaymentsRepository: No network connection, skipping background sync',
          );
        }

        _logger.d(
          'PaymentsRepository: Returning ${payments.length} cached payments',
        );
        return Right(payments);
      }

      _logger.d(
        'PaymentsRepository: No cached payments found, attempting remote fetch',
      );
      // If no cached data, try to fetch from remote
      if (await _networkInfo.isConnected) {
        _logger.d(
          'PaymentsRepository: Network connected, fetching from remote',
        );
        try {
          final remotePayments = await _remoteDataSource.getPayments();
          _logger.d(
            'PaymentsRepository: Retrieved ${remotePayments.length} payments from remote',
          );

          // Cache the remote data
          _logger.d('PaymentsRepository: Caching remote payments');
          await _localDataSource.cachePayments(remotePayments);

          // Return the data
          final payments = remotePayments
              .map((model) => model.toEntity())
              .toList();
          _logger.d(
            'PaymentsRepository: Returning ${payments.length} remote payments',
          );
          return Right(payments);
        } catch (e, stackTrace) {
          _logger.e(
            'PaymentsRepository: Error fetching payments from remote: $e',
          );
          _logger.e('PaymentsRepository: Stack trace: $stackTrace');
          return Left(ServerFailure('Failed to fetch payments: $e'));
        }
      } else {
        _logger.w(
          'PaymentsRepository: No internet connection and no cached data',
        );
        return Left(
          NetworkFailure('No internet connection and no cached data'),
        );
      }
    } catch (e, stackTrace) {
      _logger.e('PaymentsRepository: Unexpected error in getPayments: $e');
      _logger.e('PaymentsRepository: Stack trace: $stackTrace');
      return Left(CacheFailure('Error accessing local storage: $e'));
    }
  }

  @override
  Future<Either<Failure, Payment>> getPaymentById(String paymentId) async {
    try {
      // First, try to get cached payment immediately (local-first approach)
      final cachedPayment = await _localDataSource.getCachedPaymentById(
        paymentId,
      );
      if (cachedPayment != null) {
        // Return cached data immediately
        final payment = cachedPayment.toEntity();

        // Then sync with remote in background if online
        if (await _networkInfo.isConnected) {
          _syncPaymentByIdInBackground(paymentId);
        }

        return Right(payment);
      }

      // If no cached data, try to fetch from remote
      if (await _networkInfo.isConnected) {
        try {
          final remotePayment = await _remoteDataSource.getPaymentById(
            paymentId,
          );

          // Cache the remote data
          await _localDataSource.cachePayment(remotePayment);

          // Return the data
          final payment = remotePayment.toEntity();
          return Right(payment);
        } catch (e) {
          return Left(ServerFailure('Failed to fetch payment: $e'));
        }
      } else {
        return Left(
          NetworkFailure('No internet connection and no cached data'),
        );
      }
    } catch (e) {
      return Left(CacheFailure('Error accessing local storage: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Payment>>> getPaymentsByAccountId(
    String accountId,
  ) async {
    try {
      // First, try to get cached payments immediately (local-first approach)
      final cachedPayments = await _localDataSource
          .getCachedPaymentsByAccountId(accountId);
      if (cachedPayments.isNotEmpty) {
        // Return cached data immediately
        final payments = cachedPayments
            .map((model) => model.toEntity())
            .toList();

        // Then sync with remote in background if online
        if (await _networkInfo.isConnected) {
          _syncPaymentsByAccountIdInBackground(accountId);
        }

        return Right(payments);
      }

      // If no cached data, try to fetch from remote
      if (await _networkInfo.isConnected) {
        try {
          final remotePayments = await _remoteDataSource.getPaymentsByAccountId(
            accountId,
          );

          // Cache the remote data
          await _localDataSource.cachePayments(remotePayments);

          // Return the data
          final payments = remotePayments
              .map((model) => model.toEntity())
              .toList();
          return Right(payments);
        } catch (e) {
          return Left(ServerFailure('Failed to fetch payments by account: $e'));
        }
      } else {
        return Left(
          NetworkFailure('No internet connection and no cached data'),
        );
      }
    } catch (e) {
      return Left(CacheFailure('Error accessing local storage: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Payment>>> getCachedPayments() async {
    try {
      final cachedPayments = await _localDataSource.getCachedPayments();
      final payments = cachedPayments.map((model) => model.toEntity()).toList();
      return Right(payments);
    } catch (e) {
      return Left(CacheFailure('Error retrieving cached payments: $e'));
    }
  }

  @override
  Future<Either<Failure, Payment>> getCachedPaymentById(
    String paymentId,
  ) async {
    try {
      final cachedPayment = await _localDataSource.getCachedPaymentById(
        paymentId,
      );
      if (cachedPayment != null) {
        final payment = cachedPayment.toEntity();
        return Right(payment);
      } else {
        return Left(CacheFailure('Payment not found in cache'));
      }
    } catch (e) {
      return Left(CacheFailure('Error retrieving cached payment: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Payment>>> searchPayments(
    String searchKey,
  ) async {
    try {
      _logger.d(
        'PaymentsRepository: Starting searchPayments with key: $searchKey',
      );

      // Only search in local cache - no remote calls for search
      final cachedResults = await _localDataSource.searchCachedPayments(
        searchKey,
      );

      _logger.d(
        'PaymentsRepository: Found ${cachedResults.length} cached search results',
      );

      final payments = cachedResults.map((model) => model.toEntity()).toList();
      return Right(payments);
    } catch (e, stackTrace) {
      _logger.e('PaymentsRepository: Error searching payments: $e');
      _logger.e('PaymentsRepository: Stack trace: $stackTrace');
      return Left(CacheFailure('Error searching payments: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Payment>>> getCachedPaymentsByAccountId(
    String accountId,
  ) async {
    try {
      final cachedPayments = await _localDataSource
          .getCachedPaymentsByAccountId(accountId);
      final payments = cachedPayments.map((model) => model.toEntity()).toList();
      return Right(payments);
    } catch (e) {
      return Left(
        CacheFailure('Error retrieving cached payments by account: $e'),
      );
    }
  }

  /// Sync payments with remote server in background
  Future<void> _syncPaymentsInBackground() async {
    try {
      _logger.d('PaymentsRepository: Starting background sync for payments');
      final remotePayments = await _remoteDataSource.getPayments();
      _logger.d(
        'PaymentsRepository: Retrieved ${remotePayments.length} payments for background sync',
      );
      await _localDataSource.cachePayments(remotePayments);
      _logger.d('PaymentsRepository: Background sync completed successfully');
    } catch (e, stackTrace) {
      // Log error but don't throw - this is background sync
      _logger.e('PaymentsRepository: Background sync failed: $e');
      _logger.e('PaymentsRepository: Background sync stack trace: $stackTrace');
    }
  }

  /// Sync specific payment with remote server in background
  Future<void> _syncPaymentByIdInBackground(String paymentId) async {
    try {
      final remotePayment = await _remoteDataSource.getPaymentById(paymentId);
      await _localDataSource.cachePayment(remotePayment);
    } catch (e) {
      // Log error but don't throw - this is background sync
      // print('Background sync failed for payment $paymentId: $e');
    }
  }

  /// Sync payments by account with remote server in background
  Future<void> _syncPaymentsByAccountIdInBackground(String accountId) async {
    try {
      final remotePayments = await _remoteDataSource.getPaymentsByAccountId(
        accountId,
      );
      await _localDataSource.cachePayments(remotePayments);
    } catch (e) {
      // Log error but don't throw - this is background sync
      // print('Background sync failed for account $accountId: $e');
    }
  }

  @override
  Future<Either<Failure, void>> deletePayment(String paymentId) async {
    try {
      _logger.d('PaymentsRepository: Deleting payment: $paymentId');

      // Local-first: Delete from local cache first
      await _localDataSource.deleteCachedPayment(paymentId);
      _logger.d('PaymentsRepository: Payment deleted from local cache');

      // If online, try to sync with remote
      if (await _networkInfo.isConnected) {
        try {
          await _remoteDataSource.deletePayment(paymentId);
          _logger.d('PaymentsRepository: Payment deleted on remote');
        } catch (e) {
          _logger.w(
            'PaymentsRepository: Failed to delete payment on remote: $e',
          );
          // In local-first architecture, local deletion is the source of truth
          // Don't fail the operation if remote deletion fails
        }
      } else {
        _logger.d(
          'PaymentsRepository: Offline - payment deleted locally, will sync when online',
        );
      }

      return const Right(null);
    } catch (e) {
      _logger.e('PaymentsRepository: Error deleting payment: $e');
      return Left(CacheFailure('Failed to delete payment: $e'));
    }
  }
}
