import 'package:injectable/injectable.dart';
import '../entities/account_overdue_state.dart';
import '../repositories/account_overdue_state_repository.dart';

@injectable
class GetOverdueStateUseCase {
  final AccountOverdueStateRepository _overdueStateRepository;

  GetOverdueStateUseCase(this._overdueStateRepository);

  Future<AccountOverdueState> call(String accountId) async {
    return await _overdueStateRepository.getOverdueState(accountId);
  }
}
