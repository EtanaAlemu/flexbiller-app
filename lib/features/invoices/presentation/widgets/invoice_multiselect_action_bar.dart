import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/invoice.dart';
import '../bloc/invoice_multiselect_bloc.dart';
import '../bloc/events/invoice_multiselect_events.dart';
import '../bloc/states/invoice_multiselect_states.dart';
import 'export_invoices_dialog.dart';

class InvoiceMultiSelectActionBar extends StatelessWidget {
  final List<Invoice> invoices;

  const InvoiceMultiSelectActionBar({Key? key, required this.invoices})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InvoiceMultiSelectBloc, InvoiceMultiSelectState>(
      builder: (context, state) {
        final multiSelectBloc = context.read<InvoiceMultiSelectBloc>();
        final selectedCount = multiSelectBloc.selectedCount;
        final allSelected = selectedCount == invoices.length;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              // Close button
              IconButton(
                onPressed: () {
                  multiSelectBloc.add(const DisableMultiSelectMode());
                },
                icon: const Icon(Icons.close),
                tooltip: 'Close multi-select',
              ),

              const SizedBox(width: 8),

              // Selection count
              Flexible(
                child: Text(
                  '$selectedCount selected',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              const SizedBox(width: 8),

              // Select All / Deselect All button
              Flexible(
                child: TextButton(
                  onPressed: () {
                    if (allSelected) {
                      multiSelectBloc.add(const DeselectAllInvoices());
                    } else {
                      multiSelectBloc.add(
                        SelectAllInvoices(invoices: invoices),
                      );
                    }
                  },
                  child: Text(
                    allSelected ? 'Deselect All' : 'Select All',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),

              // Action buttons
              if (selectedCount > 0) ...[
                const SizedBox(width: 4),
                IconButton(
                  onPressed: () => _showDeleteDialog(context),
                  icon: const Icon(Icons.delete),
                  tooltip: 'Delete selected',
                  constraints: const BoxConstraints(
                    minWidth: 40,
                    minHeight: 40,
                  ),
                ),
                IconButton(
                  onPressed: () => _showExportDialog(context),
                  icon: const Icon(Icons.download),
                  tooltip: 'Export selected',
                  constraints: const BoxConstraints(
                    minWidth: 40,
                    minHeight: 40,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Future<void> _showExportDialog(BuildContext context) async {
    final multiSelectBloc = context.read<InvoiceMultiSelectBloc>();
    final selectedInvoices = multiSelectBloc.selectedInvoices;

    // Show export dialog for better user experience
    final result = await showDialog(
      context: context,
      builder: (context) => ExportInvoicesDialog(invoices: selectedInvoices),
    );
    if (result != null) {
      final selectedFormat = result['format'] as String;
      await _performExport(context, selectedInvoices, selectedFormat);
    }
  }

  Future<void> _performExport(
    BuildContext context,
    List<Invoice> invoicesToExport,
    String format,
  ) async {
    // Dispatch export event to BLoC - the BLoC will handle the export and emit states
    context.read<InvoiceMultiSelectBloc>().add(BulkExportInvoices(format));
  }

  void _showDeleteDialog(BuildContext context) {
    final multiSelectBloc = context.read<InvoiceMultiSelectBloc>();
    final selectedCount = multiSelectBloc.selectedCount;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Invoices'),
        content: Text(
          'Are you sure you want to delete $selectedCount selected invoice(s)? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              multiSelectBloc.add(const BulkDeleteInvoices());
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
