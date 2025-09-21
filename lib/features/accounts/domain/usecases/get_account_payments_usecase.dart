import 'package:injectable/injectable.dart';
import '../entities/account_payment.dart';
import '../repositories/account_payments_repository.dart';

@injectable
class GetAccountPaymentsUseCase {
  final AccountPaymentsRepository _paymentsRepository;

  GetAccountPaymentsUseCase(this._paymentsRepository);

  Future<List<AccountPayment>> call(String accountId) async {
    print('🔍 GetAccountPaymentsUseCase: Called with accountId: $accountId');
    print(
      '🔍 GetAccountPaymentsUseCase: Calling repository.getAccountPayments',
    );
    final result = await _paymentsRepository.getAccountPayments(accountId);
    print(
      '🔍 GetAccountPaymentsUseCase: Repository returned ${result.length} payments',
    );
    return result;
  }
}
