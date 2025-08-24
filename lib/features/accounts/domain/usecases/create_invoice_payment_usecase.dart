import 'package:injectable/injectable.dart';
import '../entities/account_invoice_payment.dart';
import '../repositories/account_invoice_payments_repository.dart';

@injectable
class CreateInvoicePaymentUseCase {
  final AccountInvoicePaymentsRepository _invoicePaymentsRepository;

  CreateInvoicePaymentUseCase(this._invoicePaymentsRepository);

  Future<AccountInvoicePayment> call(
    String accountId,
    double paymentAmount,
    String currency,
    String paymentMethod,
    String? notes,
  ) async {
    return await _invoicePaymentsRepository.createInvoicePayment(
      accountId,
      paymentAmount,
      currency,
      paymentMethod,
      notes,
    );
  }
}
