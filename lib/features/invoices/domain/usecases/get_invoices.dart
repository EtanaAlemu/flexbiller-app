import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../../core/errors/failures.dart';
import '../entities/invoice.dart';
import '../repositories/invoices_repository.dart';

@injectable
class GetInvoices {
  final InvoicesRepository _repository;

  GetInvoices(this._repository);

  Future<Either<Failure, List<Invoice>>> call() async {
    return await _repository.getInvoices();
  }
}

