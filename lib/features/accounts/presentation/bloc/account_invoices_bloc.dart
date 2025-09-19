import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/usecases/get_invoices_usecase.dart';
import 'events/account_invoices_event.dart';
import 'states/account_invoices_state.dart';
import 'package:logger/logger.dart';

@injectable
class AccountInvoicesBloc
    extends Bloc<AccountInvoicesEvent, AccountInvoicesState> {
  final GetInvoicesUseCase _getInvoicesUseCase;
  final Logger _logger = Logger();

  AccountInvoicesBloc({required GetInvoicesUseCase getInvoicesUseCase})
    : _getInvoicesUseCase = getInvoicesUseCase,
      super(AccountInvoicesInitial()) {
    on<LoadAccountInvoices>(_onLoadAccountInvoices);
    on<RefreshAccountInvoices>(_onRefreshAccountInvoices);
  }

  Future<void> _onLoadAccountInvoices(
    LoadAccountInvoices event,
    Emitter<AccountInvoicesState> emit,
  ) async {
    try {
      _logger.d(
        '🔍 _onLoadAccountInvoices called for account: ${event.accountId}',
      );
      emit(AccountInvoicesLoading(accountId: event.accountId));
      _logger.d('🔍 Emitted AccountInvoicesLoading state');

      _logger.d('🔍 About to call _getInvoicesUseCase');
      final invoices = await _getInvoicesUseCase(event.accountId);
      _logger.d('🔍 Got ${invoices.length} invoices from use case');

      final loadedState = AccountInvoicesLoaded(
        accountId: event.accountId,
        invoices: invoices,
      );
      _logger.d(
        '🔍 About to emit AccountInvoicesLoaded state with ${invoices.length} invoices',
      );
      _logger.d(
        '🔍 State details: accountId=${loadedState.accountId}, invoices=${loadedState.invoices}',
      );
      emit(loadedState);
      _logger.d(
        '🔍 Successfully emitted AccountInvoicesLoaded state with ${invoices.length} invoices',
      );
      _logger.d('🔍 Bloc instance emitting state: ${this.hashCode}');
      _logger.d('🔍 State hashCode: ${loadedState.hashCode}');
      _logger.d('🔍 State props: ${loadedState.props}');
    } catch (e) {
      _logger.e('🔍 Error in _onLoadAccountInvoices: $e');
      emit(
        AccountInvoicesFailure(
          message: e.toString(),
          accountId: event.accountId,
        ),
      );
    }
  }

  Future<void> _onRefreshAccountInvoices(
    RefreshAccountInvoices event,
    Emitter<AccountInvoicesState> emit,
  ) async {
    try {
      final currentState = state;
      if (currentState is AccountInvoicesLoaded) {
        emit(
          AccountInvoicesRefreshing(
            accountId: event.accountId,
            invoices: currentState.invoices,
          ),
        );
      } else {
        emit(AccountInvoicesLoading(accountId: event.accountId));
      }

      final invoices = await _getInvoicesUseCase(event.accountId);
      emit(
        AccountInvoicesLoaded(accountId: event.accountId, invoices: invoices),
      );
    } catch (e) {
      emit(
        AccountInvoicesFailure(
          message: e.toString(),
          accountId: event.accountId,
        ),
      );
    }
  }
}
