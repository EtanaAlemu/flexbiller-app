import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';

import '../../../../core/errors/failures.dart';
import '../entities/invoice.dart';
import '../repositories/invoices_repository.dart';

@injectable
class GetAccountInvoices {
  final InvoicesRepository _invoicesRepository;
  final Logger _logger;

  GetAccountInvoices(this._invoicesRepository, this._logger);

  Future<Either<Failure, List<Invoice>>> call(String accountId) async {
    try {
      _logger.d(
        'GetAccountInvoices: Starting to get invoices for account: $accountId',
      );

      final result = await _invoicesRepository.getInvoicesByAccountId(
        accountId,
      );

      return result.fold(
        (failure) {
          _logger.e(
            'GetAccountInvoices: Failed to get account invoices: ${failure.message}',
          );
          return Left(failure);
        },
        (invoices) {
          _logger.d(
            'GetAccountInvoices: Successfully retrieved ${invoices.length} invoices for account: $accountId',
          );
          return Right(invoices);
        },
      );
    } catch (e, stackTrace) {
      _logger.e('GetAccountInvoices: Unexpected error: $e');
      _logger.e('GetAccountInvoices: Stack trace: $stackTrace');
      return Left(ServerFailure('Unexpected error occurred: $e'));
    }
  }
}
