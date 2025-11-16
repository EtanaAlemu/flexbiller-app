import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../invoices/presentation/bloc/invoice_multiselect_bloc.dart';
import '../../../invoices/presentation/bloc/events/invoice_multiselect_events.dart';
import '../../../invoices/presentation/widgets/export_invoices_dialog.dart';
import '../../../invoices/domain/entities/invoice.dart';
import '../../../../core/widgets/base_action_menu.dart';
import '../../../../core/widgets/sort_options_bottom_sheet.dart';

class InvoicesActionMenu extends StatelessWidget {
  final GlobalKey? invoicesViewKey;

  const InvoicesActionMenu({Key? key, this.invoicesViewKey}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final menuItems = [
      ...BaseActionMenu.buildFilterSortSection(
        searchLabel: 'Search Invoices',
        filterLabel: 'Filter by Status',
      ),
      ...BaseActionMenu.buildActionsSection(exportLabel: 'Export Invoices'),
      const ActionMenuItem.divider(),
      const ActionMenuItem.sectionHeader('ANALYTICS'),
      const ActionMenuItem(
        value: 'statistics',
        label: 'Invoice Statistics',
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
        _exportInvoices(context);
        break;
      case 'refresh':
        _refreshInvoices(context);
        break;
      case 'statistics':
        _showInvoiceStatistics(context);
        break;
    }
  }

  void _toggleSearchBar(BuildContext context) {
    if (invoicesViewKey?.currentState != null) {
      (invoicesViewKey!.currentState as dynamic).toggleSearchBar();
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
                if (invoicesViewKey?.currentState != null) {
                  (invoicesViewKey!.currentState as dynamic).applyStatusFilter(
                    null,
                  );
                }
              },
            ),
            ListTile(
              title: const Text('Committed'),
              onTap: () {
                Navigator.pop(context);
                if (invoicesViewKey?.currentState != null) {
                  (invoicesViewKey!.currentState as dynamic).applyStatusFilter(
                    'COMMITTED',
                  );
                }
              },
            ),
            ListTile(
              title: const Text('Draft'),
              onTap: () {
                Navigator.pop(context);
                if (invoicesViewKey?.currentState != null) {
                  (invoicesViewKey!.currentState as dynamic).applyStatusFilter(
                    'DRAFT',
                  );
                }
              },
            ),
            ListTile(
              title: const Text('Void'),
              onTap: () {
                Navigator.pop(context);
                if (invoicesViewKey?.currentState != null) {
                  (invoicesViewKey!.currentState as dynamic).applyStatusFilter(
                    'VOID',
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showSortOptions(BuildContext context) {
    SortOptionsBottomSheet.show(
      context,
      title: 'Sort Invoices',
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
          title: 'Invoice Number',
          sortBy: 'number',
          sortOrder: 'asc',
          icon: Icons.numbers,
        ),
      ],
      onSortSelected: (sortBy, sortOrder) {
        if (invoicesViewKey?.currentState != null) {
          final sortType = '${sortBy}_$sortOrder';
          (invoicesViewKey!.currentState as dynamic).sortInvoices(sortType);
        }
      },
    );
  }

  void _exportInvoices(BuildContext context) {
    // Get all invoices first
    final invoicesViewState = invoicesViewKey?.currentState;
    if (invoicesViewState != null) {
      final allInvoices =
          (invoicesViewState as dynamic).allInvoices as List<Invoice>;

      // Enable multi-select mode and select all invoices
      context.read<InvoiceMultiSelectBloc>().add(
        EnableMultiSelectModeAndSelectAll(invoices: allInvoices),
      );

      // Show export dialog with all invoices
      _showExportDialog(context);
    } else {
      // Fallback: show message if InvoicesView is not available
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please wait for invoices to load'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Future<void> _showExportDialog(BuildContext context) async {
    // Get all invoices from the InvoicesView
    final invoicesViewState = invoicesViewKey?.currentState;
    if (invoicesViewState != null) {
      // Get all invoices from the InvoicesView state using the public getter
      final allInvoices =
          (invoicesViewState as dynamic).allInvoices as List<Invoice>;

      // Show export dialog for better user experience
      final result = await showDialog(
        context: context,
        builder: (context) => ExportInvoicesDialog(invoices: allInvoices),
      );
      if (result != null) {
        final selectedFormat = result['format'] as String;
        // Dispatch export event to BLoC
        context.read<InvoiceMultiSelectBloc>().add(
          BulkExportInvoices(selectedFormat),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to access invoices data')),
      );
    }
  }

  void _refreshInvoices(BuildContext context) {
    if (invoicesViewKey?.currentState != null) {
      (invoicesViewKey!.currentState as dynamic).refreshInvoices();
    }
  }

  void _showInvoiceStatistics(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Invoice Statistics'),
        content: const Text('Invoice statistics feature coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
