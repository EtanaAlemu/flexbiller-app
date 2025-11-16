import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/payment.dart';
import '../bloc/payment_multiselect_bloc.dart';
import '../bloc/events/payment_multiselect_events.dart';
import '../bloc/states/payment_multiselect_states.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../../core/widgets/delete_confirmation_dialog.dart';
import 'export_payments_dialog.dart';

class PaymentMultiSelectActionBar extends StatelessWidget {
  final List<Payment> payments;

  const PaymentMultiSelectActionBar({Key? key, required this.payments})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PaymentMultiSelectBloc, PaymentMultiSelectState>(
      builder: (context, state) {
        final multiSelectBloc = context.read<PaymentMultiSelectBloc>();
        final selectedCount = multiSelectBloc.selectedCount;
        final allSelected = selectedCount == payments.length;

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
                      multiSelectBloc.add(const DeselectAllPayments());
                    } else {
                      multiSelectBloc.add(
                        SelectAllPayments(payments: payments),
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
    final multiSelectBloc = context.read<PaymentMultiSelectBloc>();
    final selectedPayments = multiSelectBloc.selectedPayments;

    // Show export dialog for better user experience
    final result = await showDialog(
      context: context,
      builder: (context) => ExportPaymentsDialog(payments: selectedPayments),
    );
    if (result != null) {
      final selectedFormat = result['format'] as String;
      await _performExport(context, selectedPayments, selectedFormat);
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

  Future<void> _showDeleteDialog(BuildContext context) async {
    final multiSelectBloc = context.read<PaymentMultiSelectBloc>();
    final selectedCount = multiSelectBloc.selectedCount;

    final confirmed = await DeleteConfirmationDialog.show(
      context,
      title: 'Delete Payments',
      itemName: 'payment(s)',
      count: selectedCount,
    );

    if (confirmed) {
      _performDelete(context);
    }
  }

  void _performDelete(BuildContext context) {
    // Dispatch delete event to BLoC
    context.read<PaymentMultiSelectBloc>().add(const BulkDeletePayments());

    // Listen for delete completion
    context.read<PaymentMultiSelectBloc>().stream.listen((state) {
      if (state is BulkDeleteCompleted) {
        CustomSnackBar.showSuccess(
          context,
          message: 'Deleted ${state.count} payments successfully',
        );
      } else if (state is BulkDeleteFailed) {
        CustomSnackBar.showError(
          context,
          message: 'Delete failed: ${state.error}',
        );
      }
    });
  }
}
