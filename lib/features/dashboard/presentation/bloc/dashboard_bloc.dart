import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import '../../domain/entities/dashboard_kpi.dart';
import '../../domain/entities/subscription_trend.dart';
import '../../domain/entities/payment_status_overview.dart';
import '../../domain/usecases/get_dashboard_kpis.dart';
import '../../domain/usecases/get_subscription_trends.dart';
import '../../domain/usecases/get_payment_status_overview.dart';

part 'dashboard_event.dart';
part 'dashboard_state.dart';

@injectable
class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetDashboardKPIs getDashboardKPIs;
  final GetSubscriptionTrends getSubscriptionTrends;
  final GetPaymentStatusOverview getPaymentStatusOverview;
  final Logger _logger = Logger();

  DashboardBloc({
    required this.getDashboardKPIs,
    required this.getSubscriptionTrends,
    required this.getPaymentStatusOverview,
  }) : super(DashboardInitial()) {
    on<LoadDashboardKPIs>(_onLoadDashboardKPIs);
    on<LoadSubscriptionTrends>(_onLoadSubscriptionTrends);
    on<LoadPaymentStatusOverview>(_onLoadPaymentStatusOverview);
    _logger.d('🎯 [Dashboard Bloc] DashboardBloc initialized');
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

      result.fold(
        (failure) {
          _logger.e(
            '❌ [Dashboard Bloc] Failed to load dashboard KPIs: ${failure.message}',
          );
          emit(DashboardKPIError(failure.message));
        },
        (kpis) {
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
        },
      );
    } catch (e, stackTrace) {
      _logger.e(
        '💥 [Dashboard Bloc] Unexpected error loading dashboard KPIs: $e',
      );
      _logger.e('📚 [Dashboard Bloc] Stack trace: $stackTrace');
      emit(DashboardKPIError('Unexpected error: $e'));
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

      result.fold(
        (failure) {
          _logger.e(
            '❌ [Dashboard Bloc] Failed to load subscription trends: ${failure.message}',
          );
          emit(SubscriptionTrendsError(failure.message, kpis: preservedKPIs));
        },
        (trends) {
          _logger.i(
            '✅ [Dashboard Bloc] Successfully loaded subscription trends',
          );
          _logger.d(
            '📊 [Dashboard Bloc] Trends count: ${trends.trends.length} months',
          );
          _logger.d('📊 [Dashboard Bloc] Year: ${trends.year}');
          emit(SubscriptionTrendsLoaded(trends, kpis: preservedKPIs));
        },
      );
    } catch (e, stackTrace) {
      _logger.e(
        '💥 [Dashboard Bloc] Unexpected error loading subscription trends: $e',
      );
      _logger.e('📚 [Dashboard Bloc] Stack trace: $stackTrace');
      emit(
        SubscriptionTrendsError('Unexpected error: $e', kpis: preservedKPIs),
      );
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

      result.fold(
        (failure) {
          _logger.e(
            '❌ [Dashboard Bloc] Failed to load payment status overview: ${failure.message}',
          );
          emit(
            PaymentStatusOverviewError(failure.message, kpis: preservedKPIs),
          );
        },
        (overview) {
          _logger.i(
            '✅ [Dashboard Bloc] Successfully loaded payment status overview',
          );
          _logger.d(
            '📊 [Dashboard Bloc] Overview count: ${overview.overviews.length} months',
          );
          _logger.d('📊 [Dashboard Bloc] Year: ${overview.year}');
          emit(PaymentStatusOverviewLoaded(overview, kpis: preservedKPIs));
        },
      );
    } catch (e, stackTrace) {
      _logger.e(
        '💥 [Dashboard Bloc] Unexpected error loading payment status overview: $e',
      );
      _logger.e('📚 [Dashboard Bloc] Stack trace: $stackTrace');
      emit(
        PaymentStatusOverviewError('Unexpected error: $e', kpis: preservedKPIs),
      );
    }
  }
}
