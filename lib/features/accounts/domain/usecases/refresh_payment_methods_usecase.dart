import 'package:injectable/injectable.dart';
import '../entities/account_payment_method.dart';
import '../repositories/account_payment_methods_repository.dart';

@injectable
class RefreshPaymentMethodsUseCase {
  final AccountPaymentMethodsRepository _paymentMethodsRepository;

  RefreshPaymentMethodsUseCase(this._paymentMethodsRepository);

  Future<List<AccountPaymentMethod>> call(String accountId) async {
    return await _paymentMethodsRepository.refreshPaymentMethods(accountId);
  }
}
