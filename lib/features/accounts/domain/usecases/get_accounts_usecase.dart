import 'package:injectable/injectable.dart';
import '../entities/account.dart';
import '../entities/accounts_query_params.dart';
import '../repositories/accounts_repository.dart';

@injectable
class GetAccountsUseCase {
  final AccountsRepository _accountsRepository;

  GetAccountsUseCase(this._accountsRepository);

  Future<List<Account>> call(AccountsQueryParams params) async {
    return await _accountsRepository.getAccounts(params);
  }
}
