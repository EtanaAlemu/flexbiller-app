import 'package:injectable/injectable.dart';
import '../entities/account_payment.dart';
import '../repositories/account_payments_repository.dart';

@injectable
class CreateAccountPaymentUseCase {
  final AccountPaymentsRepository _paymentsRepository;

  CreateAccountPaymentUseCase(this._paymentsRepository);

  Future<AccountPayment> call({
    required String accountId,
    required String paymentMethodId,
    required String transactionType,
    required double amount,
    required String currency,
    required DateTime effectiveDate,
    String? description,
    Map<String, dynamic>? properties,
  }) async {
    return await _paymentsRepository.createAccountPayment(
      accountId: accountId,
      paymentMethodId: paymentMethodId,
      transactionType: transactionType,
      amount: amount,
      currency: currency,
      effectiveDate: effectiveDate,
      description: description,
      properties: properties,
    );
  }
}
