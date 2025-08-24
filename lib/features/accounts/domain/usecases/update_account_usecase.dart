import 'package:injectable/injectable.dart';
import '../../domain/entities/account.dart';
import '../../domain/repositories/accounts_repository.dart';

@injectable
class UpdateAccountUseCase {
  final AccountsRepository _accountsRepository;

  UpdateAccountUseCase(this._accountsRepository);

  Future<Account> call(Account account) async {
    return await _accountsRepository.updateAccount(account);
  }
}
