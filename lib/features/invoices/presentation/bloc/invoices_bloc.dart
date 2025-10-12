import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';

import '../../domain/entities/invoice.dart';
import '../../domain/usecases/get_invoices.dart';
import '../../domain/usecases/search_invoices.dart';

part 'events/invoices_event.dart';
part 'states/invoices_state.dart';

@injectable
class InvoicesBloc extends Bloc<InvoicesEvent, InvoicesState> {
  final GetInvoices _getInvoices;
  final SearchInvoices _searchInvoices;
  final Logger _logger;

  InvoicesBloc({
    required GetInvoices getInvoices,
    required SearchInvoices searchInvoices,
    required Logger logger,
  }) : _getInvoices = getInvoices,
       _searchInvoices = searchInvoices,
       _logger = logger,
       super(InvoicesInitial()) {
    _logger.d('InvoicesBloc initialized');
    on<GetInvoicesEvent>(_onGetInvoices);
    on<RefreshInvoicesEvent>(_onRefreshInvoices);
    on<SearchInvoicesEvent>(_onSearchInvoices);
  }

  Future<void> _onGetInvoices(
    GetInvoicesEvent event,
    Emitter<InvoicesState> emit,
  ) async {
    try {
      _logger.d('InvoicesBloc: Starting GetInvoicesEvent');
      emit(InvoicesLoading());
      _logger.d('InvoicesBloc: Emitted InvoicesLoading state');

      _logger.d('InvoicesBloc: Calling _getInvoices use case');
      final result = await _getInvoices();
      _logger.d('InvoicesBloc: Received result from _getInvoices');

      result.fold(
        (failure) {
          _logger.e(
            'InvoicesBloc: GetInvoices failed with error: ${failure.message}',
          );
          emit(InvoicesError(failure.message));
        },
        (invoices) {
          _logger.d(
            'InvoicesBloc: GetInvoices successful, received ${invoices.length} invoices',
          );
          emit(InvoicesLoaded(invoices));
        },
      );
    } catch (e, stackTrace) {
      _logger.e('InvoicesBloc: Unexpected error in _onGetInvoices: $e');
      _logger.e('InvoicesBloc: Stack trace: $stackTrace');
      emit(InvoicesError('Unexpected error occurred: $e'));
    }
  }

  Future<void> _onRefreshInvoices(
    RefreshInvoicesEvent event,
    Emitter<InvoicesState> emit,
  ) async {
    try {
      _logger.d('InvoicesBloc: Starting RefreshInvoicesEvent');

      if (state is InvoicesLoaded) {
        final currentInvoices = (state as InvoicesLoaded).invoices;
        _logger.d(
          'InvoicesBloc: Emitting InvoicesRefreshing with ${currentInvoices.length} invoices',
        );
        emit(InvoicesRefreshing(currentInvoices));
      } else {
        _logger.d('InvoicesBloc: Emitting InvoicesLoading for refresh');
        emit(InvoicesLoading());
      }

      _logger.d('InvoicesBloc: Calling _getInvoices use case for refresh');
      final result = await _getInvoices();
      _logger.d('InvoicesBloc: Received result from _getInvoices for refresh');

      result.fold(
        (failure) {
          _logger.e(
            'InvoicesBloc: RefreshInvoices failed with error: ${failure.message}',
          );
          emit(InvoicesError(failure.message));
        },
        (invoices) {
          _logger.d(
            'InvoicesBloc: RefreshInvoices successful, received ${invoices.length} invoices',
          );
          emit(InvoicesLoaded(invoices));
        },
      );
    } catch (e, stackTrace) {
      _logger.e('InvoicesBloc: Unexpected error in _onRefreshInvoices: $e');
      _logger.e('InvoicesBloc: Stack trace: $stackTrace');
      emit(InvoicesError('Unexpected error occurred: $e'));
    }
  }

  Future<void> _onSearchInvoices(
    SearchInvoicesEvent event,
    Emitter<InvoicesState> emit,
  ) async {
    try {
      _logger.d(
        'InvoicesBloc: Starting SearchInvoicesEvent with key: ${event.searchKey}',
      );

      if (event.searchKey.isEmpty) {
        _logger.d('InvoicesBloc: Empty search key, calling GetInvoicesEvent');
        add(const GetInvoicesEvent());
        return;
      }

      emit(InvoicesLoading());
      _logger.d('InvoicesBloc: Emitted InvoicesLoading state');

      _logger.d('InvoicesBloc: Calling _searchInvoices use case');
      final invoices = await _searchInvoices(event.searchKey);
      _logger.d('InvoicesBloc: Received ${invoices.length} search results');

      if (invoices.isEmpty) {
        _logger.d('InvoicesBloc: No search results found');
        emit(InvoicesEmpty('No invoices found for "${event.searchKey}"'));
      } else {
        _logger.d(
          'InvoicesBloc: SearchInvoices successful, emitting InvoicesLoaded',
        );
        emit(InvoicesLoaded(invoices));
      }
    } catch (e, stackTrace) {
      _logger.e('InvoicesBloc: Unexpected error in _onSearchInvoices: $e');
      _logger.e('InvoicesBloc: Stack trace: $stackTrace');
      emit(InvoicesError('Search failed: $e'));
    }
  }
}
