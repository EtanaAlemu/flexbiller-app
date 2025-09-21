import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/usecases/get_account_payments_usecase.dart';
import '../../domain/usecases/refund_account_payment_usecase.dart';
import 'account_payments_events.dart';
import 'account_payments_states.dart';

@injectable
class AccountPaymentsBloc
    extends Bloc<AccountPaymentsEvent, AccountPaymentsState> {
  final GetAccountPaymentsUseCase _getAccountPaymentsUseCase;
  final RefundAccountPaymentUseCase _refundAccountPaymentUseCase;

  AccountPaymentsBloc({
    required GetAccountPaymentsUseCase getAccountPaymentsUseCase,
    required RefundAccountPaymentUseCase refundAccountPaymentUseCase,
  }) : _getAccountPaymentsUseCase = getAccountPaymentsUseCase,
       _refundAccountPaymentUseCase = refundAccountPaymentUseCase,
       super(const AccountPaymentsInitial()) {
    on<LoadAccountPayments>(_onLoadAccountPayments);
    on<RefreshAccountPayments>(_onRefreshAccountPayments);
    on<RefundAccountPayment>(_onRefundAccountPayment);
    on<ClearAccountPayments>(_onClearAccountPayments);
  }

  Future<void> _onLoadAccountPayments(
    LoadAccountPayments event,
    Emitter<AccountPaymentsState> emit,
  ) async {
    print(
      '🔍 AccountPaymentsBloc: LoadAccountPayments called for accountId: ${event.accountId}',
    );

    emit(AccountPaymentsLoading(event.accountId));

    try {
      // LOCAL-FIRST: This will return local data immediately
      final payments = await _getAccountPaymentsUseCase(event.accountId);
      print(
        '🔍 AccountPaymentsBloc: LoadAccountPayments succeeded with ${payments.length} payments from local cache',
      );
      emit(
        AccountPaymentsLoaded(accountId: event.accountId, payments: payments),
      );

      // The repository will handle background sync and emit updates via stream
      // The UI will reactively update when new data arrives
    } catch (e) {
      print('🔍 AccountPaymentsBloc: LoadAccountPayments exception: $e');
      emit(
        AccountPaymentsFailure(
          accountId: event.accountId,
          message: 'An unexpected error occurred: $e',
        ),
      );
    }
  }

  Future<void> _onRefreshAccountPayments(
    RefreshAccountPayments event,
    Emitter<AccountPaymentsState> emit,
  ) async {
    print(
      '🔍 AccountPaymentsBloc: RefreshAccountPayments called for accountId: ${event.accountId}',
    );

    // Keep current state but show loading indicator
    if (state is AccountPaymentsLoaded) {
      final currentState = state as AccountPaymentsLoaded;
      emit(
        AccountPaymentsLoaded(
          accountId: event.accountId,
          payments: currentState.payments,
        ),
      );
    } else {
      emit(AccountPaymentsLoading(event.accountId));
    }

    try {
      // LOCAL-FIRST: This will return local data immediately and trigger background sync
      final payments = await _getAccountPaymentsUseCase(event.accountId);
      print(
        '🔍 AccountPaymentsBloc: RefreshAccountPayments succeeded with ${payments.length} payments from local cache',
      );
      emit(
        AccountPaymentsLoaded(accountId: event.accountId, payments: payments),
      );

      // The repository will handle background sync and emit updates via stream
      // The UI will reactively update when fresh data arrives
    } catch (e) {
      print('🔍 AccountPaymentsBloc: RefreshAccountPayments exception: $e');
      emit(
        AccountPaymentsFailure(
          accountId: event.accountId,
          message: 'An unexpected error occurred: $e',
        ),
      );
    }
  }

  Future<void> _onRefundAccountPayment(
    RefundAccountPayment event,
    Emitter<AccountPaymentsState> emit,
  ) async {
    print(
      '🔍 AccountPaymentsBloc: RefundAccountPayment called for accountId: ${event.accountId}, paymentId: ${event.paymentId}',
    );

    emit(
      AccountPaymentRefunding(
        accountId: event.accountId,
        paymentId: event.paymentId,
      ),
    );

    try {
      await _refundAccountPaymentUseCase(
        accountId: event.accountId,
        paymentId: event.paymentId,
        refundAmount: event.refundAmount,
        reason: event.reason,
      );

      print('🔍 AccountPaymentsBloc: RefundAccountPayment succeeded');
      emit(
        AccountPaymentRefunded(
          accountId: event.accountId,
          paymentId: event.paymentId,
        ),
      );

      // Reload payments to get updated list
      add(LoadAccountPayments(event.accountId));
    } catch (e) {
      print('🔍 AccountPaymentsBloc: RefundAccountPayment exception: $e');
      emit(
        AccountPaymentRefundFailure(
          accountId: event.accountId,
          paymentId: event.paymentId,
          message: 'An unexpected error occurred: $e',
        ),
      );
    }
  }

  void _onClearAccountPayments(
    ClearAccountPayments event,
    Emitter<AccountPaymentsState> emit,
  ) {
    print('🔍 AccountPaymentsBloc: ClearAccountPayments called');
    emit(const AccountPaymentsInitial());
  }
}
