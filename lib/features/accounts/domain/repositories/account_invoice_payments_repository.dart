import '../entities/account_invoice_payment.dart';

abstract class AccountInvoicePaymentsRepository {
  /// Get all invoice payments for a specific account
  Future<List<AccountInvoicePayment>> getAccountInvoicePayments(String accountId);

  /// Get a specific invoice payment by ID
  Future<AccountInvoicePayment> getAccountInvoicePayment(String accountId, String paymentId);

  /// Get invoice payments by status
  Future<List<AccountInvoicePayment>> getInvoicePaymentsByStatus(String accountId, String status);

  /// Get invoice payments by date range
  Future<List<AccountInvoicePayment>> getInvoicePaymentsByDateRange(
    String accountId,
    DateTime startDate,
    DateTime endDate,
  );

  /// Get invoice payments by payment method
  Future<List<AccountInvoicePayment>> getInvoicePaymentsByMethod(String accountId, String paymentMethod);

  /// Get invoice payments by invoice number
  Future<List<AccountInvoicePayment>> getInvoicePaymentsByInvoiceNumber(String accountId, String invoiceNumber);

  /// Get invoice payments with pagination
  Future<List<AccountInvoicePayment>> getInvoicePaymentsWithPagination(
    String accountId,
    int page,
    int pageSize,
  );

  /// Get invoice payment statistics for an account
  Future<Map<String, dynamic>> getInvoicePaymentStatistics(String accountId);
}
