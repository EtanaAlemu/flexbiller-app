import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../payments/presentation/bloc/payment_multiselect_bloc.dart';
import '../../../payments/presentation/bloc/events/payment_multiselect_events.dart';
import '../../../payments/presentation/widgets/export_payments_dialog.dart';
import '../../../payments/domain/entities/payment.dart';
import '../../../../core/widgets/base_action_menu.dart';
import '../../../../core/widgets/sort_options_bottom_sheet.dart';

class PaymentsActionMenu extends StatelessWidget {
  final GlobalKey? paymentsViewKey;

  const PaymentsActionMenu({Key? key, this.paymentsViewKey}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final menuItems = [
      ...BaseActionMenu.buildFilterSortSection(
        searchLabel: 'Search Payments',
        filterLabel: 'Filter by Status',
      ),
      ...BaseActionMenu.buildActionsSection(exportLabel: 'Export Payments'),
      const ActionMenuItem.divider(),
      const ActionMenuItem.sectionHeader('ANALYTICS'),
      const ActionMenuItem(
        value: 'statistics',
        label: 'Payment Statistics',
        icon: Icons.analytics_rounded,
      ),
    ];

    return BaseActionMenu(
      menuItems: menuItems,
      onActionSelected: (value) => _handleMenuAction(context, value),
      icon: Icons.more_vert_rounded,
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
    SortOptionsBottomSheet.show(
      context,
      title: 'Sort Payments',
      options: const [
        SortOption(
          title: 'Date (Newest First)',
          sortBy: 'date',
          sortOrder: 'desc',
          icon: Icons.calendar_today,
        ),
        SortOption(
          title: 'Date (Oldest First)',
          sortBy: 'date',
          sortOrder: 'asc',
          icon: Icons.calendar_today,
        ),
        SortOption(
          title: 'Amount (Highest First)',
          sortBy: 'amount',
          sortOrder: 'desc',
          icon: Icons.attach_money,
        ),
        SortOption(
          title: 'Amount (Lowest First)',
          sortBy: 'amount',
          sortOrder: 'asc',
          icon: Icons.attach_money,
        ),
        SortOption(
          title: 'Payment Number',
          sortBy: 'number',
          sortOrder: 'asc',
          icon: Icons.numbers,
        ),
      ],
      onSortSelected: (sortBy, sortOrder) {
        final sortType = '${sortBy}_$sortOrder';
        _sortPayments(context, sortType);
      },
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

  Future<void> _showExportDialog(BuildContext context) async {
    // Get all payments from the PaymentsView
    final paymentsViewState = paymentsViewKey?.currentState;
    if (paymentsViewState != null) {
      // Get all payments from the PaymentsView state using the public getter
      final allPayments =
          (paymentsViewState as dynamic).allPayments as List<Payment>;

      // Show export dialog for better user experience
      final result = await showDialog(
        context: context,
        builder: (context) => ExportPaymentsDialog(payments: allPayments),
      );
      if (result != null) {
        final selectedFormat = result['format'] as String;
        await _performExport(context, allPayments, selectedFormat);
      }
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
