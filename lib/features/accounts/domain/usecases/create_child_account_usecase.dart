import 'package:injectable/injectable.dart';
import '../entities/child_account.dart';
import '../repositories/child_account_repository.dart';

@injectable
class CreateChildAccountUseCase {
  final ChildAccountRepository _childAccountRepository;

  CreateChildAccountUseCase(this._childAccountRepository);

  Future<ChildAccount> call({
    required String name,
    required String email,
    required String currency,
    required bool isPaymentDelegatedToParent,
    required String parentAccountId,
  }) async {
    final childAccount = ChildAccount(
      name: name,
      email: email,
      currency: currency,
      isPaymentDelegatedToParent: isPaymentDelegatedToParent,
      parentAccountId: parentAccountId,
    );

    return await _childAccountRepository.createChildAccount(childAccount);
  }
}
