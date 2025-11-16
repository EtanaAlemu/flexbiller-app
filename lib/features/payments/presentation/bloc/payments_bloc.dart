import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';

import '../../../../core/bloc/bloc_error_handler_mixin.dart';
import '../../domain/entities/payment.dart';
import '../../domain/usecases/get_payments.dart';
import '../../domain/usecases/get_payment_by_id.dart';
import '../../domain/usecases/get_payments_by_account_id.dart';
import '../../domain/usecases/search_payments.dart';

part 'events/payments_event.dart';
part 'states/payments_state.dart';

@injectable
class PaymentsBloc extends Bloc<PaymentsEvent, PaymentsState>
    with BlocErrorHandlerMixin {
  final GetPayments _getPayments;
  final GetPaymentById _getPaymentById;
  final GetPaymentsByAccountId _getPaymentsByAccountId;
  final SearchPayments _searchPayments;
  final Logger _logger;

  PaymentsBloc({
    required GetPayments getPayments,
    required GetPaymentById getPaymentById,
    required GetPaymentsByAccountId getPaymentsByAccountId,
    required SearchPayments searchPayments,
    required Logger logger,
  }) : _getPayments = getPayments,
       _getPaymentById = getPaymentById,
       _getPaymentsByAccountId = getPaymentsByAccountId,
       _searchPayments = searchPayments,
       _logger = logger,
       super(PaymentsInitial()) {
    _logger.d('PaymentsBloc initialized');
    on<GetPaymentsEvent>(_onGetPayments);
    on<GetPaymentByIdEvent>(_onGetPaymentById);
    on<GetPaymentsByAccountIdEvent>(_onGetPaymentsByAccountId);
    on<RefreshPaymentsEvent>(_onRefreshPayments);
    on<SearchPaymentsEvent>(_onSearchPayments);
  }

  Future<void> _onGetPayments(
    GetPaymentsEvent event,
    Emitter<PaymentsState> emit,
  ) async {
    try {
      _logger.d('PaymentsBloc: Starting GetPaymentsEvent');
      emit(PaymentsLoading());
      _logger.d('PaymentsBloc: Emitted PaymentsLoading state');

      _logger.d('PaymentsBloc: Calling _getPayments use case');
      final result = await _getPayments();
      _logger.d('PaymentsBloc: Received result from _getPayments');

      final payments = handleEitherResult(
        result,
        context: 'get_payments',
        onError: (message) {
          emit(PaymentsError(message));
        },
      );

      if (payments != null) {
        _logger.d(
          'PaymentsBloc: GetPayments successful, received ${payments.length} payments',
        );
        emit(PaymentsLoaded(payments));
      }
    } catch (e) {
      final message = handleException(e, context: 'get_payments');
      emit(PaymentsError(message));
    }
  }

  Future<void> _onGetPaymentById(
    GetPaymentByIdEvent event,
    Emitter<PaymentsState> emit,
  ) async {
    try {
      _logger.d(
        'PaymentsBloc: Starting GetPaymentByIdEvent for payment: ${event.paymentId}',
      );
      emit(PaymentLoading());
      _logger.d('PaymentsBloc: Emitted PaymentLoading state');

      _logger.d('PaymentsBloc: Calling _getPaymentById use case');
      final result = await _getPaymentById(event.paymentId);
      _logger.d('PaymentsBloc: Received result from _getPaymentById');

      final payment = handleEitherResult(
        result,
        context: 'get_payment_by_id',
        onError: (message) {
          emit(PaymentError(message));
        },
      );

      if (payment != null) {
        _logger.d(
          'PaymentsBloc: GetPaymentById successful, received payment: ${payment.paymentId}',
        );
        emit(PaymentLoaded(payment));
      }
    } catch (e) {
      final message = handleException(
        e,
        context: 'get_payment_by_id',
        metadata: {'paymentId': event.paymentId},
      );
      emit(PaymentError(message));
    }
  }

  Future<void> _onGetPaymentsByAccountId(
    GetPaymentsByAccountIdEvent event,
    Emitter<PaymentsState> emit,
  ) async {
    try {
      _logger.d(
        'PaymentsBloc: Starting GetPaymentsByAccountIdEvent for account: ${event.accountId}',
      );
      emit(PaymentsLoading());
      _logger.d('PaymentsBloc: Emitted PaymentsLoading state');

      _logger.d('PaymentsBloc: Calling _getPaymentsByAccountId use case');
      final result = await _getPaymentsByAccountId(event.accountId);
      _logger.d('PaymentsBloc: Received result from _getPaymentsByAccountId');

      final payments = handleEitherResult(
        result,
        context: 'get_payments_by_account_id',
        onError: (message) {
          emit(PaymentsError(message));
        },
      );

      if (payments != null) {
        _logger.d(
          'PaymentsBloc: GetPaymentsByAccountId successful, received ${payments.length} payments',
        );
        emit(PaymentsLoaded(payments));
      }
    } catch (e) {
      final message = handleException(
        e,
        context: 'get_payments_by_account_id',
        metadata: {'accountId': event.accountId},
      );
      emit(PaymentsError(message));
    }
  }

  Future<void> _onRefreshPayments(
    RefreshPaymentsEvent event,
    Emitter<PaymentsState> emit,
  ) async {
    try {
      _logger.d('PaymentsBloc: Starting RefreshPaymentsEvent');

      if (state is PaymentsLoaded) {
        final currentPayments = (state as PaymentsLoaded).payments;
        _logger.d(
          'PaymentsBloc: Emitting PaymentsRefreshing with ${currentPayments.length} payments',
        );
        emit(PaymentsRefreshing(currentPayments));
      } else {
        _logger.d('PaymentsBloc: Emitting PaymentsLoading for refresh');
        emit(PaymentsLoading());
      }

      _logger.d('PaymentsBloc: Calling _getPayments use case for refresh');
      final result = await _getPayments();
      _logger.d('PaymentsBloc: Received result from _getPayments for refresh');

      final payments = handleEitherResult(
        result,
        context: 'refresh_payments',
        onError: (message) {
          emit(PaymentsError(message));
        },
      );

      if (payments != null) {
        _logger.d(
          'PaymentsBloc: RefreshPayments successful, received ${payments.length} payments',
        );
        emit(PaymentsLoaded(payments));
      }
    } catch (e) {
      final message = handleException(e, context: 'refresh_payments');
      emit(PaymentsError(message));
    }
  }

  Future<void> _onSearchPayments(
    SearchPaymentsEvent event,
    Emitter<PaymentsState> emit,
  ) async {
    try {
      _logger.d(
        'PaymentsBloc: Starting SearchPaymentsEvent with key: ${event.searchKey}',
      );

      if (event.searchKey.isEmpty) {
        _logger.d('PaymentsBloc: Empty search key, calling GetPaymentsEvent');
        add(const GetPaymentsEvent());
        return;
      }

      emit(PaymentsLoading());
      _logger.d('PaymentsBloc: Emitted PaymentsLoading state');

      _logger.d('PaymentsBloc: Calling _searchPayments use case');
      final payments = await _searchPayments(event.searchKey);
      _logger.d('PaymentsBloc: Received ${payments.length} search results');

      if (payments.isEmpty) {
        _logger.d('PaymentsBloc: No search results found');
        emit(PaymentsEmpty('No payments found for "${event.searchKey}"'));
      } else {
        _logger.d(
          'PaymentsBloc: SearchPayments successful, emitting PaymentsLoaded',
        );
        emit(PaymentsLoaded(payments));
      }
    } catch (e) {
      final message = handleException(
        e,
        context: 'search_payments',
        metadata: {'searchKey': event.searchKey},
      );
      emit(PaymentsError(message));
    }
  }
}
