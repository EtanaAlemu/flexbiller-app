import '../entities/account_payment.dart';

abstract class AccountPaymentsRepository {
  /// Get all payments for a specific account
  Future<List<AccountPayment>> getAccountPayments(String accountId);

  /// Get a specific payment by ID
  Future<AccountPayment> getAccountPayment(String accountId, String paymentId);

  /// Get payments by status for an account
  Future<List<AccountPayment>> getAccountPaymentsByStatus(String accountId, String status);

  /// Get payments by type for an account
  Future<List<AccountPayment>> getAccountPaymentsByType(String accountId, String type);

  /// Get payments by date range for an account
  Future<List<AccountPayment>> getAccountPaymentsByDateRange(
    String accountId,
    DateTime startDate,
    DateTime endDate,
  );

  /// Get payments with pagination for an account
  Future<List<AccountPayment>> getAccountPaymentsWithPagination(
    String accountId,
    int page,
    int pageSize,
  );

  /// Get payment statistics for an account
  Future<Map<String, dynamic>> getAccountPaymentStatistics(String accountId);

  /// Search payments for an account
  Future<List<AccountPayment>> searchAccountPayments(String accountId, String searchTerm);

  /// Get refunded payments for an account
  Future<List<AccountPayment>> getRefundedPayments(String accountId);

  /// Get failed payments for an account
  Future<List<AccountPayment>> getFailedPayments(String accountId);

  /// Get successful payments for an account
  Future<List<AccountPayment>> getSuccessfulPayments(String accountId);

  /// Get pending payments for an account
  Future<List<AccountPayment>> getPendingPayments(String accountId);
}
