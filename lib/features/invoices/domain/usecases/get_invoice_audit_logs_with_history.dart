import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';

import '../../../../core/errors/failures.dart';
import '../entities/invoice_audit_log.dart';
import '../repositories/invoices_repository.dart';

@injectable
class GetInvoiceAuditLogsWithHistory {
  final InvoicesRepository _invoicesRepository;
  final Logger _logger;

  GetInvoiceAuditLogsWithHistory(this._invoicesRepository, this._logger);

  Future<Either<Failure, List<InvoiceAuditLog>>> call(String invoiceId) async {
    try {
      _logger.d(
        'GetInvoiceAuditLogsWithHistory: Starting to get audit logs for invoice: $invoiceId',
      );

      final result = await _invoicesRepository.getInvoiceAuditLogsWithHistory(invoiceId);

      return result.fold(
        (failure) {
          _logger.e(
            'GetInvoiceAuditLogsWithHistory: Failed to get audit logs: ${failure.message}',
          );
          return Left(failure);
        },
        (auditLogs) {
          _logger.d(
            'GetInvoiceAuditLogsWithHistory: Successfully retrieved ${auditLogs.length} audit logs for invoice: $invoiceId',
          );
          return Right(auditLogs);
        },
      );
    } catch (e, stackTrace) {
      _logger.e('GetInvoiceAuditLogsWithHistory: Unexpected error: $e');
      _logger.e('GetInvoiceAuditLogsWithHistory: Stack trace: $stackTrace');
      return Left(ServerFailure('Unexpected error occurred: $e'));
    }
  }
}
