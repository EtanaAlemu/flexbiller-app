import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../subscriptions/domain/usecases/get_subscriptions_for_account_usecase.dart';
import 'events/account_subscriptions_event.dart';
import 'states/account_subscriptions_state.dart';
import 'package:logger/logger.dart';

@injectable
class AccountSubscriptionsBloc
    extends Bloc<AccountSubscriptionsEvent, AccountSubscriptionsState> {
  final GetSubscriptionsForAccountUseCase _getSubscriptionsForAccountUseCase;
  final Logger _logger = Logger();

  AccountSubscriptionsBloc({
    required GetSubscriptionsForAccountUseCase
    getSubscriptionsForAccountUseCase,
  }) : _getSubscriptionsForAccountUseCase = getSubscriptionsForAccountUseCase,
       super(AccountSubscriptionsInitial()) {
    on<LoadAccountSubscriptions>(_onLoadAccountSubscriptions);
    on<RefreshAccountSubscriptions>(_onRefreshAccountSubscriptions);
  }

  Future<void> _onLoadAccountSubscriptions(
    LoadAccountSubscriptions event,
    Emitter<AccountSubscriptionsState> emit,
  ) async {
    try {
      _logger.d(
        '🔍 _onLoadAccountSubscriptions called for account: ${event.accountId}',
      );
      emit(AccountSubscriptionsLoading(accountId: event.accountId));
      _logger.d('🔍 Emitted AccountSubscriptionsLoading state');

      _logger.d('🔍 About to call _getSubscriptionsForAccountUseCase');
      final subscriptions = await _getSubscriptionsForAccountUseCase(
        event.accountId,
      );
      _logger.d('🔍 Got ${subscriptions.length} subscriptions from use case');

      final loadedState = AccountSubscriptionsLoaded(
        accountId: event.accountId,
        subscriptions: subscriptions,
      );
      _logger.d(
        '🔍 About to emit AccountSubscriptionsLoaded state with ${subscriptions.length} subscriptions',
      );
      _logger.d(
        '🔍 State details: accountId=${loadedState.accountId}, subscriptions=${loadedState.subscriptions}',
      );
      emit(loadedState);
      _logger.d(
        '🔍 Successfully emitted AccountSubscriptionsLoaded state with ${subscriptions.length} subscriptions',
      );
      _logger.d('🔍 Bloc instance emitting state: ${this.hashCode}');
      _logger.d('🔍 State hashCode: ${loadedState.hashCode}');
      _logger.d('🔍 State props: ${loadedState.props}');
    } catch (e) {
      _logger.e('🔍 Error in _onLoadAccountSubscriptions: $e');
      emit(
        AccountSubscriptionsFailure(
          message: e.toString(),
          accountId: event.accountId,
        ),
      );
    }
  }

  Future<void> _onRefreshAccountSubscriptions(
    RefreshAccountSubscriptions event,
    Emitter<AccountSubscriptionsState> emit,
  ) async {
    try {
      final currentState = state;
      if (currentState is AccountSubscriptionsLoaded) {
        emit(
          AccountSubscriptionsRefreshing(
            accountId: event.accountId,
            subscriptions: currentState.subscriptions,
          ),
        );
      } else {
        emit(AccountSubscriptionsLoading(accountId: event.accountId));
      }

      final subscriptions = await _getSubscriptionsForAccountUseCase(
        event.accountId,
      );
      emit(
        AccountSubscriptionsLoaded(
          accountId: event.accountId,
          subscriptions: subscriptions,
        ),
      );
    } catch (e) {
      emit(
        AccountSubscriptionsFailure(
          message: e.toString(),
          accountId: event.accountId,
        ),
      );
    }
  }
}
