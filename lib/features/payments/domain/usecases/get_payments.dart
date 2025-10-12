import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../../core/errors/failures.dart';
import '../entities/payment.dart';
import '../repositories/payments_repository.dart';

@injectable
class GetPayments {
  final PaymentsRepository _repository;

  GetPayments(this._repository);

  Future<Either<Failure, List<Payment>>> call() async {
    return await _repository.getPayments();
  }
}
