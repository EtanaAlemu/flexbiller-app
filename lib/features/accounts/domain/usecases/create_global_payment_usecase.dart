import 'package:injectable/injectable.dart';
import '../entities/account_payment.dart';
import '../repositories/account_payments_repository.dart';

@injectable
class CreateGlobalPaymentUseCase {
  final AccountPaymentsRepository _paymentsRepository;

  CreateGlobalPaymentUseCase(this._paymentsRepository);

  Future<AccountPayment> call({
    required String externalKey,
    required String paymentMethodId,
    required String transactionExternalKey,
    required String paymentExternalKey,
    required String transactionType,
    required double amount,
    required String currency,
    required DateTime effectiveDate,
    List<Map<String, dynamic>>? properties,
  }) async {
    return await _paymentsRepository.createGlobalPayment(
      externalKey: externalKey,
      paymentMethodId: paymentMethodId,
      transactionExternalKey: transactionExternalKey,
      paymentExternalKey: paymentExternalKey,
      transactionType: transactionType,
      amount: amount,
      currency: currency,
      effectiveDate: effectiveDate,
      properties: properties,
    );
  }
}
