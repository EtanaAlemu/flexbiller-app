import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';

import '../../domain/entities/payment.dart';
import '../../domain/usecases/get_payments.dart';
import '../../domain/usecases/get_payment_by_id.dart';
import '../../domain/usecases/get_payments_by_account_id.dart';
import '../../domain/usecases/search_payments.dart';

part 'events/payments_event.dart';
part 'states/payments_state.dart';

@injectable
class PaymentsBloc extends Bloc<PaymentsEvent, PaymentsState> {
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

      result.fold(
        (failure) {
          _logger.e(
            'PaymentsBloc: GetPayments failed with error: ${failure.message}',
          );
          emit(PaymentsError(failure.message));
        },
        (payments) {
          _logger.d(
            'PaymentsBloc: GetPayments successful, received ${payments.length} payments',
          );
          emit(PaymentsLoaded(payments));
        },
      );
    } catch (e, stackTrace) {
      _logger.e('PaymentsBloc: Unexpected error in _onGetPayments: $e');
      _logger.e('PaymentsBloc: Stack trace: $stackTrace');
      emit(PaymentsError('Unexpected error occurred: $e'));
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

      result.fold(
        (failure) {
          _logger.e(
            'PaymentsBloc: GetPaymentById failed with error: ${failure.message}',
          );
          emit(PaymentError(failure.message));
        },
        (payment) {
          _logger.d(
            'PaymentsBloc: GetPaymentById successful, received payment: ${payment.paymentId}',
          );
          emit(PaymentLoaded(payment));
        },
      );
    } catch (e, stackTrace) {
      _logger.e('PaymentsBloc: Unexpected error in _onGetPaymentById: $e');
      _logger.e('PaymentsBloc: Stack trace: $stackTrace');
      emit(PaymentError('Unexpected error occurred: $e'));
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

      result.fold(
        (failure) {
          _logger.e(
            'PaymentsBloc: GetPaymentsByAccountId failed with error: ${failure.message}',
          );
          emit(PaymentsError(failure.message));
        },
        (payments) {
          _logger.d(
            'PaymentsBloc: GetPaymentsByAccountId successful, received ${payments.length} payments',
          );
          emit(PaymentsLoaded(payments));
        },
      );
    } catch (e, stackTrace) {
      _logger.e(
        'PaymentsBloc: Unexpected error in _onGetPaymentsByAccountId: $e',
      );
      _logger.e('PaymentsBloc: Stack trace: $stackTrace');
      emit(PaymentsError('Unexpected error occurred: $e'));
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

      result.fold(
        (failure) {
          _logger.e(
            'PaymentsBloc: RefreshPayments failed with error: ${failure.message}',
          );
          emit(PaymentsError(failure.message));
        },
        (payments) {
          _logger.d(
            'PaymentsBloc: RefreshPayments successful, received ${payments.length} payments',
          );
          emit(PaymentsLoaded(payments));
        },
      );
    } catch (e, stackTrace) {
      _logger.e('PaymentsBloc: Unexpected error in _onRefreshPayments: $e');
      _logger.e('PaymentsBloc: Stack trace: $stackTrace');
      emit(PaymentsError('Unexpected error occurred: $e'));
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
    } catch (e, stackTrace) {
      _logger.e('PaymentsBloc: Unexpected error in _onSearchPayments: $e');
      _logger.e('PaymentsBloc: Stack trace: $stackTrace');
      emit(PaymentsError('Search failed: $e'));
    }
  }
}
