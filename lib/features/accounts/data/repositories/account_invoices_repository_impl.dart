import 'package:injectable/injectable.dart';
import '../../domain/entities/account_invoice.dart';
import '../../domain/repositories/account_invoices_repository.dart';
import '../datasources/account_invoices_remote_data_source.dart';

@Injectable(as: AccountInvoicesRepository)
class AccountInvoicesRepositoryImpl implements AccountInvoicesRepository {
  final AccountInvoicesRemoteDataSource _remoteDataSource;

  AccountInvoicesRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<AccountInvoice>> getInvoices(String accountId) async {
    try {
      final invoiceModels = await _remoteDataSource.getInvoices(accountId);
      return invoiceModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<AccountInvoice>> getPaginatedInvoices(String accountId) async {
    try {
      final invoiceModels = await _remoteDataSource.getPaginatedInvoices(
        accountId,
      );
      return invoiceModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      rethrow;
    }
  }
}
