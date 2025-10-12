import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/invoice.dart';
import '../bloc/invoice_multiselect_bloc.dart';
import '../bloc/events/invoice_multiselect_events.dart';
import '../bloc/states/invoice_multiselect_states.dart';
import '../pages/invoice_detail_page.dart';

class InvoicesListWidget extends StatelessWidget {
  final List<Invoice> invoices;
  final bool isRefreshing;
  final Future<void> Function()? onRefresh;

  const InvoicesListWidget({
    super.key,
    required this.invoices,
    this.isRefreshing = false,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (invoices.isEmpty) {
      return RefreshIndicator(
        onRefresh: onRefresh ?? () async {},
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'No invoices available',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: onRefresh ?? () async {},
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: invoices.length,
            itemBuilder: (context, index) {
              final invoice = invoices[index];
              return InvoiceListItem(invoice: invoice);
            },
          ),
        ),
        if (isRefreshing)
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: LinearProgressIndicator(),
          ),
      ],
    );
  }
}

class InvoiceListItem extends StatelessWidget {
  final Invoice invoice;

  const InvoiceListItem({super.key, required this.invoice});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InvoiceMultiSelectBloc, InvoiceMultiSelectState>(
      builder: (context, state) {
        final multiSelectBloc = context.read<InvoiceMultiSelectBloc>();
        final isMultiSelectMode = multiSelectBloc.isMultiSelectMode;
        final isSelected = multiSelectBloc.isInvoiceSelected(invoice);

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: isSelected
                ? BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  )
                : BorderSide(
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withOpacity(0.1),
                    width: 1,
                  ),
          ),
          child: GestureDetector(
            onTap: () {
              if (isMultiSelectMode) {
                _toggleSelection(context);
              } else {
                _navigateToInvoiceDetail(context);
              }
            },
            onLongPress: () {
              if (!isMultiSelectMode) {
                _enableMultiSelectModeAndSelect(context);
              }
              // Provide haptic feedback
              HapticFeedback.mediumImpact();
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Status Icon with optional checkbox overlay
                  Stack(
                    children: [
                      // Always show status icon
                      _buildStatusIcon(context),

                      // Show checkbox overlay when in multi-select mode and selected
                      if (isMultiSelectMode && isSelected)
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Theme.of(context).colorScheme.primary,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 12,
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(width: 16),

                  // Invoice Info
                  Expanded(child: _buildInvoiceInfo(context)),

                  // Arrow Icon (only in normal mode)
                  if (!isMultiSelectMode)
                    Icon(
                      Icons.chevron_right,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.5),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusIcon(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: _getStatusColor(invoice.status),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Icon(
        _getStatusIcon(invoice.status),
        color: Colors.white,
        size: 24,
      ),
    );
  }

  Widget _buildInvoiceInfo(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: invoice.currency);
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Invoice #${invoice.invoiceNumber}',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text(
          currencyFormat.format(invoice.amount),
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '${invoice.status} • ${dateFormat.format(DateTime.parse(invoice.invoiceDate))}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  void _toggleSelection(BuildContext context) {
    final multiSelectBloc = context.read<InvoiceMultiSelectBloc>();
    if (multiSelectBloc.isInvoiceSelected(invoice)) {
      multiSelectBloc.add(DeselectInvoice(invoice));
    } else {
      multiSelectBloc.add(SelectInvoice(invoice));
    }
  }

  void _enableMultiSelectModeAndSelect(BuildContext context) {
    context.read<InvoiceMultiSelectBloc>().add(
      EnableMultiSelectModeAndSelect(invoice),
    );
  }

  void _navigateToInvoiceDetail(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => InvoiceDetailPage(invoice: invoice),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'COMMITTED':
        return Colors.green;
      case 'PENDING':
        return Colors.orange;
      case 'FAILED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toUpperCase()) {
      case 'COMMITTED':
        return Icons.check_circle;
      case 'PENDING':
        return Icons.schedule;
      case 'FAILED':
        return Icons.error;
      default:
        return Icons.receipt_long;
    }
  }
}
