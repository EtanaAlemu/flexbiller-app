import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../../core/errors/failures.dart';
import '../entities/payment.dart';
import '../repositories/payments_repository.dart';

@injectable
class GetPaymentById {
  final PaymentsRepository _repository;

  GetPaymentById(this._repository);

  Future<Either<Failure, Payment>> call(String paymentId) async {
    return await _repository.getPaymentById(paymentId);
  }
}
