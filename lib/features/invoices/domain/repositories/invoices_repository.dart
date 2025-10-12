import 'package:dartz/dartz.dart';
import '../../../../../core/errors/failures.dart';
import '../entities/invoice.dart';
import '../entities/invoice_audit_log.dart';

abstract class InvoicesRepository {
  /// Get all invoices
  /// Returns cached invoices immediately, then syncs with remote in background
  Future<Either<Failure, List<Invoice>>> getInvoices();

  /// Get a specific invoice by ID
  /// Returns cached invoice immediately, then syncs with remote in background
  Future<Either<Failure, Invoice>> getInvoiceById(String invoiceId);

  /// Get invoices by account ID
  /// Returns cached invoices immediately, then syncs with remote in background
  Future<Either<Failure, List<Invoice>>> getInvoicesByAccountId(
    String accountId,
  );

  /// Search invoices by search key
  /// Searches only in local cache - no remote calls
  Future<Either<Failure, List<Invoice>>> searchInvoices(String searchKey);

  /// Get cached invoices from local storage
  Future<Either<Failure, List<Invoice>>> getCachedInvoices();

  /// Get cached invoice by ID from local storage
  Future<Either<Failure, Invoice>> getCachedInvoiceById(String invoiceId);

  /// Get cached invoices by account ID from local storage
  Future<Either<Failure, List<Invoice>>> getCachedInvoicesByAccountId(
    String accountId,
  );

  /// Get invoice audit logs with history by invoice ID
  /// Returns cached audit logs immediately, then syncs with remote in background
  Future<Either<Failure, List<InvoiceAuditLog>>> getInvoiceAuditLogsWithHistory(
    String invoiceId,
  );

  /// Adjust an invoice item
  /// Updates invoice item amount and description
  Future<Either<Failure, void>> adjustInvoiceItem(
    String invoiceId,
    String invoiceItemId,
    String accountId,
    double amount,
    String currency,
    String description,
  );
}
