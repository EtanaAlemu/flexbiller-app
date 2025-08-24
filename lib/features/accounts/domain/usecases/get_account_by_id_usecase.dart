import 'package:injectable/injectable.dart';
import '../entities/account.dart';
import '../repositories/accounts_repository.dart';

@injectable
class GetAccountByIdUseCase {
  final AccountsRepository _accountsRepository;

  GetAccountByIdUseCase(this._accountsRepository);

  Future<Account> call(String accountId) async {
    return await _accountsRepository.getAccountById(accountId);
  }
}
