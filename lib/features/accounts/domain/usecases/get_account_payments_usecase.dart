import 'package:injectable/injectable.dart';
import '../entities/account_payment.dart';
import '../repositories/account_payments_repository.dart';

@injectable
class GetAccountPaymentsUseCase {
  final AccountPaymentsRepository _paymentsRepository;

  GetAccountPaymentsUseCase(this._paymentsRepository);

  Future<List<AccountPayment>> call(String accountId) async {
    return await _paymentsRepository.getAccountPayments(accountId);
  }
}
