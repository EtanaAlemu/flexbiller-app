import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import '../entities/account_payment.dart';
import '../repositories/account_payments_repository.dart';

@injectable
class GetAccountPaymentsUseCase {
  final AccountPaymentsRepository _paymentsRepository;
  final Logger _logger = Logger();

  GetAccountPaymentsUseCase(this._paymentsRepository);

  Future<List<AccountPayment>> call(String accountId) async {
    _logger.d(
      '🔍 GetAccountPaymentsUseCase: Called with accountId: $accountId',
    );
    _logger.d(
      '🔍 GetAccountPaymentsUseCase: Calling repository.getAccountPayments',
    );
    final result = await _paymentsRepository.getAccountPayments(accountId);
    _logger.d(
      '🔍 GetAccountPaymentsUseCase: Repository returned ${result.length} payments',
    );
    return result;
  }
}
