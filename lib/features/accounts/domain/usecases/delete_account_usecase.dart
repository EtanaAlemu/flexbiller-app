import 'package:injectable/injectable.dart';
import '../../domain/repositories/accounts_repository.dart';

@injectable
class DeleteAccountUseCase {
  final AccountsRepository _accountsRepository;

  DeleteAccountUseCase(this._accountsRepository);

  Future<void> call(String accountId) async {
    return await _accountsRepository.deleteAccount(accountId);
  }
}
