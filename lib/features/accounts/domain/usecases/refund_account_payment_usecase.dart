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
    // For now, this is a placeholder implementation
    // The actual refund logic would be implemented in the repository
    throw UnimplementedError('Refund functionality not yet implemented');
  }
}

