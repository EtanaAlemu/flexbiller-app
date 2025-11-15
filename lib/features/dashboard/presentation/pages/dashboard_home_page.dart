import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import '../bloc/dashboard_bloc.dart';
import '../widgets/dashboard_welcome_section.dart';
import '../widgets/dashboard_kpi_cards.dart';
import '../widgets/dashboard_kpi_cards_skeleton.dart';
import '../widgets/subscription_trends_chart.dart';
import '../widgets/subscription_trends_chart_skeleton.dart';
import '../widgets/payment_status_overview_chart.dart';
import '../widgets/payment_status_overview_chart_skeleton.dart';
import '../../domain/entities/dashboard_kpi.dart';
import '../../../../injection_container.dart';

class DashboardHomePage extends StatefulWidget {
  const DashboardHomePage({Key? key}) : super(key: key);

  @override
  State<DashboardHomePage> createState() => _DashboardHomePageState();
}

class _DashboardHomePageState extends State<DashboardHomePage> {
  final Logger _logger = Logger();
  int _subscriptionTrendsYear = DateTime.now().year;
  int _paymentStatusOverviewYear = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    _logger.i('📊 [Dashboard Page] DashboardHomePage initialized');
  }

  void _onSubscriptionTrendsYearChanged(int year, BuildContext blocContext) {
    setState(() {
      _subscriptionTrendsYear = year;
    });
    // Dispatch event to load subscription trends for the new year only
    blocContext.read<DashboardBloc>().add(LoadSubscriptionTrends(year));
  }

  void _onPaymentStatusOverviewYearChanged(int year, BuildContext blocContext) {
    setState(() {
      _paymentStatusOverviewYear = year;
    });
    // Dispatch event to load payment status overview for the new year only
    blocContext.read<DashboardBloc>().add(LoadPaymentStatusOverview(year));
  }

  Future<void> _onRefresh(BuildContext blocContext) async {
    _logger.i('🔄 [Dashboard Page] Pull to refresh triggered');

    // Use BlocProvider.of to get the bloc from the correct context
    final bloc = BlocProvider.of<DashboardBloc>(blocContext);

    // Dispatch all events to refresh data
    bloc.add(const LoadDashboardKPIs());
    bloc.add(LoadSubscriptionTrends(_subscriptionTrendsYear));
    bloc.add(LoadPaymentStatusOverview(_paymentStatusOverviewYear));

    // Wait a bit for the events to be processed
    // The actual refresh will happen asynchronously via BLoC
    await Future.delayed(const Duration(milliseconds: 500));

    _logger.d('✅ [Dashboard Page] Refresh events dispatched');
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        _logger.d('🎯 [Dashboard Page] Creating DashboardBloc');
        final bloc = getIt<DashboardBloc>();
        _logger.d('📤 [Dashboard Page] Dispatching LoadDashboardKPIs event');
        bloc.add(const LoadDashboardKPIs());
        _logger.d(
          '📤 [Dashboard Page] Dispatching LoadSubscriptionTrends event for year: ${DateTime.now().year}',
        );
        bloc.add(LoadSubscriptionTrends(DateTime.now().year));
        _logger.d(
          '📤 [Dashboard Page] Dispatching LoadPaymentStatusOverview event for year: ${DateTime.now().year}',
        );
        bloc.add(LoadPaymentStatusOverview(DateTime.now().year));
        return bloc;
      },
      child: BlocListener<DashboardBloc, DashboardState>(
        listener: (context, state) {
          if (state is DashboardKPIError) {
            _logger.e('❌ [Dashboard Page] KPI Error: ${state.message}');
            _logger.e(
              '📚 [Dashboard Page] This might be a database query error',
            );
          }
          if (state is SubscriptionTrendsError) {
            _logger.e(
              '❌ [Dashboard Page] Subscription Trends Error: ${state.message}',
            );
          }
        },
        child: Builder(
          builder: (builderContext) => Scaffold(
            body: RefreshIndicator(
              onRefresh: () => _onRefresh(builderContext),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome Section
                    // const DashboardWelcomeSection(),
                    // Main Content
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 8.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),

                          // KPI Cards - Real Data from API
                          BlocBuilder<DashboardBloc, DashboardState>(
                            buildWhen: (previous, current) {
                              // Rebuild when KPI-related states change
                              return current is DashboardKPILoaded ||
                                  current is DashboardKPIError ||
                                  current is DashboardKPILoading ||
                                  (current is SubscriptionTrendsLoaded &&
                                      current.kpis != null) ||
                                  (current is SubscriptionTrendsLoading &&
                                      current.kpis != null) ||
                                  (current is SubscriptionTrendsError &&
                                      current.kpis != null);
                            },
                            builder: (context, state) {
                              DashboardKPI? kpis;

                              // Extract KPIs from any state that might have them
                              if (state is DashboardKPILoaded) {
                                kpis = state.kpis;
                              } else if (state is SubscriptionTrendsLoaded &&
                                  state.kpis != null) {
                                kpis = state.kpis;
                              } else if (state is SubscriptionTrendsLoading &&
                                  state.kpis != null) {
                                kpis = state.kpis;
                              } else if (state is SubscriptionTrendsError &&
                                  state.kpis != null) {
                                kpis = state.kpis;
                              }

                              if (kpis != null) {
                                _logger.d(
                                  '✅ [Dashboard Page] KPI Cards loaded successfully',
                                );
                                return DashboardKPICards(kpis: kpis);
                              } else if (state is DashboardKPIError) {
                                _logger.e(
                                  '❌ [Dashboard Page] KPI Error State: ${state.message}',
                                );
                                _logger.e(
                                  '🔍 [Dashboard Page] Error might be from database query',
                                );
                                return Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      children: [
                                        Text(
                                          'Error loading KPIs: ${state.message}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge
                                              ?.copyWith(color: Colors.red),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Check logs for database query details',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              } else if (state is DashboardKPILoading) {
                                _logger.d('⏳ [Dashboard Page] KPI Loading...');
                                return const DashboardKPICardsSkeleton();
                              } else if (state is DashboardInitial) {
                                // Show skeleton on initial state
                                return const DashboardKPICardsSkeleton();
                              } else {
                                // Return empty space to maintain layout
                                return const SizedBox.shrink();
                              }
                            },
                          ),
                          const SizedBox(height: 16),

                          // Subscription Trends Chart
                          BlocBuilder<DashboardBloc, DashboardState>(
                            buildWhen: (previous, current) {
                              // Rebuild when subscription trends states change
                              return current is SubscriptionTrendsLoaded ||
                                  current is SubscriptionTrendsError ||
                                  current is SubscriptionTrendsLoading;
                            },
                            builder: (context, state) {
                              if (state is SubscriptionTrendsLoaded) {
                                _logger.d(
                                  '✅ [Dashboard Page] Subscription Trends loaded successfully',
                                );
                                // Update selected year to match loaded data
                                if (_subscriptionTrendsYear !=
                                    state.trends.year) {
                                  WidgetsBinding.instance.addPostFrameCallback((
                                    _,
                                  ) {
                                    setState(() {
                                      _subscriptionTrendsYear =
                                          state.trends.year;
                                    });
                                  });
                                }
                                return SubscriptionTrendsChart(
                                  trends: state.trends,
                                  selectedYear: state.trends.year,
                                  onYearChanged: (year, blocContext) =>
                                      _onSubscriptionTrendsYearChanged(
                                        year,
                                        blocContext,
                                      ),
                                );
                              } else if (state is SubscriptionTrendsError) {
                                _logger.e(
                                  '❌ [Dashboard Page] Subscription Trends Error State: ${state.message}',
                                );
                                _logger.e(
                                  '❌ [Dashboard Page] Subscription Trends Error State: ${state.message}',
                                );
                                return Card(
                                  elevation: 0.2,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Center(
                                      child: Column(
                                        children: [
                                          Text(
                                            'Error loading subscription trends: ${state.message}',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyLarge
                                                ?.copyWith(color: Colors.red),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Check logs for details',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(color: Colors.grey),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              } else if (state is SubscriptionTrendsLoading) {
                                _logger.d(
                                  '⏳ [Dashboard Page] Subscription Trends Loading...',
                                );
                                return const SubscriptionTrendsChartSkeleton();
                              } else if (state is DashboardInitial ||
                                  state is DashboardKPILoading ||
                                  state is DashboardKPILoaded) {
                                // Show skeleton on initial states or when KPIs are loading/loaded but trends haven't started
                                return const SubscriptionTrendsChartSkeleton();
                              } else {
                                // Don't show anything if trends haven't been requested yet
                                return const SizedBox.shrink();
                              }
                            },
                          ),
                          const SizedBox(height: 16),

                          // Payment Status Overview Chart
                          BlocBuilder<DashboardBloc, DashboardState>(
                            buildWhen: (previous, current) {
                              // Rebuild when payment status overview states change
                              return current is PaymentStatusOverviewLoaded ||
                                  current is PaymentStatusOverviewError ||
                                  current is PaymentStatusOverviewLoading;
                            },
                            builder: (context, state) {
                              if (state is PaymentStatusOverviewLoaded) {
                                _logger.d(
                                  '✅ [Dashboard Page] Payment Status Overview loaded successfully',
                                );
                                // Update selected year to match loaded data
                                if (_paymentStatusOverviewYear !=
                                    state.overview.year) {
                                  WidgetsBinding.instance.addPostFrameCallback((
                                    _,
                                  ) {
                                    setState(() {
                                      _paymentStatusOverviewYear =
                                          state.overview.year;
                                    });
                                  });
                                }
                                return PaymentStatusOverviewChart(
                                  overview: state.overview,
                                  selectedYear: state.overview.year,
                                  onYearChanged: (year, blocContext) =>
                                      _onPaymentStatusOverviewYearChanged(
                                        year,
                                        blocContext,
                                      ),
                                );
                              } else if (state is PaymentStatusOverviewError) {
                                _logger.e(
                                  '❌ [Dashboard Page] Payment Status Overview Error State: ${state.message}',
                                );
                                return Card(
                                  elevation: 0.2,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Center(
                                      child: Column(
                                        children: [
                                          Text(
                                            'Error loading payment status overview: ${state.message}',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyLarge
                                                ?.copyWith(color: Colors.red),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Check logs for details',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(color: Colors.grey),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              } else if (state
                                  is PaymentStatusOverviewLoading) {
                                _logger.d(
                                  '⏳ [Dashboard Page] Payment Status Overview Loading...',
                                );
                                return const PaymentStatusOverviewChartSkeleton();
                              } else if (state is DashboardInitial ||
                                  state is DashboardKPILoading ||
                                  state is DashboardKPILoaded ||
                                  state is SubscriptionTrendsLoading ||
                                  state is SubscriptionTrendsLoaded) {
                                // Show skeleton on initial states or when other data is loading/loaded but overview hasn't started
                                return const PaymentStatusOverviewChartSkeleton();
                              } else {
                                // Don't show anything if overview hasn't been requested yet
                                return const SizedBox.shrink();
                              }
                            },
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
