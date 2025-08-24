import 'package:injectable/injectable.dart';
import '../entities/account.dart';
import '../repositories/accounts_repository.dart';

@injectable
class SearchAccountsUseCase {
  final AccountsRepository _accountsRepository;

  SearchAccountsUseCase(this._accountsRepository);

  Future<List<Account>> call(String searchKey) async {
    return await _accountsRepository.searchAccounts(searchKey);
  }
}
