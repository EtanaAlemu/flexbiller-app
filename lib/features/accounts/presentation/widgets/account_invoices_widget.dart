import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/account_invoices_bloc.dart';
import '../bloc/account_invoices_event.dart';
import '../bloc/account_invoices_state.dart';
import '../../domain/entities/account_invoice.dart';
import '../../../../core/widgets/error_display_widget.dart';
import 'invoice_detail_card.dart';

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
                return InvoiceDetailCard(
                  invoice: invoice,
                  onTap: () => _navigateToInvoiceDetails(context, invoice),
                );
              },
            ),
          );
        }

        // Default state - show loading
        return const LoadingWidget(message: 'Loading invoices...');
      },
    );
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
