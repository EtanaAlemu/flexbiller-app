import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../../core/errors/failures.dart';
import '../repositories/payments_repository.dart';

@injectable
class DeletePaymentUseCase {
  final PaymentsRepository _paymentsRepository;

  DeletePaymentUseCase(this._paymentsRepository);

  Future<Either<Failure, void>> call(String paymentId) async {
    return await _paymentsRepository.deletePayment(paymentId);
  }
}
