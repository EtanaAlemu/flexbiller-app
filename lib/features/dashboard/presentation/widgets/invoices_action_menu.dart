import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../invoices/presentation/bloc/invoice_multiselect_bloc.dart';
import '../../../invoices/presentation/bloc/events/invoice_multiselect_events.dart';
import '../../../invoices/presentation/widgets/export_invoices_dialog.dart';
import '../../../invoices/domain/entities/invoice.dart';

class InvoicesActionMenu extends StatelessWidget {
  final GlobalKey? invoicesViewKey;

  const InvoicesActionMenu({Key? key, this.invoicesViewKey}) : super(key: key);

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
              const Text('Search Invoices'),
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
              const Text('Export Invoices'),
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
              const Text('Invoice Statistics'),
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
                if (invoicesViewKey?.currentState != null) {
                  (invoicesViewKey!.currentState as dynamic).sortInvoices(
                    'date_desc',
                  );
                }
              },
            ),
            ListTile(
              title: const Text('Date (Oldest First)'),
              onTap: () {
                Navigator.pop(context);
                if (invoicesViewKey?.currentState != null) {
                  (invoicesViewKey!.currentState as dynamic).sortInvoices(
                    'date_asc',
                  );
                }
              },
            ),
            ListTile(
              title: const Text('Amount (Highest First)'),
              onTap: () {
                Navigator.pop(context);
                if (invoicesViewKey?.currentState != null) {
                  (invoicesViewKey!.currentState as dynamic).sortInvoices(
                    'amount_desc',
                  );
                }
              },
            ),
            ListTile(
              title: const Text('Amount (Lowest First)'),
              onTap: () {
                Navigator.pop(context);
                if (invoicesViewKey?.currentState != null) {
                  (invoicesViewKey!.currentState as dynamic).sortInvoices(
                    'amount_asc',
                  );
                }
              },
            ),
            ListTile(
              title: const Text('Invoice Number'),
              onTap: () {
                Navigator.pop(context);
                if (invoicesViewKey?.currentState != null) {
                  (invoicesViewKey!.currentState as dynamic).sortInvoices(
                    'number',
                  );
                }
              },
            ),
          ],
        ),
      ),
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

  void _showExportDialog(BuildContext context) {
    // Get all invoices from the InvoicesView
    final invoicesViewState = invoicesViewKey?.currentState;
    if (invoicesViewState != null) {
      // Get all invoices from the InvoicesView state using the public getter
      final allInvoices =
          (invoicesViewState as dynamic).allInvoices as List<Invoice>;

      // Show export dialog for better user experience
      showDialog(
        context: context,
        builder: (context) => ExportInvoicesDialog(invoices: allInvoices),
      ).then((result) async {
        if (result != null) {
          final selectedFormat = result['format'] as String;
          // Dispatch export event to BLoC
          context.read<InvoiceMultiSelectBloc>().add(
            BulkExportInvoices(selectedFormat),
          );
        }
      });
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
