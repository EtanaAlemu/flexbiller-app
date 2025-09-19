import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/account_invoices_bloc.dart';
import '../bloc/account_invoices_event.dart';
import '../bloc/account_invoices_state.dart';
import '../../domain/entities/account_invoice.dart';
import '../../../../core/widgets/error_display_widget.dart';

class AccountInvoicesWidget extends StatefulWidget {
  final String accountId;

  const AccountInvoicesWidget({Key? key, required this.accountId})
    : super(key: key);

  @override
  State<AccountInvoicesWidget> createState() => _AccountInvoicesWidgetState();
}

class _AccountInvoicesWidgetState extends State<AccountInvoicesWidget> {
  @override
  void initState() {
    super.initState();
    // Load invoices when the widget is first created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AccountInvoicesBloc>().add(
        LoadAccountInvoices(accountId: widget.accountId),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccountInvoicesBloc, AccountInvoicesState>(
      builder: (context, state) {
        if (state is AccountInvoicesLoading) {
          return const LoadingWidget(message: 'Loading invoices...');
        }

        if (state is AccountInvoicesFailure) {
          return ErrorDisplayWidget(
            error: state.message,
            context: 'invoices',
            onRetry: () {
              context.read<AccountInvoicesBloc>().add(
                LoadAccountInvoices(accountId: widget.accountId),
              );
            },
          );
        }

        if (state is AccountInvoicesLoaded) {
          if (state.invoices.isEmpty) {
            return EmptyStateWidget(
              message: 'No invoices found',
              subtitle: 'This account doesn\'t have any invoices yet.',
              icon: Icons.receipt_outlined,
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<AccountInvoicesBloc>().add(
                RefreshAccountInvoices(accountId: widget.accountId),
              );
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: state.invoices.length,
              itemBuilder: (context, index) {
                final invoice = state.invoices[index];
                return _buildInvoiceCard(context, invoice);
              },
            ),
          );
        }

        // Default state - show loading
        return const LoadingWidget(message: 'Loading invoices...');
      },
    );
  }

  Widget _buildInvoiceCard(BuildContext context, AccountInvoice invoice) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: () => _navigateToInvoiceDetails(context, invoice),
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      invoice.invoiceNumber,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(invoice.status),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      invoice.status,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Amount: ${_formatCurrency(invoice.amount, invoice.currency)}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (invoice.balance > 0)
                    Text(
                      'Balance: ${_formatCurrency(invoice.balance, invoice.currency)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Date: ${_formatDate(invoice.invoiceDate)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              Text(
                'Due: ${_formatDate(invoice.targetDate)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return Colors.green;
      case 'unpaid':
        return Colors.red;
      case 'partially_paid':
        return Colors.orange;
      case 'cancelled':
        return Colors.grey;
      case 'refunded':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _formatCurrency(dynamic amount, String? currency) {
    if (amount == null) return 'N/A';
    final currencySymbol = currency == 'USD' ? '\$' : currency ?? '';
    return '$currencySymbol${amount.toStringAsFixed(2)}';
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'Unknown';
    try {
      if (date is String) {
        final parsedDate = DateTime.parse(date);
        return '${parsedDate.day}/${parsedDate.month}/${parsedDate.year}';
      } else if (date is DateTime) {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return 'Invalid date';
    }
    return 'Unknown';
  }

  void _navigateToInvoiceDetails(BuildContext context, AccountInvoice invoice) {
    // For now, just show a snackbar. In the future, this could navigate to an invoice details page
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Invoice ${invoice.invoiceNumber} details'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
