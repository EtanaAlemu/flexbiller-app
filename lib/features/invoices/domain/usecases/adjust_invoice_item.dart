import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/invoices_repository.dart';

@injectable
class AdjustInvoiceItem {
  final InvoicesRepository _invoicesRepository;
  final Logger _logger;

  AdjustInvoiceItem(this._invoicesRepository, this._logger);

  Future<Either<Failure, void>> call({
    required String invoiceId,
    required String invoiceItemId,
    required String accountId,
    required double amount,
    required String currency,
    required String description,
  }) async {
    try {
      _logger.d(
        'AdjustInvoiceItem: Starting to adjust invoice item: $invoiceItemId for invoice: $invoiceId',
      );

      final result = await _invoicesRepository.adjustInvoiceItem(
        invoiceId,
        invoiceItemId,
        accountId,
        amount,
        currency,
        description,
      );

      return result.fold(
        (failure) {
          _logger.e(
            'AdjustInvoiceItem: Failed to adjust invoice item: ${failure.message}',
          );
          return Left(failure);
        },
        (_) {
          _logger.d(
            'AdjustInvoiceItem: Successfully adjusted invoice item: $invoiceItemId',
          );
          return const Right(null);
        },
      );
    } catch (e, stackTrace) {
      _logger.e('AdjustInvoiceItem: Unexpected error: $e');
      _logger.e('AdjustInvoiceItem: Stack trace: $stackTrace');
      return Left(ServerFailure('Unexpected error occurred: $e'));
    }
  }
}
