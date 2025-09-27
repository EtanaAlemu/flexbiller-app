import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class DashboardDatePicker extends StatefulWidget {
  final Function(DateTime, DateTime) onDateRangeChanged;
  final DateTime? startDate;
  final DateTime? endDate;

  const DashboardDatePicker({
    Key? key,
    required this.onDateRangeChanged,
    this.startDate,
    this.endDate,
  }) : super(key: key);

  @override
  State<DashboardDatePicker> createState() => _DashboardDatePickerState();
}

class _DashboardDatePickerState extends State<DashboardDatePicker> {
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _startDate = widget.startDate;
    _endDate = widget.endDate;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Date Range Filter',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: SfDateRangePicker(
                view: DateRangePickerView.month,
                selectionMode: DateRangePickerSelectionMode.range,
                initialSelectedRange: PickerDateRange(_startDate, _endDate),
                onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
                  if (args.value is PickerDateRange) {
                    final range = args.value as PickerDateRange;
                    setState(() {
                      _startDate = range.startDate;
                      _endDate = range.endDate;
                    });
                    if (_startDate != null && _endDate != null) {
                      widget.onDateRangeChanged(_startDate!, _endDate!);
                    }
                  }
                },
                headerStyle: DateRangePickerHeaderStyle(
                  textAlign: TextAlign.center,
                  textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                rangeTextStyle: Theme.of(context).textTheme.bodyMedium,
                selectionTextStyle: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.white),
                selectionColor: Colors.blue,
                startRangeSelectionColor: Colors.blue,
                endRangeSelectionColor: Colors.blue,
                rangeSelectionColor: Colors.blue.withOpacity(0.3),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Start: ${_startDate?.toString().split(' ')[0] ?? 'Not selected'}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'End: ${_endDate?.toString().split(' ')[0] ?? 'Not selected'}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


