import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/subscription_trend.dart';

class SubscriptionTrendsChart extends StatelessWidget {
  final SubscriptionTrends trends;
  final int selectedYear;
  final Function(int, BuildContext) onYearChanged;

  const SubscriptionTrendsChart({
    Key? key,
    required this.trends,
    required this.selectedYear,
    required this.onYearChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with title and year selector
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title section - flexible to prevent overflow
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Subscription Trends',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$selectedYear yearly data',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.6),
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Year picker button
                OutlinedButton.icon(
                  onPressed: () => _showYearPicker(context),
                  icon: const Icon(Icons.calendar_today, size: 18),
                  label: Text(
                    selectedYear.toString(),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Chart
            SizedBox(
              height: 300,
              child: SfCartesianChart(
                primaryXAxis: CategoryAxis(labelRotation: -45),
                primaryYAxis: NumericAxis(numberFormat: NumberFormat.compact()),
                legend: Legend(
                  isVisible: true,
                  position: LegendPosition.bottom,
                  overflowMode: LegendItemOverflowMode.scroll,
                ),
                tooltipBehavior: TooltipBehavior(enable: true),
                series: <CartesianSeries>[
                  // New Subscriptions spline (smooth continuous curve)
                  SplineSeries<SubscriptionTrend, String>(
                    dataSource: trends.trends,
                    xValueMapper: (SubscriptionTrend data, _) => data.month,
                    yValueMapper: (SubscriptionTrend data, _) =>
                        data.newSubscriptions,
                    name: 'New Subscriptions',
                    color: Colors.green,
                    width: 3,
                    splineType: SplineType.cardinal,
                    markerSettings: const MarkerSettings(
                      isVisible: true,
                      height: 6,
                      width: 6,
                      shape: DataMarkerType.circle,
                    ),
                  ),
                  // Churned Subscriptions spline (smooth continuous curve)
                  SplineSeries<SubscriptionTrend, String>(
                    dataSource: trends.trends,
                    xValueMapper: (SubscriptionTrend data, _) => data.month,
                    yValueMapper: (SubscriptionTrend data, _) =>
                        data.churnedSubscriptions,
                    name: 'Churned Subscriptions',
                    color: Colors.red,
                    width: 3,
                    splineType: SplineType.cardinal,
                    markerSettings: const MarkerSettings(
                      isVisible: true,
                      height: 6,
                      width: 6,
                      shape: DataMarkerType.circle,
                    ),
                  ),
                  // Revenue spline (smooth continuous curve)
                  SplineSeries<SubscriptionTrend, String>(
                    dataSource: trends.trends,
                    xValueMapper: (SubscriptionTrend data, _) => data.month,
                    yValueMapper: (SubscriptionTrend data, _) => data.revenue,
                    name: 'Revenue (\$)',
                    color: Colors.blue,
                    width: 3,
                    splineType: SplineType.cardinal,
                    yAxisName: 'secondary',
                    markerSettings: const MarkerSettings(
                      isVisible: true,
                      height: 6,
                      width: 6,
                      shape: DataMarkerType.circle,
                    ),
                  ),
                ],
                // Secondary Y-axis for Revenue
                axes: <ChartAxis>[
                  NumericAxis(
                    name: 'secondary',
                    opposedPosition: true,
                    numberFormat: NumberFormat.currency(symbol: '\$'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showYearPicker(BuildContext context) {
    final currentYear = DateTime.now().year;
    final startYear = 2021; // Start from 2021
    final endYear = currentYear; // Up to current year (not greater)
    final years = List.generate(
      endYear - startYear + 1,
      (index) => startYear + index,
    ).reversed.toList();

    // Store the widget context to use in the dialog callbacks
    final widgetContext = context;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Select Year'),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: ListView.builder(
              itemCount: years.length,
              itemBuilder: (dialogContext, index) {
                final year = years[index];
                final isSelected = year == selectedYear;
                return ListTile(
                  title: Text(
                    year.toString(),
                    style: TextStyle(
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isSelected
                          ? Theme.of(widgetContext).colorScheme.primary
                          : null,
                    ),
                  ),
                  trailing: isSelected
                      ? Icon(
                          Icons.check,
                          color: Theme.of(widgetContext).colorScheme.primary,
                        )
                      : null,
                  onTap: () {
                    Navigator.of(dialogContext).pop();
                    if (year != selectedYear) {
                      // Use the widget context that has access to the BLoC
                      onYearChanged(year, widgetContext);
                    }
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}
