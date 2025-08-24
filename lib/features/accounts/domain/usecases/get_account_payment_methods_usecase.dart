import 'package:injectable/injectable.dart';
import '../entities/account_payment_method.dart';
import '../repositories/account_payment_methods_repository.dart';

@injectable
class GetAccountPaymentMethodsUseCase {
  final AccountPaymentMethodsRepository _paymentMethodsRepository;

  GetAccountPaymentMethodsUseCase(this._paymentMethodsRepository);

  Future<List<AccountPaymentMethod>> call(String accountId) async {
    return await _paymentMethodsRepository.getAccountPaymentMethods(accountId);
  }
}
