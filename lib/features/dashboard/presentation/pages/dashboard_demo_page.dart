import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/dashboard_bloc.dart';
import '../widgets/dashboard_overview_cards.dart';
import '../widgets/dashboard_charts.dart';
import '../widgets/dashboard_data_grid.dart';
import '../widgets/dashboard_calendar.dart';
import '../widgets/dashboard_date_picker.dart';
import '../../../../injection_container.dart';

class DashboardDemoPage extends StatefulWidget {
  const DashboardDemoPage({Key? key}) : super(key: key);

  @override
  State<DashboardDemoPage> createState() => _DashboardDemoPageState();
}

class _DashboardDemoPageState extends State<DashboardDemoPage> {
  bool _showAccounts = true;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    // Set default date range to last 6 months
    _endDate = DateTime.now();
    _startDate = DateTime.now().subtract(const Duration(days: 180));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          getIt<DashboardBloc>()..add(const LoadDashboardData()),
      child: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Text(
              //   'Dashboard',
              //   style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              //     fontWeight: FontWeight.bold,
              //   ),
              // ),
              const SizedBox(height: 8),
              Text(
                'Overview of your accounts and subscriptions',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 24),

              // Overview Cards
              BlocBuilder<DashboardBloc, DashboardState>(
                builder: (context, state) {
                  if (state is DashboardLoaded) {
                    return DashboardOverviewCards(
                      totalAccounts: state.dashboardData.totalAccounts,
                      activeAccounts: state.dashboardData.activeAccounts,
                      totalSubscriptions:
                          state.dashboardData.totalSubscriptions,
                      activeSubscriptions:
                          state.dashboardData.activeSubscriptions,
                      totalRevenue: state.dashboardData.totalRevenue,
                      monthlyRevenue: state.dashboardData.monthlyRevenue,
                    );
                  } else if (state is DashboardError) {
                    return Center(
                      child: Text(
                        'Error loading dashboard data: ${state.message}',
                        style: Theme.of(
                          context,
                        ).textTheme.bodyLarge?.copyWith(color: Colors.red),
                      ),
                    );
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                },
              ),
              const SizedBox(height: 24),

              // Charts
              BlocBuilder<DashboardBloc, DashboardState>(
                builder: (context, state) {
                  if (state is DashboardLoaded) {
                    return DashboardCharts(dashboardData: state.dashboardData);
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
