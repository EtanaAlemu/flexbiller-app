import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';

import '../../../../core/errors/failures.dart';
import '../entities/invoice.dart';
import '../repositories/invoices_repository.dart';

@injectable
class GetInvoiceById {
  final InvoicesRepository _invoicesRepository;
  final Logger _logger;

  GetInvoiceById(this._invoicesRepository, this._logger);

  Future<Either<Failure, Invoice>> call(String invoiceId) async {
    try {
      _logger.d('GetInvoiceById: Starting to get invoice with ID: $invoiceId');

      final result = await _invoicesRepository.getInvoiceById(invoiceId);

      return result.fold(
        (failure) {
          _logger.e(
            'GetInvoiceById: Failed to get invoice: ${failure.message}',
          );
          return Left(failure);
        },
        (invoice) {
          _logger.d(
            'GetInvoiceById: Successfully retrieved invoice: ${invoice.invoiceNumber}',
          );
          return Right(invoice);
        },
      );
    } catch (e, stackTrace) {
      _logger.e('GetInvoiceById: Unexpected error: $e');
      _logger.e('GetInvoiceById: Stack trace: $stackTrace');
      return Left(ServerFailure('Unexpected error occurred: $e'));
    }
  }
}
