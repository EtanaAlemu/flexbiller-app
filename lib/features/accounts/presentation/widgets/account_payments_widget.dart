import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/account_payment.dart';
import '../bloc/accounts_bloc.dart';
import '../bloc/accounts_event.dart';
import '../bloc/accounts_state.dart';
import 'create_account_payment_form.dart';

class AccountPaymentsWidget extends StatelessWidget {
  final String accountId;

  const AccountPaymentsWidget({Key? key, required this.accountId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccountsBloc, AccountsState>(
      builder: (context, state) {
        if (state is AccountPaymentsLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is AccountPaymentsFailure) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'Failed to load payments',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  state.message,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<AccountsBloc>().add(LoadAccountPayments(accountId));
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (state is AccountPaymentsLoaded) {
          return Scaffold(
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Payments (${state.payments.length})',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: () {
                        context.read<AccountsBloc>().add(RefreshAccountPayments(accountId));
                      },
                      tooltip: 'Refresh Payments',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (state.payments.isEmpty)
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.payment_outlined,
                          size: 64,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No payments found',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'This account has no payment history',
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => _showCreatePaymentForm(context),
                          icon: const Icon(Icons.add),
                          label: const Text('Create First Payment'),
                        ),
                      ],
                    ),
                  )
                else
                  Expanded(
                    child: ListView.builder(
                      itemCount: state.payments.length,
                      itemBuilder: (context, index) {
                        final payment = state.payments[index];
                        return _buildPaymentCard(context, payment);
                      },
                    ),
                  ),
              ],
            ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () => _showCreatePaymentForm(context),
              icon: const Icon(Icons.add),
              label: const Text('New Payment'),
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
          );
        }

        return const Center(child: Text('No payment data available'));
      },
    );
  }

  void _showCreatePaymentForm(BuildContext context) {
    // For now, we'll show a placeholder. In a real app, you'd get the available payment methods
    // from the account payment methods state or pass them as a parameter
    final availablePaymentMethods = ['placeholder-payment-method-id'];
    
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CreateAccountPaymentForm(
          accountId: accountId,
          availablePaymentMethods: availablePaymentMethods,
        ),
      ),
    );
  }

  Widget _buildPaymentCard(BuildContext context, AccountPayment payment) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getPaymentStatusIcon(payment.paymentStatus),
                  color: _getPaymentStatusColor(payment.paymentStatus),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${payment.currency} ${payment.amount.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        payment.paymentType,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getPaymentStatusColor(payment.paymentStatus).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    payment.paymentStatus,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: _getPaymentStatusColor(payment.paymentStatus),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  size: 16,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
                const SizedBox(width: 4),
                Text(
                  'Date: ${_formatDateTime(payment.paymentDate)}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(width: 16),
                if (payment.processedDate != null) ...[
                  Icon(
                    Icons.check_circle,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Processed: ${_formatDateTime(payment.processedDate!)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ],
            ),
            if (payment.paymentMethodName != null || payment.paymentMethodType != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.payment,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                  const SizedBox(width: 4),
                  if (payment.paymentMethodName != null) ...[
                    Text(
                      payment.paymentMethodName!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(width: 8),
                  ],
                  if (payment.paymentMethodType != null) ...[
                    Text(
                      '(${payment.paymentMethodType})',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ],
              ),
            ],
            if (payment.transactionId != null || payment.referenceNumber != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  if (payment.transactionId != null) ...[
                    Icon(
                      Icons.receipt,
                      size: 16,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'TXN: ${payment.transactionId}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontFamily: 'monospace',
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                  if (payment.referenceNumber != null) ...[
                    Icon(
                      Icons.tag,
                      size: 16,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Ref: ${payment.referenceNumber}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ],
              ),
            ],
            if (payment.description != null || payment.notes != null) ...[
              const SizedBox(height: 8),
              if (payment.description != null) ...[
                Row(
                  children: [
                    Icon(
                      Icons.description,
                      size: 16,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        payment.description!,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
              ],
              if (payment.notes != null) ...[
                Row(
                  children: [
                    Icon(
                      Icons.note,
                      size: 16,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        payment.notes!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
            if (payment.isRefunded) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.undo,
                      size: 16,
                      color: Colors.orange,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Refunded',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (payment.refundedAmount != null) ...[
                            Text(
                              'Amount: ${payment.currency} ${payment.refundedAmount!.toStringAsFixed(2)}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.orange,
                              ),
                            ),
                          ],
                          if (payment.refundReason != null) ...[
                            Text(
                              'Reason: ${payment.refundReason}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.orange,
                              ),
                            ),
                          ],
                          if (payment.refundedDate != null) ...[
                            Text(
                              'Date: ${_formatDateTime(payment.refundedDate!)}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.orange,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (payment.failureReason != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Theme.of(context).colorScheme.error.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 16,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Payment Failed',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.error,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            payment.failureReason!,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                          if (payment.gatewayResponse != null) ...[
                            Text(
                              'Gateway: ${payment.gatewayResponse}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.error,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getPaymentStatusIcon(String status) {
    switch (status.toUpperCase()) {
      case 'SUCCESSFUL':
      case 'COMPLETED':
        return Icons.check_circle;
      case 'PENDING':
        return Icons.schedule;
      case 'FAILED':
      case 'DECLINED':
        return Icons.error;
      case 'CANCELLED':
        return Icons.cancel;
      case 'REFUNDED':
        return Icons.undo;
      case 'PROCESSING':
        return Icons.sync;
      default:
        return Icons.payment;
    }
  }

  Color _getPaymentStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'SUCCESSFUL':
      case 'COMPLETED':
        return Colors.green;
      case 'PENDING':
      case 'PROCESSING':
        return Colors.orange;
      case 'FAILED':
      case 'DECLINED':
        return Colors.red;
      case 'CANCELLED':
        return Colors.grey;
      case 'REFUNDED':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
