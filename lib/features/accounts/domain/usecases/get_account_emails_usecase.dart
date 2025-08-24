import 'package:injectable/injectable.dart';
import '../entities/account_email.dart';
import '../repositories/account_emails_repository.dart';

@injectable
class GetAccountEmailsUseCase {
  final AccountEmailsRepository _emailsRepository;

  GetAccountEmailsUseCase(this._emailsRepository);

  Future<List<AccountEmail>> call(String accountId) async {
    return await _emailsRepository.getAccountEmails(accountId);
  }
}
