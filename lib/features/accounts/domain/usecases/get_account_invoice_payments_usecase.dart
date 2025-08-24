import 'package:injectable/injectable.dart';
import '../entities/account_invoice_payment.dart';
import '../repositories/account_invoice_payments_repository.dart';

@injectable
class GetAccountInvoicePaymentsUseCase {
  final AccountInvoicePaymentsRepository _invoicePaymentsRepository;

  GetAccountInvoicePaymentsUseCase(this._invoicePaymentsRepository);

  Future<List<AccountInvoicePayment>> call(String accountId) async {
    return await _invoicePaymentsRepository.getAccountInvoicePayments(accountId);
  }
}
