import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../payments/presentation/bloc/payment_multiselect_bloc.dart';
import '../../../payments/presentation/bloc/events/payment_multiselect_events.dart';
import '../../../payments/presentation/widgets/export_payments_dialog.dart';
import '../../../payments/domain/entities/payment.dart';

class PaymentsActionMenu extends StatelessWidget {
  final GlobalKey? paymentsViewKey;

  const PaymentsActionMenu({Key? key, this.paymentsViewKey}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert_rounded),
      tooltip: 'More options',
      onSelected: (value) => _handleMenuAction(context, value),
      itemBuilder: (context) => [
        // Filter section
        PopupMenuItem<String>(
          enabled: false,
          child: Text(
            'FILTER & SORT',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        PopupMenuItem<String>(
          value: 'search',
          child: Row(
            children: [
              Icon(
                Icons.search_rounded,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              const SizedBox(width: 12),
              const Text('Search Payments'),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'filter',
          child: Row(
            children: [
              Icon(
                Icons.filter_list_rounded,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              const SizedBox(width: 12),
              const Text('Filter by Status'),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'sort',
          child: Row(
            children: [
              Icon(
                Icons.sort_rounded,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              const SizedBox(width: 12),
              const Text('Sort Options'),
            ],
          ),
        ),
        const PopupMenuDivider(),
        // Actions section
        PopupMenuItem<String>(
          enabled: false,
          child: Text(
            'ACTIONS',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        PopupMenuItem<String>(
          value: 'export',
          child: Row(
            children: [
              Icon(
                Icons.download_rounded,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              const SizedBox(width: 12),
              const Text('Export Payments'),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'refresh',
          child: Row(
            children: [
              Icon(
                Icons.refresh_rounded,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              const SizedBox(width: 12),
              const Text('Refresh Data'),
            ],
          ),
        ),
        const PopupMenuDivider(),
        // Analytics section
        PopupMenuItem<String>(
          enabled: false,
          child: Text(
            'ANALYTICS',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        PopupMenuItem<String>(
          value: 'statistics',
          child: Row(
            children: [
              Icon(
                Icons.analytics_rounded,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              const SizedBox(width: 12),
              const Text('Payment Statistics'),
            ],
          ),
        ),
      ],
    );
  }

  void _handleMenuAction(BuildContext context, String action) {
    switch (action) {
      case 'search':
        _toggleSearchBar(context);
        break;
      case 'filter':
        _showStatusFilter(context);
        break;
      case 'sort':
        _showSortOptions(context);
        break;
      case 'export':
        _exportPayments(context);
        break;
      case 'refresh':
        _refreshPayments(context);
        break;
      case 'statistics':
        _showPaymentStatistics(context);
        break;
    }
  }

  void _toggleSearchBar(BuildContext context) {
    if (paymentsViewKey?.currentState != null) {
      (paymentsViewKey!.currentState as dynamic).toggleSearchBar();
    }
  }

  void _showStatusFilter(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter by Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('All'),
              onTap: () {
                Navigator.pop(context);
                _applyStatusFilter(context, null);
              },
            ),
            ListTile(
              title: const Text('Success'),
              onTap: () {
                Navigator.pop(context);
                _applyStatusFilter(context, 'SUCCESS');
              },
            ),
            ListTile(
              title: const Text('Pending'),
              onTap: () {
                Navigator.pop(context);
                _applyStatusFilter(context, 'PENDING');
              },
            ),
            ListTile(
              title: const Text('Failed'),
              onTap: () {
                Navigator.pop(context);
                _applyStatusFilter(context, 'FAILED');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _applyStatusFilter(BuildContext context, String? status) {
    if (paymentsViewKey?.currentState != null) {
      (paymentsViewKey!.currentState as dynamic).applyStatusFilter(status);
    }
  }

  void _showSortOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sort Options'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Date (Newest First)'),
              onTap: () {
                Navigator.pop(context);
                _sortPayments(context, 'date_desc');
              },
            ),
            ListTile(
              title: const Text('Date (Oldest First)'),
              onTap: () {
                Navigator.pop(context);
                _sortPayments(context, 'date_asc');
              },
            ),
            ListTile(
              title: const Text('Amount (Highest First)'),
              onTap: () {
                Navigator.pop(context);
                _sortPayments(context, 'amount_desc');
              },
            ),
            ListTile(
              title: const Text('Amount (Lowest First)'),
              onTap: () {
                Navigator.pop(context);
                _sortPayments(context, 'amount_asc');
              },
            ),
            ListTile(
              title: const Text('Payment Number'),
              onTap: () {
                Navigator.pop(context);
                _sortPayments(context, 'number');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _sortPayments(BuildContext context, String sortType) {
    if (paymentsViewKey?.currentState != null) {
      (paymentsViewKey!.currentState as dynamic).sortPayments(sortType);
    }
  }

  void _exportPayments(BuildContext context) {
    // Get all payments first
    final paymentsViewState = paymentsViewKey?.currentState;
    if (paymentsViewState != null) {
      final allPayments =
          (paymentsViewState as dynamic).allPayments as List<Payment>;

      // Enable multi-select mode and select all payments
      context.read<PaymentMultiSelectBloc>().add(
        EnableMultiSelectModeAndSelectAll(payments: allPayments),
      );

      // Show export dialog with all payments
      _showExportDialog(context);
    } else {
      // Fallback: show message if PaymentsView is not available
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please wait for payments to load'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _showExportDialog(BuildContext context) {
    // Get all payments from the PaymentsView
    final paymentsViewState = paymentsViewKey?.currentState;
    if (paymentsViewState != null) {
      // Get all payments from the PaymentsView state using the public getter
      final allPayments =
          (paymentsViewState as dynamic).allPayments as List<Payment>;

      // Show export dialog for better user experience
      showDialog(
        context: context,
        builder: (context) => ExportPaymentsDialog(payments: allPayments),
      ).then((result) async {
        if (result != null) {
          final selectedFormat = result['format'] as String;
          await _performExport(context, allPayments, selectedFormat);
        }
      });
    } else {
      // Fallback: show message if PaymentsView is not available
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please wait for payments to load'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Future<void> _performExport(
    BuildContext context,
    List<Payment> paymentsToExport,
    String format,
  ) async {
    // Dispatch export event to BLoC - the BLoC will handle the export and emit states
    context.read<PaymentMultiSelectBloc>().add(BulkExportPayments(format));
  }

  void _refreshPayments(BuildContext context) {
    if (paymentsViewKey?.currentState != null) {
      (paymentsViewKey!.currentState as dynamic).refreshPayments();
    }
  }

  void _showPaymentStatistics(BuildContext context) {
    if (paymentsViewKey?.currentState != null) {
      (paymentsViewKey!.currentState as dynamic).showPaymentStatistics();
    }
  }
}
