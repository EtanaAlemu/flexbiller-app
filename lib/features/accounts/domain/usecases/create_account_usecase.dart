import 'package:injectable/injectable.dart';
import '../../domain/entities/account.dart';
import '../../domain/repositories/accounts_repository.dart';

@injectable
class CreateAccountUseCase {
  final AccountsRepository _accountsRepository;

  CreateAccountUseCase(this._accountsRepository);

  Future<Account> call(Account account) async {
    return await _accountsRepository.createAccount(account);
  }
}
