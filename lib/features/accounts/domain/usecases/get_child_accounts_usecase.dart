import 'package:injectable/injectable.dart';
import '../entities/child_account.dart';
import '../repositories/child_account_repository.dart';

@injectable
class GetChildAccountsUseCase {
  final ChildAccountRepository _childAccountRepository;

  GetChildAccountsUseCase(this._childAccountRepository);

  Future<List<ChildAccount>> call(String parentAccountId) async {
    return await _childAccountRepository.getChildAccounts(parentAccountId);
  }
}
