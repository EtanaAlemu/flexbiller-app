import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

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

  PaymentsRepositoryImpl({
    required PaymentsRemoteDataSource remoteDataSource,
    required PaymentsLocalDataSource localDataSource,
    required NetworkInfo networkInfo,
  }) : _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource,
       _networkInfo = networkInfo;

  @override
  Future<Either<Failure, List<Payment>>> getPayments() async {
    try {
      // First, try to get cached payments immediately (local-first approach)
      final cachedPayments = await _localDataSource.getCachedPayments();
      if (cachedPayments.isNotEmpty) {
        // Return cached data immediately
        final payments = cachedPayments
            .map((model) => model.toEntity())
            .toList();

        // Then sync with remote in background if online
        if (await _networkInfo.isConnected) {
          _syncPaymentsInBackground();
        }

        return Right(payments);
      }

      // If no cached data, try to fetch from remote
      if (await _networkInfo.isConnected) {
        try {
          final remotePayments = await _remoteDataSource.getPayments();

          // Cache the remote data
          await _localDataSource.cachePayments(remotePayments);

          // Return the data
          final payments = remotePayments
              .map((model) => model.toEntity())
              .toList();
          return Right(payments);
        } catch (e) {
          return Left(ServerFailure('Failed to fetch payments: $e'));
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
      final remotePayments = await _remoteDataSource.getPayments();
      await _localDataSource.cachePayments(remotePayments);
    } catch (e) {
      // Log error but don't throw - this is background sync
      // In a real app, you might want to use a proper logging service
      // print('Background sync failed: $e');
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
}
