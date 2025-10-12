import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../../core/errors/failures.dart';
import '../entities/payment.dart';
import '../repositories/payments_repository.dart';

@injectable
class GetPaymentsByAccountId {
  final PaymentsRepository _repository;

  GetPaymentsByAccountId(this._repository);

  Future<Either<Failure, List<Payment>>> call(String accountId) async {
    return await _repository.getPaymentsByAccountId(accountId);
  }
}
