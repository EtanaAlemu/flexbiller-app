import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/dashboard_data.dart';

class DashboardCharts extends StatelessWidget {
  final DashboardData dashboardData;

  const DashboardCharts({Key? key, required this.dashboardData})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Revenue Chart
        Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Revenue Trend',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 300,
                  child: SfCartesianChart(
                    primaryXAxis: CategoryAxis(),
                    primaryYAxis: NumericAxis(
                      numberFormat: NumberFormat.currency(symbol: '\$'),
                    ),
                    series: <CartesianSeries>[
                      LineSeries<RevenueChartData, String>(
                        dataSource: dashboardData.revenueChartData,
                        xValueMapper: (RevenueChartData data, _) => data.month,
                        yValueMapper: (RevenueChartData data, _) =>
                            data.revenue,
                        name: 'Revenue',
                        color: Colors.blue,
                        width: 3,
                        markerSettings: const MarkerSettings(
                          isVisible: true,
                          height: 6,
                          width: 6,
                        ),
                      ),
                    ],
                    tooltipBehavior: TooltipBehavior(enable: true),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Account Growth Chart
        Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Account Growth',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 300,
                  child: SfCartesianChart(
                    primaryXAxis: CategoryAxis(),
                    primaryYAxis: NumericAxis(),
                    series: <CartesianSeries>[
                      ColumnSeries<AccountChartData, String>(
                        dataSource: dashboardData.accountChartData,
                        xValueMapper: (AccountChartData data, _) => data.month,
                        yValueMapper: (AccountChartData data, _) => data.count,
                        name: 'Accounts',
                        color: Colors.green,
                        borderRadius: const BorderRadius.all(
                          Radius.circular(4),
                        ),
                      ),
                    ],
                    tooltipBehavior: TooltipBehavior(enable: true),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Subscription Distribution Chart
        Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Subscription Distribution',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 300,
                  child: SfCircularChart(
                    series: <PieSeries>[
                      PieSeries<SubscriptionChartData, String>(
                        dataSource: dashboardData.subscriptionChartData,
                        xValueMapper: (SubscriptionChartData data, _) =>
                            data.productName,
                        yValueMapper: (SubscriptionChartData data, _) =>
                            data.count,
                        dataLabelSettings: const DataLabelSettings(
                          isVisible: true,
                          labelPosition: ChartDataLabelPosition.outside,
                        ),
                        enableTooltip: true,
                      ),
                    ],
                    legend: Legend(
                      isVisible: true,
                      position: LegendPosition.bottom,
                      overflowMode: LegendItemOverflowMode.wrap,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Status Distribution Charts
        Row(
          children: [
            Expanded(
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Account Status',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 250,
                        child: SfCircularChart(
                          series: <PieSeries>[
                            PieSeries<AccountStatusData, String>(
                              dataSource: dashboardData.accountStatusData,
                              xValueMapper: (AccountStatusData data, _) =>
                                  data.status,
                              yValueMapper: (AccountStatusData data, _) =>
                                  data.count,
                              dataLabelSettings: const DataLabelSettings(
                                isVisible: true,
                                labelPosition: ChartDataLabelPosition.outside,
                              ),
                              enableTooltip: true,
                            ),
                          ],
                          legend: Legend(
                            isVisible: true,
                            position: LegendPosition.bottom,
                            overflowMode: LegendItemOverflowMode.wrap,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Subscription Status',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 250,
                        child: SfCircularChart(
                          series: <PieSeries>[
                            PieSeries<SubscriptionStatusData, String>(
                              dataSource: dashboardData.subscriptionStatusData,
                              xValueMapper: (SubscriptionStatusData data, _) =>
                                  data.status,
                              yValueMapper: (SubscriptionStatusData data, _) =>
                                  data.count,
                              dataLabelSettings: const DataLabelSettings(
                                isVisible: true,
                                labelPosition: ChartDataLabelPosition.outside,
                              ),
                              enableTooltip: true,
                            ),
                          ],
                          legend: Legend(
                            isVisible: true,
                            position: LegendPosition.bottom,
                            overflowMode: LegendItemOverflowMode.wrap,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
