import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/payment.dart';
import '../../domain/entities/payment_transaction.dart';

class PaymentDetailPage extends StatelessWidget {
  final Payment payment;

  const PaymentDetailPage({super.key, required this.payment});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: payment.currency);
    final dateFormat = DateFormat('MMM dd, yyyy HH:mm');
    final latestTransaction = payment.transactions.isNotEmpty
        ? payment.transactions.first
        : null;

    return Scaffold(
      appBar: AppBar(
        title: Text('Payment #${payment.paymentNumber}'),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Payment Status Card
            _buildStatusCard(context, latestTransaction, currencyFormat),
            const SizedBox(height: 24),

            // Payment Overview
            _buildSectionHeader(context, 'Payment Overview'),
            const SizedBox(height: 12),
            _buildOverviewCard(context, currencyFormat, dateFormat),
            const SizedBox(height: 24),

            // Transaction Details
            _buildSectionHeader(context, 'Transaction Details'),
            const SizedBox(height: 12),
            _buildTransactionsList(context, currencyFormat, dateFormat),
            const SizedBox(height: 24),

            // Payment Method & Account Info
            _buildSectionHeader(context, 'Payment Information'),
            const SizedBox(height: 12),
            _buildPaymentInfoCard(context),
            const SizedBox(height: 24),

            // Audit Logs (if available)
            if (payment.auditLogs.isNotEmpty) ...[
              _buildSectionHeader(context, 'Audit Logs'),
              const SizedBox(height: 12),
              _buildAuditLogsCard(context, dateFormat),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(
    BuildContext context,
    PaymentTransaction? latestTransaction,
    NumberFormat currencyFormat,
  ) {
    final status = latestTransaction?.status ?? 'Unknown';
    final statusColor = _getStatusColor(status);
    final statusIcon = _getStatusIcon(status);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              statusColor.withOpacity(0.1),
              statusColor.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(40),
              ),
              child: Icon(statusIcon, color: Colors.white, size: 40),
            ),
            const SizedBox(height: 16),
            Text(
              status.toUpperCase(),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              currencyFormat.format(payment.purchasedAmount),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            if (latestTransaction != null) ...[
              const SizedBox(height: 8),
              Text(
                'Processed on ${DateFormat('MMM dd, yyyy').format(latestTransaction.effectiveDate)}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }

  Widget _buildOverviewCard(
    BuildContext context,
    NumberFormat currencyFormat,
    DateFormat dateFormat,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildInfoRow(
              context,
              'Payment Number',
              payment.paymentNumber,
              Icons.receipt_long,
            ),
            const Divider(),
            _buildInfoRow(
              context,
              'External Key',
              payment.paymentExternalKey,
              Icons.key,
            ),
            const Divider(),
            _buildInfoRow(
              context,
              'Account ID',
              payment.accountId,
              Icons.account_circle,
            ),
            const Divider(),
            _buildInfoRow(
              context,
              'Payment Method ID',
              payment.paymentMethodId,
              Icons.credit_card,
            ),
            const Divider(),
            _buildAmountRow(
              context,
              'Authorized Amount',
              payment.authAmount,
              currencyFormat,
              Icons.check_circle_outline,
            ),
            const Divider(),
            _buildAmountRow(
              context,
              'Captured Amount',
              payment.capturedAmount,
              currencyFormat,
              Icons.money,
            ),
            const Divider(),
            _buildAmountRow(
              context,
              'Purchased Amount',
              payment.purchasedAmount,
              currencyFormat,
              Icons.shopping_cart,
            ),
            if (payment.refundedAmount > 0) ...[
              const Divider(),
              _buildAmountRow(
                context,
                'Refunded Amount',
                payment.refundedAmount,
                currencyFormat,
                Icons.undo,
                isRefund: true,
              ),
            ],
            if (payment.creditedAmount > 0) ...[
              const Divider(),
              _buildAmountRow(
                context,
                'Credited Amount',
                payment.creditedAmount,
                currencyFormat,
                Icons.add_circle_outline,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionsList(
    BuildContext context,
    NumberFormat currencyFormat,
    DateFormat dateFormat,
  ) {
    if (payment.transactions.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.receipt_long_outlined,
                  size: 48,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.5),
                ),
                const SizedBox(height: 12),
                Text(
                  'No transactions found',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      child: Column(
        children: payment.transactions.asMap().entries.map((entry) {
          final index = entry.key;
          final transaction = entry.value;
          final isLast = index == payment.transactions.length - 1;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: _getStatusColor(transaction.status),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            _getTransactionIcon(transaction.transactionType),
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                transaction.transactionType.toUpperCase(),
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              Text(
                                transaction.status.toUpperCase(),
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: _getStatusColor(
                                        transaction.status,
                                      ),
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              currencyFormat.format(transaction.amount),
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                            ),
                            Text(
                              dateFormat.format(transaction.effectiveDate),
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface.withOpacity(0.7),
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildTransactionDetails(
                      context,
                      transaction,
                      currencyFormat,
                    ),
                  ],
                ),
              ),
              if (!isLast) const Divider(height: 1),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTransactionDetails(
    BuildContext context,
    PaymentTransaction transaction,
    NumberFormat currencyFormat,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          if (transaction.transactionExternalKey.isNotEmpty)
            _buildDetailRow(
              context,
              'Transaction External Key',
              transaction.transactionExternalKey,
            ),
          if (transaction.processedAmount != transaction.amount)
            _buildDetailRow(
              context,
              'Processed Amount',
              currencyFormat.format(transaction.processedAmount),
            ),
          if (transaction.processedCurrency != transaction.currency)
            _buildDetailRow(
              context,
              'Processed Currency',
              transaction.processedCurrency,
            ),
          if (transaction.gatewayErrorCode != null)
            _buildDetailRow(
              context,
              'Gateway Error Code',
              transaction.gatewayErrorCode!,
              isError: true,
            ),
          if (transaction.gatewayErrorMsg != null)
            _buildDetailRow(
              context,
              'Gateway Error Message',
              transaction.gatewayErrorMsg!,
              isError: true,
            ),
          if (transaction.firstPaymentReferenceId != null)
            _buildDetailRow(
              context,
              'First Payment Reference',
              transaction.firstPaymentReferenceId!,
            ),
          if (transaction.secondPaymentReferenceId != null)
            _buildDetailRow(
              context,
              'Second Payment Reference',
              transaction.secondPaymentReferenceId!,
            ),
        ],
      ),
    );
  }

  Widget _buildPaymentInfoCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildInfoRow(
              context,
              'Currency',
              payment.currency,
              Icons.attach_money,
            ),
            const Divider(),
            _buildInfoRow(
              context,
              'Payment Attempts',
              payment.paymentAttempts?.length.toString() ?? '0',
              Icons.repeat,
            ),
            const Divider(),
            _buildInfoRow(
              context,
              'Total Transactions',
              payment.transactions.length.toString(),
              Icons.list_alt,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuditLogsCard(BuildContext context, DateFormat dateFormat) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: payment.auditLogs.asMap().entries.map((entry) {
            final index = entry.key;
            final log = entry.value;
            final isLast = index == payment.auditLogs.length - 1;

            return Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.history,
                      size: 20,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            log['action']?.toString() ?? 'Unknown Action',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w500),
                          ),
                          if (log['timestamp'] != null)
                            Text(
                              dateFormat.format(
                                DateTime.parse(log['timestamp']),
                              ),
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface.withOpacity(0.7),
                                  ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (!isLast) const SizedBox(height: 12),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              Text(
                value,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAmountRow(
    BuildContext context,
    String label,
    double amount,
    NumberFormat currencyFormat,
    IconData icon, {
    bool isRefund = false,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: isRefund ? Colors.red : Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              Text(
                currencyFormat.format(amount),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: isRefund
                      ? Colors.red
                      : Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value, {
    bool isError = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isError
                    ? Colors.red
                    : Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toUpperCase()) {
      case 'SUCCESS':
      case 'COMPLETED':
        return Colors.green;
      case 'FAILED':
      case 'ERROR':
        return Colors.red;
      case 'PENDING':
        return Colors.orange;
      case 'CANCELLED':
        return Colors.grey;
      case 'PROCESSING':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String? status) {
    switch (status?.toUpperCase()) {
      case 'SUCCESS':
      case 'COMPLETED':
        return Icons.check_circle;
      case 'FAILED':
      case 'ERROR':
        return Icons.error;
      case 'PENDING':
        return Icons.schedule;
      case 'CANCELLED':
        return Icons.cancel;
      case 'PROCESSING':
        return Icons.sync;
      default:
        return Icons.payment;
    }
  }

  IconData _getTransactionIcon(String transactionType) {
    switch (transactionType.toUpperCase()) {
      case 'AUTHORIZE':
        return Icons.lock;
      case 'CAPTURE':
        return Icons.money;
      case 'REFUND':
        return Icons.undo;
      case 'VOID':
        return Icons.cancel;
      case 'CREDIT':
        return Icons.add_circle;
      default:
        return Icons.receipt_long;
    }
  }
}
