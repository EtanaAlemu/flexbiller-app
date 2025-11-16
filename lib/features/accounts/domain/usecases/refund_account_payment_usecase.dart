import 'package:injectable/injectable.dart';
import '../repositories/account_payments_repository.dart';

@injectable
class RefundAccountPaymentUseCase {
  final AccountPaymentsRepository _paymentsRepository;

  RefundAccountPaymentUseCase(this._paymentsRepository);

  Future<void> call({
    required String accountId,
    required String paymentId,
    required double refundAmount,
    required String reason,
  }) async {
    return await _paymentsRepository.refundPayment(
      accountId: accountId,
      paymentId: paymentId,
      refundAmount: refundAmount,
      reason: reason,
    );
  }
}
