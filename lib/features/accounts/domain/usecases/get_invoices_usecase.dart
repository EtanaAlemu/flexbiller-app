import 'package:injectable/injectable.dart';
import '../entities/account_invoice.dart';
import '../repositories/account_invoices_repository.dart';

@injectable
class GetInvoicesUseCase {
  final AccountInvoicesRepository _invoicesRepository;

  GetInvoicesUseCase(this._invoicesRepository);

  Future<List<AccountInvoice>> call(String accountId) async {
    return await _invoicesRepository.getInvoices(accountId);
  }
}
