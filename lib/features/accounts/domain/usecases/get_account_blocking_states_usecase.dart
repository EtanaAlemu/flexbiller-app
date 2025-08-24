import 'package:injectable/injectable.dart';
import '../entities/account_blocking_state.dart';
import '../repositories/account_blocking_states_repository.dart';

@injectable
class GetAccountBlockingStatesUseCase {
  final AccountBlockingStatesRepository _blockingStatesRepository;

  GetAccountBlockingStatesUseCase(this._blockingStatesRepository);

  Future<List<AccountBlockingState>> call(String accountId) async {
    return await _blockingStatesRepository.getAccountBlockingStates(accountId);
  }
}
