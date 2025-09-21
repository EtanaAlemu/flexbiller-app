import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/usecases/get_account_payment_methods_usecase.dart';
import '../../domain/usecases/set_default_payment_method_use_case.dart';
import '../../domain/usecases/refresh_payment_methods_usecase.dart';
import 'account_payment_methods_events.dart';
import 'account_payment_methods_states.dart';

@injectable
class AccountPaymentMethodsBloc
    extends Bloc<AccountPaymentMethodsEvent, AccountPaymentMethodsState> {
  final GetAccountPaymentMethodsUseCase _getAccountPaymentMethodsUseCase;
  final SetDefaultPaymentMethodUseCase _setDefaultPaymentMethodUseCase;
  final RefreshPaymentMethodsUseCase _refreshPaymentMethodsUseCase;

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
    print(
      '🔍 AccountPaymentMethodsBloc: LoadAccountPaymentMethods called for accountId: ${event.accountId}',
    );

    emit(AccountPaymentMethodsLoading(event.accountId));

    try {
      // LOCAL-FIRST: This will return local data immediately
      final paymentMethods = await _getAccountPaymentMethodsUseCase(
        event.accountId,
      );
      print(
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
      print(
        '🔍 AccountPaymentMethodsBloc: LoadAccountPaymentMethods exception: $e',
      );
      emit(
        AccountPaymentMethodsFailure(
          accountId: event.accountId,
          message: 'An unexpected error occurred: $e',
        ),
      );
    }
  }

  Future<void> _onRefreshAccountPaymentMethods(
    RefreshAccountPaymentMethods event,
    Emitter<AccountPaymentMethodsState> emit,
  ) async {
    print(
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
      print(
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
      print(
        '🔍 AccountPaymentMethodsBloc: RefreshAccountPaymentMethods exception: $e',
      );
      emit(
        AccountPaymentMethodsFailure(
          accountId: event.accountId,
          message: 'An unexpected error occurred: $e',
        ),
      );
    }
  }

  Future<void> _onSetDefaultPaymentMethod(
    SetDefaultPaymentMethod event,
    Emitter<AccountPaymentMethodsState> emit,
  ) async {
    print(
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

      print('🔍 AccountPaymentMethodsBloc: SetDefaultPaymentMethod succeeded');
      emit(
        DefaultPaymentMethodSet(
          accountId: event.accountId,
          paymentMethod: paymentMethod,
        ),
      );

      // Reload payment methods to get updated list
      add(LoadAccountPaymentMethods(event.accountId));
    } catch (e) {
      print(
        '🔍 AccountPaymentMethodsBloc: SetDefaultPaymentMethod exception: $e',
      );
      emit(
        DefaultPaymentMethodSetFailure(
          accountId: event.accountId,
          paymentMethodId: event.paymentMethodId,
          message: 'An unexpected error occurred: $e',
        ),
      );
    }
  }

  Future<void> _onCreatePaymentMethod(
    CreatePaymentMethod event,
    Emitter<AccountPaymentMethodsState> emit,
  ) async {
    print(
      '🔍 AccountPaymentMethodsBloc: CreatePaymentMethod called for accountId: ${event.accountId}',
    );

    emit(PaymentMethodCreating(event.accountId));

    try {
      // Note: This would need to be implemented in the repository
      // For now, we'll just reload the payment methods
      add(LoadAccountPaymentMethods(event.accountId));
    } catch (e) {
      print('🔍 AccountPaymentMethodsBloc: CreatePaymentMethod exception: $e');
      emit(
        PaymentMethodCreationFailure(
          accountId: event.accountId,
          message: 'An unexpected error occurred: $e',
        ),
      );
    }
  }

  Future<void> _onUpdatePaymentMethod(
    UpdatePaymentMethod event,
    Emitter<AccountPaymentMethodsState> emit,
  ) async {
    print(
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
      print('🔍 AccountPaymentMethodsBloc: UpdatePaymentMethod exception: $e');
      emit(
        PaymentMethodUpdateFailure(
          accountId: event.accountId,
          paymentMethodId: event.paymentMethodId,
          message: 'An unexpected error occurred: $e',
        ),
      );
    }
  }

  Future<void> _onDeletePaymentMethod(
    DeletePaymentMethod event,
    Emitter<AccountPaymentMethodsState> emit,
  ) async {
    print(
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
      print('🔍 AccountPaymentMethodsBloc: DeletePaymentMethod exception: $e');
      emit(
        PaymentMethodDeletionFailure(
          accountId: event.accountId,
          paymentMethodId: event.paymentMethodId,
          message: 'An unexpected error occurred: $e',
        ),
      );
    }
  }

  Future<void> _onDeactivatePaymentMethod(
    DeactivatePaymentMethod event,
    Emitter<AccountPaymentMethodsState> emit,
  ) async {
    print(
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
      print(
        '🔍 AccountPaymentMethodsBloc: DeactivatePaymentMethod exception: $e',
      );
      emit(
        PaymentMethodDeactivationFailure(
          accountId: event.accountId,
          paymentMethodId: event.paymentMethodId,
          message: 'An unexpected error occurred: $e',
        ),
      );
    }
  }

  Future<void> _onReactivatePaymentMethod(
    ReactivatePaymentMethod event,
    Emitter<AccountPaymentMethodsState> emit,
  ) async {
    print(
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
      print(
        '🔍 AccountPaymentMethodsBloc: ReactivatePaymentMethod exception: $e',
      );
      emit(
        PaymentMethodReactivationFailure(
          accountId: event.accountId,
          paymentMethodId: event.paymentMethodId,
          message: 'An unexpected error occurred: $e',
        ),
      );
    }
  }

  Future<void> _onSyncPaymentMethods(
    SyncPaymentMethods event,
    Emitter<AccountPaymentMethodsState> emit,
  ) async {
    print(
      '🔍 AccountPaymentMethodsBloc: SyncPaymentMethods called for accountId: ${event.accountId}',
    );

    emit(PaymentMethodsSyncing(event.accountId));

    try {
      final paymentMethods = await _refreshPaymentMethodsUseCase(
        event.accountId,
      );
      print(
        '🔍 AccountPaymentMethodsBloc: SyncPaymentMethods succeeded with ${paymentMethods.length} payment methods',
      );
      emit(
        PaymentMethodsSynced(
          accountId: event.accountId,
          paymentMethods: paymentMethods,
        ),
      );
    } catch (e) {
      print('🔍 AccountPaymentMethodsBloc: SyncPaymentMethods exception: $e');
      emit(
        PaymentMethodsSyncFailure(
          accountId: event.accountId,
          message: 'An unexpected error occurred: $e',
        ),
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
