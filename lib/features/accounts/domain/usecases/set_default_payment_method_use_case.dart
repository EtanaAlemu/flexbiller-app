import 'package:injectable/injectable.dart';
import '../entities/account_payment_method.dart';
import '../repositories/account_payment_methods_repository.dart';

@injectable
class SetDefaultPaymentMethodUseCase {
  final AccountPaymentMethodsRepository _paymentMethodsRepository;

  SetDefaultPaymentMethodUseCase(this._paymentMethodsRepository);

  Future<AccountPaymentMethod> call(
    String accountId,
    String paymentMethodId,
    bool payAllUnpaidInvoices,
  ) async {
    return await _paymentMethodsRepository.setDefaultPaymentMethod(
      accountId,
      paymentMethodId,
      payAllUnpaidInvoices,
    );
  }
}
