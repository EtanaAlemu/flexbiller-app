import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import '../../../../core/bloc/bloc_error_handler_mixin.dart';
import '../../domain/usecases/get_account_payment_methods_usecase.dart';
import '../../domain/usecases/set_default_payment_method_use_case.dart';
import '../../domain/usecases/refresh_payment_methods_usecase.dart';
import 'events/account_payment_methods_events.dart';
import 'states/account_payment_methods_states.dart';

@injectable
class AccountPaymentMethodsBloc
    extends Bloc<AccountPaymentMethodsEvent, AccountPaymentMethodsState>
    with BlocErrorHandlerMixin {
  final GetAccountPaymentMethodsUseCase _getAccountPaymentMethodsUseCase;
  final SetDefaultPaymentMethodUseCase _setDefaultPaymentMethodUseCase;
  final RefreshPaymentMethodsUseCase _refreshPaymentMethodsUseCase;
  final Logger _logger = Logger();

  AccountPaymentMethodsBloc({
    required GetAccountPaymentMethodsUseCase getAccountPaymentMethodsUseCase,
    required SetDefaultPaymentMethodUseCase setDefaultPaymentMethodUseCase,
    required RefreshPaymentMethodsUseCase refreshPaymentMethodsUseCase,
  }) : _getAccountPaymentMethodsUseCase = getAccountPaymentMethodsUseCase,
       _setDefaultPaymentMethodUseCase = setDefaultPaymentMethodUseCase,
       _refreshPaymentMethodsUseCase = refreshPaymentMethodsUseCase,
       super(const AccountPaymentMethodsInitial('')) {
    on<LoadAccountPaymentMethods>(_onLoadAccountPaymentMethods);
    on<RefreshAccountPaymentMethods>(_onRefreshAccountPaymentMethods);
    on<SetDefaultPaymentMethod>(_onSetDefaultPaymentMethod);
    on<CreatePaymentMethod>(_onCreatePaymentMethod);
    on<UpdatePaymentMethod>(_onUpdatePaymentMethod);
    on<DeletePaymentMethod>(_onDeletePaymentMethod);
    on<DeactivatePaymentMethod>(_onDeactivatePaymentMethod);
    on<ReactivatePaymentMethod>(_onReactivatePaymentMethod);
    on<SyncPaymentMethods>(_onSyncPaymentMethods);
    on<ClearAccountPaymentMethods>(_onClearAccountPaymentMethods);
  }

  Future<void> _onLoadAccountPaymentMethods(
    LoadAccountPaymentMethods event,
    Emitter<AccountPaymentMethodsState> emit,
  ) async {
    _logger.d(
      '🔍 AccountPaymentMethodsBloc: LoadAccountPaymentMethods called for accountId: ${event.accountId}',
    );

    emit(AccountPaymentMethodsLoading(event.accountId));

    try {
      // LOCAL-FIRST: This will return local data immediately
      final paymentMethods = await _getAccountPaymentMethodsUseCase(
        event.accountId,
      );
      _logger.d(
        '🔍 AccountPaymentMethodsBloc: LoadAccountPaymentMethods succeeded with ${paymentMethods.length} payment methods from local cache',
      );
      emit(
        AccountPaymentMethodsLoaded(
          accountId: event.accountId,
          paymentMethods: paymentMethods,
        ),
      );

      // The repository will handle background sync and emit updates via stream
      // The UI will reactively update when new data arrives
    } catch (e) {
      final message = handleException(
        e,
        context: 'load_account_payment_methods',
        metadata: {'accountId': event.accountId},
      );
      emit(
        AccountPaymentMethodsFailure(
          accountId: event.accountId,
          message: message,
        ),
      );
    }
  }

  Future<void> _onRefreshAccountPaymentMethods(
    RefreshAccountPaymentMethods event,
    Emitter<AccountPaymentMethodsState> emit,
  ) async {
    _logger.d(
      '🔍 AccountPaymentMethodsBloc: RefreshAccountPaymentMethods called for accountId: ${event.accountId}',
    );

    // Keep current state but show loading indicator
    if (state is AccountPaymentMethodsLoaded) {
      final currentState = state as AccountPaymentMethodsLoaded;
      emit(
        AccountPaymentMethodsLoaded(
          accountId: event.accountId,
          paymentMethods: currentState.paymentMethods,
        ),
      );
    } else {
      emit(AccountPaymentMethodsLoading(event.accountId));
    }

    try {
      // LOCAL-FIRST: This will return local data immediately and trigger background sync
      final paymentMethods = await _getAccountPaymentMethodsUseCase(
        event.accountId,
      );
      _logger.d(
        '🔍 AccountPaymentMethodsBloc: RefreshAccountPaymentMethods succeeded with ${paymentMethods.length} payment methods from local cache',
      );
      emit(
        AccountPaymentMethodsLoaded(
          accountId: event.accountId,
          paymentMethods: paymentMethods,
        ),
      );

      // The repository will handle background sync and emit updates via stream
      // The UI will reactively update when fresh data arrives
    } catch (e) {
      final message = handleException(
        e,
        context: 'refresh_account_payment_methods',
        metadata: {'accountId': event.accountId},
      );
      emit(
        AccountPaymentMethodsFailure(
          accountId: event.accountId,
          message: message,
        ),
      );
    }
  }

  Future<void> _onSetDefaultPaymentMethod(
    SetDefaultPaymentMethod event,
    Emitter<AccountPaymentMethodsState> emit,
  ) async {
    _logger.d(
      '🔍 AccountPaymentMethodsBloc: SetDefaultPaymentMethod called for accountId: ${event.accountId}, paymentMethodId: ${event.paymentMethodId}',
    );

    emit(
      DefaultPaymentMethodSetting(
        accountId: event.accountId,
        paymentMethodId: event.paymentMethodId,
      ),
    );

    try {
      final paymentMethod = await _setDefaultPaymentMethodUseCase(
        event.accountId,
        event.paymentMethodId,
        event.payAllUnpaidInvoices,
      );

      _logger.i(
        '🔍 AccountPaymentMethodsBloc: SetDefaultPaymentMethod succeeded',
      );
      emit(
        DefaultPaymentMethodSet(
          accountId: event.accountId,
          paymentMethod: paymentMethod,
        ),
      );

      // Reload payment methods to get updated list
      add(LoadAccountPaymentMethods(event.accountId));
    } catch (e) {
      final message = handleException(
        e,
        context: 'set_default_payment_method',
        metadata: {
          'accountId': event.accountId,
          'paymentMethodId': event.paymentMethodId,
        },
      );
      emit(
        DefaultPaymentMethodSetFailure(
          accountId: event.accountId,
          paymentMethodId: event.paymentMethodId,
          message: message,
        ),
      );
    }
  }

  Future<void> _onCreatePaymentMethod(
    CreatePaymentMethod event,
    Emitter<AccountPaymentMethodsState> emit,
  ) async {
    _logger.d(
      '🔍 AccountPaymentMethodsBloc: CreatePaymentMethod called for accountId: ${event.accountId}',
    );

    emit(PaymentMethodCreating(event.accountId));

    try {
      // Note: This would need to be implemented in the repository
      // For now, we'll just reload the payment methods
      add(LoadAccountPaymentMethods(event.accountId));
    } catch (e) {
      final message = handleException(
        e,
        context: 'create_payment_method',
        metadata: {'accountId': event.accountId},
      );
      emit(
        PaymentMethodCreationFailure(
          accountId: event.accountId,
          message: message,
        ),
      );
    }
  }

  Future<void> _onUpdatePaymentMethod(
    UpdatePaymentMethod event,
    Emitter<AccountPaymentMethodsState> emit,
  ) async {
    _logger.d(
      '🔍 AccountPaymentMethodsBloc: UpdatePaymentMethod called for accountId: ${event.accountId}, paymentMethodId: ${event.paymentMethodId}',
    );

    emit(
      PaymentMethodUpdating(
        accountId: event.accountId,
        paymentMethodId: event.paymentMethodId,
      ),
    );

    try {
      // Note: This would need to be implemented in the repository
      // For now, we'll just reload the payment methods
      add(LoadAccountPaymentMethods(event.accountId));
    } catch (e) {
      final message = handleException(
        e,
        context: 'update_payment_method',
        metadata: {
          'accountId': event.accountId,
          'paymentMethodId': event.paymentMethodId,
        },
      );
      emit(
        PaymentMethodUpdateFailure(
          accountId: event.accountId,
          paymentMethodId: event.paymentMethodId,
          message: message,
        ),
      );
    }
  }

  Future<void> _onDeletePaymentMethod(
    DeletePaymentMethod event,
    Emitter<AccountPaymentMethodsState> emit,
  ) async {
    _logger.d(
      '🔍 AccountPaymentMethodsBloc: DeletePaymentMethod called for accountId: ${event.accountId}, paymentMethodId: ${event.paymentMethodId}',
    );

    emit(
      PaymentMethodDeleting(
        accountId: event.accountId,
        paymentMethodId: event.paymentMethodId,
      ),
    );

    try {
      // Note: This would need to be implemented in the repository
      // For now, we'll just reload the payment methods
      add(LoadAccountPaymentMethods(event.accountId));
    } catch (e) {
      final message = handleException(
        e,
        context: 'delete_payment_method',
        metadata: {
          'accountId': event.accountId,
          'paymentMethodId': event.paymentMethodId,
        },
      );
      emit(
        PaymentMethodDeletionFailure(
          accountId: event.accountId,
          paymentMethodId: event.paymentMethodId,
          message: message,
        ),
      );
    }
  }

  Future<void> _onDeactivatePaymentMethod(
    DeactivatePaymentMethod event,
    Emitter<AccountPaymentMethodsState> emit,
  ) async {
    _logger.d(
      '🔍 AccountPaymentMethodsBloc: DeactivatePaymentMethod called for accountId: ${event.accountId}, paymentMethodId: ${event.paymentMethodId}',
    );

    emit(
      PaymentMethodDeactivating(
        accountId: event.accountId,
        paymentMethodId: event.paymentMethodId,
      ),
    );

    try {
      // Note: This would need to be implemented in the repository
      // For now, we'll just reload the payment methods
      add(LoadAccountPaymentMethods(event.accountId));
    } catch (e) {
      final message = handleException(
        e,
        context: 'deactivate_payment_method',
        metadata: {
          'accountId': event.accountId,
          'paymentMethodId': event.paymentMethodId,
        },
      );
      emit(
        PaymentMethodDeactivationFailure(
          accountId: event.accountId,
          paymentMethodId: event.paymentMethodId,
          message: message,
        ),
      );
    }
  }

  Future<void> _onReactivatePaymentMethod(
    ReactivatePaymentMethod event,
    Emitter<AccountPaymentMethodsState> emit,
  ) async {
    _logger.d(
      '🔍 AccountPaymentMethodsBloc: ReactivatePaymentMethod called for accountId: ${event.accountId}, paymentMethodId: ${event.paymentMethodId}',
    );

    emit(
      PaymentMethodReactivating(
        accountId: event.accountId,
        paymentMethodId: event.paymentMethodId,
      ),
    );

    try {
      // Note: This would need to be implemented in the repository
      // For now, we'll just reload the payment methods
      add(LoadAccountPaymentMethods(event.accountId));
    } catch (e) {
      final message = handleException(
        e,
        context: 'reactivate_payment_method',
        metadata: {
          'accountId': event.accountId,
          'paymentMethodId': event.paymentMethodId,
        },
      );
      emit(
        PaymentMethodReactivationFailure(
          accountId: event.accountId,
          paymentMethodId: event.paymentMethodId,
          message: message,
        ),
      );
    }
  }

  Future<void> _onSyncPaymentMethods(
    SyncPaymentMethods event,
    Emitter<AccountPaymentMethodsState> emit,
  ) async {
    _logger.d(
      '🔍 AccountPaymentMethodsBloc: SyncPaymentMethods called for accountId: ${event.accountId}',
    );

    emit(PaymentMethodsSyncing(event.accountId));

    try {
      final paymentMethods = await _refreshPaymentMethodsUseCase(
        event.accountId,
      );
      _logger.i(
        '🔍 AccountPaymentMethodsBloc: SyncPaymentMethods succeeded with ${paymentMethods.length} payment methods',
      );
      emit(
        PaymentMethodsSynced(
          accountId: event.accountId,
          paymentMethods: paymentMethods,
        ),
      );
    } catch (e) {
      final message = handleException(
        e,
        context: 'sync_payment_methods',
        metadata: {'accountId': event.accountId},
      );
      emit(
        PaymentMethodsSyncFailure(accountId: event.accountId, message: message),
      );
    }
  }

  void _onClearAccountPaymentMethods(
    ClearAccountPaymentMethods event,
    Emitter<AccountPaymentMethodsState> emit,
  ) {
    emit(AccountPaymentMethodsInitial(event.accountId));
  }
}
