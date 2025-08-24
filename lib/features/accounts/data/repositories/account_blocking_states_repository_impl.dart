import 'package:injectable/injectable.dart';
import '../../domain/entities/account_blocking_state.dart';
import '../../domain/repositories/account_blocking_states_repository.dart';
import '../datasources/account_blocking_states_remote_data_source.dart';

@Injectable(as: AccountBlockingStatesRepository)
class AccountBlockingStatesRepositoryImpl implements AccountBlockingStatesRepository {
  final AccountBlockingStatesRemoteDataSource _remoteDataSource;

  AccountBlockingStatesRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<AccountBlockingState>> getAccountBlockingStates(String accountId) async {
    try {
      final blockingStateModels = await _remoteDataSource.getAccountBlockingStates(accountId);
      return blockingStateModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<AccountBlockingState> getAccountBlockingState(String accountId, String stateId) async {
    try {
      final blockingStateModel = await _remoteDataSource.getAccountBlockingState(accountId, stateId);
      return blockingStateModel.toEntity();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<AccountBlockingState> createAccountBlockingState(
    String accountId,
    String stateName,
    String service,
    bool isBlockChange,
    bool isBlockEntitlement,
    bool isBlockBilling,
    DateTime effectiveDate,
  ) async {
    try {
      final blockingStateModel = await _remoteDataSource.createAccountBlockingState(
        accountId,
        stateName,
        service,
        isBlockChange,
        isBlockEntitlement,
        isBlockBilling,
        effectiveDate,
      );
      return blockingStateModel.toEntity();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<AccountBlockingState> updateAccountBlockingState(
    String accountId,
    String stateId,
    String stateName,
    String service,
    bool isBlockChange,
    bool isBlockEntitlement,
    bool isBlockBilling,
    DateTime effectiveDate,
  ) async {
    try {
      final blockingStateModel = await _remoteDataSource.updateAccountBlockingState(
        accountId,
        stateId,
        stateName,
        service,
        isBlockChange,
        isBlockEntitlement,
        isBlockBilling,
        effectiveDate,
      );
      return blockingStateModel.toEntity();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteAccountBlockingState(String accountId, String stateId) async {
    try {
      await _remoteDataSource.deleteAccountBlockingState(accountId, stateId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<AccountBlockingState>> getBlockingStatesByService(String accountId, String service) async {
    try {
      final blockingStateModels = await _remoteDataSource.getBlockingStatesByService(accountId, service);
      return blockingStateModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<AccountBlockingState>> getActiveBlockingStates(String accountId) async {
    try {
      final blockingStateModels = await _remoteDataSource.getActiveBlockingStates(accountId);
      return blockingStateModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      rethrow;
    }
  }
}
