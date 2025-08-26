import '../entities/account_invoice.dart';

abstract class AccountInvoicesRepository {
  Future<List<AccountInvoice>> getInvoices(String accountId);
  Future<List<AccountInvoice>> getPaginatedInvoices(String accountId);
}
