import '../entities/account_invoice.dart';

abstract class AccountInvoicesRepository {
  /// Stream of account invoices for reactive UI updates
  Stream<List<AccountInvoice>> get accountInvoicesStream;

  /// Get all invoices for a specific account
  Future<List<AccountInvoice>> getInvoices(String accountId);

  /// Get paginated invoices for a specific account
  Future<List<AccountInvoice>> getPaginatedInvoices(String accountId);
}
