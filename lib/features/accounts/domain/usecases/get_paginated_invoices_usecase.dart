import 'package:injectable/injectable.dart';
import '../entities/account_invoice.dart';
import '../repositories/account_invoices_repository.dart';

@injectable
class GetPaginatedInvoicesUseCase {
  final AccountInvoicesRepository _invoicesRepository;

  GetPaginatedInvoicesUseCase(this._invoicesRepository);

  Future<List<AccountInvoice>> call(String accountId) async {
    return await _invoicesRepository.getPaginatedInvoices(accountId);
  }
}
