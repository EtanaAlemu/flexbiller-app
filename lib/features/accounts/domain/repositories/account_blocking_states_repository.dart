import 'dart:async';
import '../entities/account_blocking_state.dart';

abstract class AccountBlockingStatesRepository {
  /// Stream for reactive UI updates of all blocking states
  Stream<List<AccountBlockingState>> get blockingStatesStream;

  /// Stream for reactive UI updates of active blocking states
  Stream<List<AccountBlockingState>> get activeBlockingStatesStream;

  /// Get all blocking states for a specific account
  Future<List<AccountBlockingState>> getAccountBlockingStates(String accountId);

  /// Get a specific blocking state by ID
  Future<AccountBlockingState> getAccountBlockingState(
    String accountId,
    String stateId,
  );

  /// Create a new blocking state for an account
  Future<AccountBlockingState> createAccountBlockingState(
    String accountId,
    String stateName,
    String service,
    bool isBlockChange,
    bool isBlockEntitlement,
    bool isBlockBilling,
    DateTime effectiveDate,
    String type,
  );

  /// Update an existing blocking state
  Future<AccountBlockingState> updateAccountBlockingState(
    String accountId,
    String stateId,
    String stateName,
    String service,
    bool isBlockChange,
    bool isBlockEntitlement,
    bool isBlockBilling,
    DateTime effectiveDate,
  );

  /// Delete a blocking state from an account
  Future<void> deleteAccountBlockingState(String accountId, String stateId);

  /// Get blocking states by service
  Future<List<AccountBlockingState>> getBlockingStatesByService(
    String accountId,
    String service,
  );

  /// Get active blocking states (effective date in the past or present)
  Future<List<AccountBlockingState>> getActiveBlockingStates(String accountId);
}
