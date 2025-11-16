import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/payment_status_overview.dart';

class PaymentStatusOverviewChart extends StatelessWidget {
  final PaymentStatusOverviews overview;
  final int selectedYear;
  final Function(int, BuildContext) onYearChanged;

  const PaymentStatusOverviewChart({
    Key? key,
    required this.overview,
    required this.selectedYear,
    required this.onYearChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Card(
        elevation: 0.2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with title and year selector
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 4.0,
                ),
                child: Row(
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
                            'Payment Status Overview',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$selectedYear yearly data',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withOpacity(0.6),
                                  fontSize: 11,
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
                      icon: const Icon(Icons.calendar_today, size: 16),
                      label: Text(
                        selectedYear.toString(),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        minimumSize: const Size(0, 32),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // Chart
              SizedBox(
                height: 350,
                child: SfCartesianChart(
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  primaryXAxis: CategoryAxis(
                    labelRotation: -45,
                    labelStyle: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  primaryYAxis: NumericAxis(
                    numberFormat: NumberFormat.compact(),
                    labelStyle: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  legend: Legend(
                    isVisible: true,
                    position: LegendPosition.bottom,
                    overflowMode: LegendItemOverflowMode.scroll,
                    textStyle: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  tooltipBehavior: TooltipBehavior(
                    enable: true,
                    color: Theme.of(context).colorScheme.surface,
                    textStyle: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  series: <CartesianSeries>[
                    // Paid Invoices spline (smooth continuous curve)
                    SplineSeries<PaymentStatusOverview, String>(
                      dataSource: overview.overviews,
                      xValueMapper: (PaymentStatusOverview data, _) =>
                          data.month,
                      yValueMapper: (PaymentStatusOverview data, _) =>
                          data.paidInvoices,
                      name: 'Paid Invoices',
                      color: Theme.of(context).colorScheme.primary,
                      width: 3,
                      splineType: SplineType.natural,
                      markerSettings: MarkerSettings(
                        isVisible: true,
                        height: 6,
                        width: 6,
                        shape: DataMarkerType.circle,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    // Unpaid Invoices spline (smooth continuous curve)
                    SplineSeries<PaymentStatusOverview, String>(
                      dataSource: overview.overviews,
                      xValueMapper: (PaymentStatusOverview data, _) =>
                          data.month,
                      yValueMapper: (PaymentStatusOverview data, _) =>
                          data.unpaidInvoices,
                      name: 'Unpaid Invoices',
                      color: Theme.of(context).colorScheme.error,
                      width: 3,
                      splineType: SplineType.natural,
                      markerSettings: MarkerSettings(
                        isVisible: true,
                        height: 6,
                        width: 6,
                        shape: DataMarkerType.circle,
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
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

    // Store the widget context to use in the bottom sheet callbacks
    final widgetContext = context;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext bottomSheetContext) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Title
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                child: Text(
                  'Select Year',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              // Year list
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: years.length,
                  itemBuilder: (bottomSheetContext, index) {
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
                          fontSize: isSelected ? 18 : 16,
                        ),
                      ),
                      trailing: isSelected
                          ? Icon(
                              Icons.check,
                              color: Theme.of(
                                widgetContext,
                              ).colorScheme.primary,
                            )
                          : null,
                      onTap: () {
                        Navigator.of(bottomSheetContext).pop();
                        if (year != selectedYear) {
                          // Use the widget context that has access to the BLoC
                          onYearChanged(year, widgetContext);
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
