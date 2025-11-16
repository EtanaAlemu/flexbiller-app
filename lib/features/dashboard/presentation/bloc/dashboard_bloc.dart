import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import '../../../../core/bloc/bloc_error_handler_mixin.dart';
import '../../../../core/models/repository_response.dart';
import '../../domain/entities/dashboard_kpi.dart';
import '../../domain/entities/subscription_trend.dart';
import '../../domain/entities/payment_status_overview.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../../domain/usecases/get_dashboard_kpis.dart';
import '../../domain/usecases/get_subscription_trends.dart';
import '../../domain/usecases/get_payment_status_overview.dart';

part 'dashboard_event.dart';
part 'dashboard_state.dart';

@injectable
class DashboardBloc extends Bloc<DashboardEvent, DashboardState>
    with BlocErrorHandlerMixin {
  final GetDashboardKPIs getDashboardKPIs;
  final GetSubscriptionTrends getSubscriptionTrends;
  final GetPaymentStatusOverview getPaymentStatusOverview;
  final DashboardRepository dashboardRepository;
  final Logger _logger = Logger();

  // Stream subscriptions for reactive updates
  StreamSubscription<RepositoryResponse<DashboardKPI>>? _kpisSubscription;
  final Map<int, StreamSubscription<RepositoryResponse<SubscriptionTrends>>>
  _trendsSubscriptions = {};
  final Map<int, StreamSubscription<RepositoryResponse<PaymentStatusOverviews>>>
  _overviewSubscriptions = {};

  DashboardBloc({
    required this.getDashboardKPIs,
    required this.getSubscriptionTrends,
    required this.getPaymentStatusOverview,
    required this.dashboardRepository,
  }) : super(DashboardInitial()) {
    on<LoadDashboardKPIs>(_onLoadDashboardKPIs);
    on<LoadSubscriptionTrends>(_onLoadSubscriptionTrends);
    on<LoadPaymentStatusOverview>(_onLoadPaymentStatusOverview);
    on<KPIsStreamUpdate>(_onKPIsStreamUpdate);
    on<SubscriptionTrendsStreamUpdate>(_onSubscriptionTrendsStreamUpdate);
    on<PaymentStatusOverviewStreamUpdate>(_onPaymentStatusOverviewStreamUpdate);
    _logger.d('🎯 [Dashboard Bloc] DashboardBloc initialized');
  }

  @override
  Future<void> close() {
    _kpisSubscription?.cancel();
    for (final subscription in _trendsSubscriptions.values) {
      subscription.cancel();
    }
    _trendsSubscriptions.clear();
    for (final subscription in _overviewSubscriptions.values) {
      subscription.cancel();
    }
    _overviewSubscriptions.clear();
    return super.close();
  }

  Future<void> _onLoadDashboardKPIs(
    LoadDashboardKPIs event,
    Emitter<DashboardState> emit,
  ) async {
    _logger.i('📊 [Dashboard Bloc] LoadDashboardKPIs event received');
    emit(DashboardKPILoading());
    _logger.d('🔄 [Dashboard Bloc] Emitted DashboardKPILoading state');

    try {
      final result = await getDashboardKPIs();

      final kpis = handleEitherResult(
        result,
        context: 'load_dashboard_kpis',
        onError: (message) {
          emit(DashboardKPIError(message));
        },
      );

      if (kpis != null) {
        _logger.i('✅ [Dashboard Bloc] Successfully loaded dashboard KPIs');
        _logger.d(
          '📊 [Dashboard Bloc] Active Subscriptions: ${kpis.activeSubscriptions.value}',
        );
        _logger.d(
          '📊 [Dashboard Bloc] Pending Invoices: ${kpis.pendingInvoices.value}',
        );
        _logger.d(
          '📊 [Dashboard Bloc] Failed Payments: ${kpis.failedPayments.value}',
        );
        _logger.d(
          '📊 [Dashboard Bloc] Monthly Revenue: ${kpis.monthlyRevenue.value} ${kpis.monthlyRevenue.currency}',
        );
        emit(DashboardKPILoaded(kpis));

        // Subscribe to stream for reactive updates
        _subscribeToKPIsStream();
      }
    } catch (e) {
      final message = handleException(e, context: 'load_dashboard_kpis');
      emit(DashboardKPIError(message));
    }
  }

  Future<void> _onLoadSubscriptionTrends(
    LoadSubscriptionTrends event,
    Emitter<DashboardState> emit,
  ) async {
    _logger.i(
      '📊 [Dashboard Bloc] LoadSubscriptionTrends event received for year: ${event.year}',
    );

    // Preserve KPI data if available in current state
    DashboardKPI? preservedKPIs;
    if (state is DashboardKPILoaded) {
      preservedKPIs = (state as DashboardKPILoaded).kpis;
    } else if (state is SubscriptionTrendsLoaded) {
      preservedKPIs = (state as SubscriptionTrendsLoaded).kpis;
    } else if (state is SubscriptionTrendsLoading) {
      preservedKPIs = (state as SubscriptionTrendsLoading).kpis;
    } else if (state is SubscriptionTrendsError) {
      preservedKPIs = (state as SubscriptionTrendsError).kpis;
    }

    emit(SubscriptionTrendsLoading(kpis: preservedKPIs));
    _logger.d('🔄 [Dashboard Bloc] Emitted SubscriptionTrendsLoading state');

    try {
      final result = await getSubscriptionTrends(event.year);

      final trends = handleEitherResult(
        result,
        context: 'load_subscription_trends',
        onError: (message) {
          emit(SubscriptionTrendsError(message, kpis: preservedKPIs));
        },
      );

      if (trends != null) {
        _logger.i('✅ [Dashboard Bloc] Successfully loaded subscription trends');
        _logger.d(
          '📊 [Dashboard Bloc] Trends count: ${trends.trends.length} months',
        );
        _logger.d('📊 [Dashboard Bloc] Year: ${trends.year}');
        emit(SubscriptionTrendsLoaded(trends, kpis: preservedKPIs));

        // Subscribe to stream for reactive updates
        _subscribeToTrendsStream(event.year, preservedKPIs);
      }
    } catch (e) {
      final message = handleException(
        e,
        context: 'load_subscription_trends',
        metadata: {'year': event.year},
      );
      emit(SubscriptionTrendsError(message, kpis: preservedKPIs));
    }
  }

  Future<void> _onLoadPaymentStatusOverview(
    LoadPaymentStatusOverview event,
    Emitter<DashboardState> emit,
  ) async {
    _logger.i(
      '📊 [Dashboard Bloc] LoadPaymentStatusOverview event received for year: ${event.year}',
    );

    // Preserve KPI data if available in current state
    DashboardKPI? preservedKPIs;
    if (state is DashboardKPILoaded) {
      preservedKPIs = (state as DashboardKPILoaded).kpis;
    } else if (state is SubscriptionTrendsLoaded) {
      preservedKPIs = (state as SubscriptionTrendsLoaded).kpis;
    } else if (state is SubscriptionTrendsLoading) {
      preservedKPIs = (state as SubscriptionTrendsLoading).kpis;
    } else if (state is SubscriptionTrendsError) {
      preservedKPIs = (state as SubscriptionTrendsError).kpis;
    } else if (state is PaymentStatusOverviewLoaded) {
      preservedKPIs = (state as PaymentStatusOverviewLoaded).kpis;
    } else if (state is PaymentStatusOverviewLoading) {
      preservedKPIs = (state as PaymentStatusOverviewLoading).kpis;
    } else if (state is PaymentStatusOverviewError) {
      preservedKPIs = (state as PaymentStatusOverviewError).kpis;
    }

    emit(PaymentStatusOverviewLoading(kpis: preservedKPIs));
    _logger.d('🔄 [Dashboard Bloc] Emitted PaymentStatusOverviewLoading state');

    try {
      final result = await getPaymentStatusOverview(event.year);

      final overview = handleEitherResult(
        result,
        context: 'load_payment_status_overview',
        onError: (message) {
          emit(PaymentStatusOverviewError(message, kpis: preservedKPIs));
        },
      );

      if (overview != null) {
        _logger.i(
          '✅ [Dashboard Bloc] Successfully loaded payment status overview',
        );
        _logger.d(
          '📊 [Dashboard Bloc] Overview count: ${overview.overviews.length} months',
        );
        _logger.d('📊 [Dashboard Bloc] Year: ${overview.year}');
        emit(PaymentStatusOverviewLoaded(overview, kpis: preservedKPIs));

        // Subscribe to stream for reactive updates
        _subscribeToOverviewStream(event.year, preservedKPIs);
      }
    } catch (e) {
      final message = handleException(
        e,
        context: 'load_payment_status_overview',
        metadata: {'year': event.year},
      );
      emit(PaymentStatusOverviewError(message, kpis: preservedKPIs));
    }
  }

  /// Subscribe to KPIs stream for reactive updates
  void _subscribeToKPIsStream() {
    _kpisSubscription?.cancel();
    _kpisSubscription = dashboardRepository.kpisStream.listen(
      (response) {
        if (response.isSuccess && response.data != null) {
          _logger.d('📡 [Dashboard Bloc] Received KPIs update from stream');
          add(KPIsStreamUpdate(response.data!));
        } else if (response.hasError) {
          _logger.w(
            '⚠️ [Dashboard Bloc] KPIs stream error: ${response.errorMessage}',
          );
          // Don't dispatch event for stream errors, just log
        }
      },
      onError: (error) {
        _logger.e('❌ [Dashboard Bloc] KPIs stream error: $error');
        // Don't dispatch event for stream errors, just log
      },
    );
  }

  /// Subscribe to trends stream for reactive updates
  void _subscribeToTrendsStream(int year, DashboardKPI? preservedKPIs) {
    _trendsSubscriptions[year]?.cancel();
    _trendsSubscriptions[year] = dashboardRepository
        .getSubscriptionTrendsStream(year)
        .listen(
          (response) {
            if (response.isSuccess && response.data != null) {
              _logger.d(
                '📡 [Dashboard Bloc] Received trends update from stream for year $year',
              );
              // Get current KPIs from state if available
              DashboardKPI? currentKPIs;
              if (state is SubscriptionTrendsLoaded) {
                currentKPIs = (state as SubscriptionTrendsLoaded).kpis;
              } else if (state is SubscriptionTrendsLoading) {
                currentKPIs = (state as SubscriptionTrendsLoading).kpis;
              } else if (state is DashboardKPILoaded) {
                currentKPIs = (state as DashboardKPILoaded).kpis;
              } else {
                currentKPIs = preservedKPIs;
              }
              add(
                SubscriptionTrendsStreamUpdate(
                  response.data!,
                  year,
                  preservedKPIs: currentKPIs,
                ),
              );
            } else if (response.hasError) {
              _logger.w(
                '⚠️ [Dashboard Bloc] Trends stream error for year $year: ${response.errorMessage}',
              );
              // Don't dispatch event for stream errors, just log
            }
          },
          onError: (error) {
            _logger.e(
              '❌ [Dashboard Bloc] Trends stream error for year $year: $error',
            );
            // Don't dispatch event for stream errors, just log
          },
        );
  }

  /// Subscribe to overview stream for reactive updates
  void _subscribeToOverviewStream(int year, DashboardKPI? preservedKPIs) {
    _overviewSubscriptions[year]?.cancel();
    _overviewSubscriptions[year] = dashboardRepository
        .getPaymentStatusOverviewStream(year)
        .listen(
          (response) {
            if (response.isSuccess && response.data != null) {
              _logger.d(
                '📡 [Dashboard Bloc] Received overview update from stream for year $year',
              );
              // Get current KPIs from state if available
              DashboardKPI? currentKPIs;
              if (state is PaymentStatusOverviewLoaded) {
                currentKPIs = (state as PaymentStatusOverviewLoaded).kpis;
              } else if (state is PaymentStatusOverviewLoading) {
                currentKPIs = (state as PaymentStatusOverviewLoading).kpis;
              } else if (state is DashboardKPILoaded) {
                currentKPIs = (state as DashboardKPILoaded).kpis;
              } else {
                currentKPIs = preservedKPIs;
              }
              add(
                PaymentStatusOverviewStreamUpdate(
                  response.data!,
                  year,
                  preservedKPIs: currentKPIs,
                ),
              );
            } else if (response.hasError) {
              _logger.w(
                '⚠️ [Dashboard Bloc] Overview stream error for year $year: ${response.errorMessage}',
              );
              // Don't dispatch event for stream errors, just log
            }
          },
          onError: (error) {
            _logger.e(
              '❌ [Dashboard Bloc] Overview stream error for year $year: $error',
            );
            // Don't dispatch event for stream errors, just log
          },
        );
  }

  /// Handle KPIs stream update event
  Future<void> _onKPIsStreamUpdate(
    KPIsStreamUpdate event,
    Emitter<DashboardState> emit,
  ) async {
    _logger.d('📡 [Dashboard Bloc] Processing KPIs stream update');
    emit(DashboardKPILoaded(event.kpis));
  }

  /// Handle subscription trends stream update event
  Future<void> _onSubscriptionTrendsStreamUpdate(
    SubscriptionTrendsStreamUpdate event,
    Emitter<DashboardState> emit,
  ) async {
    _logger.d(
      '📡 [Dashboard Bloc] Processing trends stream update for year ${event.year}',
    );
    emit(SubscriptionTrendsLoaded(event.trends, kpis: event.preservedKPIs));
  }

  /// Handle payment status overview stream update event
  Future<void> _onPaymentStatusOverviewStreamUpdate(
    PaymentStatusOverviewStreamUpdate event,
    Emitter<DashboardState> emit,
  ) async {
    _logger.d(
      '📡 [Dashboard Bloc] Processing overview stream update for year ${event.year}',
    );
    emit(
      PaymentStatusOverviewLoaded(event.overview, kpis: event.preservedKPIs),
    );
  }
}
