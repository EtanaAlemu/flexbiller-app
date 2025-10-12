import 'package:dartz/dartz.dart';
import '../../../../../core/errors/failures.dart';
import '../entities/payment.dart';

abstract class PaymentsRepository {
  /// Get all payments
  /// Returns cached payments immediately, then syncs with remote in background
  Future<Either<Failure, List<Payment>>> getPayments();

  /// Get a specific payment by ID
  /// Returns cached payment immediately, then syncs with remote in background
  Future<Either<Failure, Payment>> getPaymentById(String paymentId);

  /// Get payments by account ID
  /// Returns cached payments immediately, then syncs with remote in background
  Future<Either<Failure, List<Payment>>> getPaymentsByAccountId(
    String accountId,
  );

  /// Search payments by search key
  /// Searches only in local cache - no remote calls
  Future<Either<Failure, List<Payment>>> searchPayments(String searchKey);

  /// Get cached payments from local storage
  Future<Either<Failure, List<Payment>>> getCachedPayments();

  /// Get cached payment by ID from local storage
  Future<Either<Failure, Payment>> getCachedPaymentById(String paymentId);

  /// Get cached payments by account ID from local storage
  Future<Either<Failure, List<Payment>>> getCachedPaymentsByAccountId(
    String accountId,
  );
}
