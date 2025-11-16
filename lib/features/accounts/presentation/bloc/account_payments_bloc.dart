import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import '../../../../core/bloc/bloc_error_handler_mixin.dart';
import '../../domain/usecases/get_account_payments_usecase.dart';
import '../../domain/usecases/refund_account_payment_usecase.dart';
import 'events/account_payments_events.dart';
import 'states/account_payments_states.dart';

@injectable
class AccountPaymentsBloc
    extends Bloc<AccountPaymentsEvent, AccountPaymentsState>
    with BlocErrorHandlerMixin {
  final GetAccountPaymentsUseCase _getAccountPaymentsUseCase;
  final RefundAccountPaymentUseCase _refundAccountPaymentUseCase;
  final Logger _logger = Logger();

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
    _logger.d(
      '🔍 AccountPaymentsBloc: LoadAccountPayments called for accountId: ${event.accountId}',
    );

    emit(AccountPaymentsLoading(event.accountId));

    try {
      // LOCAL-FIRST: This will return local data immediately
      final payments = await _getAccountPaymentsUseCase(event.accountId);
      _logger.d(
        '🔍 AccountPaymentsBloc: LoadAccountPayments succeeded with ${payments.length} payments from local cache',
      );
      emit(
        AccountPaymentsLoaded(accountId: event.accountId, payments: payments),
      );

      // The repository will handle background sync and emit updates via stream
      // The UI will reactively update when new data arrives
    } catch (e) {
      final message = handleException(
        e,
        context: 'load_account_payments',
        metadata: {'accountId': event.accountId},
      );
      emit(
        AccountPaymentsFailure(accountId: event.accountId, message: message),
      );
    }
  }

  Future<void> _onRefreshAccountPayments(
    RefreshAccountPayments event,
    Emitter<AccountPaymentsState> emit,
  ) async {
    _logger.d(
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
      _logger.d(
        '🔍 AccountPaymentsBloc: RefreshAccountPayments succeeded with ${payments.length} payments from local cache',
      );
      emit(
        AccountPaymentsLoaded(accountId: event.accountId, payments: payments),
      );

      // The repository will handle background sync and emit updates via stream
      // The UI will reactively update when fresh data arrives
    } catch (e) {
      final message = handleException(
        e,
        context: 'refresh_account_payments',
        metadata: {'accountId': event.accountId},
      );
      emit(
        AccountPaymentsFailure(accountId: event.accountId, message: message),
      );
    }
  }

  Future<void> _onRefundAccountPayment(
    RefundAccountPayment event,
    Emitter<AccountPaymentsState> emit,
  ) async {
    _logger.d(
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

      _logger.i('🔍 AccountPaymentsBloc: RefundAccountPayment succeeded');
      emit(
        AccountPaymentRefunded(
          accountId: event.accountId,
          paymentId: event.paymentId,
        ),
      );

      // Reload payments to get updated list
      add(LoadAccountPayments(event.accountId));
    } catch (e) {
      final message = handleException(
        e,
        context: 'refund_account_payment',
        metadata: {'accountId': event.accountId, 'paymentId': event.paymentId},
      );
      emit(
        AccountPaymentRefundFailure(
          accountId: event.accountId,
          paymentId: event.paymentId,
          message: message,
        ),
      );
    }
  }

  void _onClearAccountPayments(
    ClearAccountPayments event,
    Emitter<AccountPaymentsState> emit,
  ) {
    _logger.d('🔍 AccountPaymentsBloc: ClearAccountPayments called');
    emit(const AccountPaymentsInitial());
  }
}
