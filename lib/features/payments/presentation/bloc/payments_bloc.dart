import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/payment.dart';
import '../../domain/usecases/get_payments.dart';
import '../../domain/usecases/get_payment_by_id.dart';
import '../../domain/usecases/get_payments_by_account_id.dart';

part 'payments_event.dart';
part 'payments_state.dart';

@injectable
class PaymentsBloc extends Bloc<PaymentsEvent, PaymentsState> {
  final GetPayments _getPayments;
  final GetPaymentById _getPaymentById;
  final GetPaymentsByAccountId _getPaymentsByAccountId;

  PaymentsBloc({
    required GetPayments getPayments,
    required GetPaymentById getPaymentById,
    required GetPaymentsByAccountId getPaymentsByAccountId,
  }) : _getPayments = getPayments,
       _getPaymentById = getPaymentById,
       _getPaymentsByAccountId = getPaymentsByAccountId,
       super(PaymentsInitial()) {
    on<GetPaymentsEvent>(_onGetPayments);
    on<GetPaymentByIdEvent>(_onGetPaymentById);
    on<GetPaymentsByAccountIdEvent>(_onGetPaymentsByAccountId);
    on<RefreshPaymentsEvent>(_onRefreshPayments);
  }

  Future<void> _onGetPayments(
    GetPaymentsEvent event,
    Emitter<PaymentsState> emit,
  ) async {
    emit(PaymentsLoading());

    final result = await _getPayments();

    result.fold(
      (failure) => emit(PaymentsError(failure.message)),
      (payments) => emit(PaymentsLoaded(payments)),
    );
  }

  Future<void> _onGetPaymentById(
    GetPaymentByIdEvent event,
    Emitter<PaymentsState> emit,
  ) async {
    emit(PaymentLoading());

    final result = await _getPaymentById(event.paymentId);

    result.fold(
      (failure) => emit(PaymentError(failure.message)),
      (payment) => emit(PaymentLoaded(payment)),
    );
  }

  Future<void> _onGetPaymentsByAccountId(
    GetPaymentsByAccountIdEvent event,
    Emitter<PaymentsState> emit,
  ) async {
    emit(PaymentsLoading());

    final result = await _getPaymentsByAccountId(event.accountId);

    result.fold(
      (failure) => emit(PaymentsError(failure.message)),
      (payments) => emit(PaymentsLoaded(payments)),
    );
  }

  Future<void> _onRefreshPayments(
    RefreshPaymentsEvent event,
    Emitter<PaymentsState> emit,
  ) async {
    if (state is PaymentsLoaded) {
      emit(PaymentsRefreshing((state as PaymentsLoaded).payments));
    } else {
      emit(PaymentsLoading());
    }

    final result = await _getPayments();

    result.fold(
      (failure) => emit(PaymentsError(failure.message)),
      (payments) => emit(PaymentsLoaded(payments)),
    );
  }
}
