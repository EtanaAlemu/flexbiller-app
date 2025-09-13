import 'package:flutter/material.dart';

class PaymentDetailPage extends StatelessWidget {
  final dynamic payment;
  final String accountId;

  const PaymentDetailPage({
    Key? key,
    required this.payment,
    required this.accountId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment Details'),
        actions: [
          if (payment.paymentStatus == 'completed' &&
              payment.isRefunded != true)
            IconButton(
              icon: const Icon(Icons.undo),
              onPressed: () => _showRefundDialog(context),
              tooltip: 'Refund Payment',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPaymentHeader(context),
            const SizedBox(height: 24),
            _buildPaymentInfoCard(context),
            const SizedBox(height: 16),
            _buildTransactionDetailsCard(context),
            if (payment.isRefunded == true) ...[
              const SizedBox(height: 16),
              _buildRefundDetailsCard(context),
            ],
            const SizedBox(height: 16),
            _buildActionsCard(context),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentHeader(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getStatusColor(payment.paymentStatus).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _getStatusColor(payment.paymentStatus),
                  width: 2,
                ),
              ),
              child: Icon(
                _getPaymentIcon(payment.paymentType),
                size: 32,
                color: _getStatusColor(payment.paymentStatus),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    payment.paymentType ?? 'Unknown Type',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatCurrency(payment.amount, payment.currency),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(payment.paymentStatus),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      payment.paymentStatus ?? 'Unknown',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentInfoCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Payment Information',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Payment ID', payment.id ?? 'N/A'),
            _buildInfoRow('Type', payment.paymentType ?? 'N/A'),
            _buildInfoRow('Status', payment.paymentStatus ?? 'N/A'),
            _buildInfoRow(
              'Amount',
              _formatCurrency(payment.amount, payment.currency),
            ),
            _buildInfoRow('Currency', payment.currency ?? 'N/A'),
            _buildInfoRow('Method', payment.paymentMethodName ?? 'N/A'),
            _buildInfoRow('Date', _formatDate(payment.paymentDate)),
            if (payment.processedDate != null)
              _buildInfoRow('Processed', _formatDate(payment.processedDate)),
            if (payment.description != null)
              _buildInfoRow('Description', payment.description),
            if (payment.notes != null) _buildInfoRow('Notes', payment.notes),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionDetailsCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Transaction Details',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            if (payment.transactionId != null)
              _buildInfoRow('Transaction ID', payment.transactionId),
            if (payment.referenceNumber != null)
              _buildInfoRow('Reference Number', payment.referenceNumber),
            if (payment.gateway != null)
              _buildInfoRow('Gateway', payment.gateway),
            if (payment.gatewayTransactionId != null)
              _buildInfoRow(
                'Gateway Transaction ID',
                payment.gatewayTransactionId,
              ),
            if (payment.paymentMethodId != null)
              _buildInfoRow('Payment Method ID', payment.paymentMethodId),
            if (payment.accountId != null)
              _buildInfoRow('Account ID', payment.accountId),
          ],
        ),
      ),
    );
  }

  Widget _buildRefundDetailsCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.undo, color: Colors.orange, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Refund Information',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Refunded', 'Yes'),
            if (payment.refundedAmount != null)
              _buildInfoRow(
                'Refund Amount',
                _formatCurrency(payment.refundedAmount, payment.currency),
              ),
            if (payment.refundReason != null)
              _buildInfoRow('Refund Reason', payment.refundReason),
            if (payment.refundedDate != null)
              _buildInfoRow('Refund Date', _formatDate(payment.refundedDate)),
          ],
        ),
      ),
    );
  }

  Widget _buildActionsCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Actions',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                if (payment.paymentStatus == 'completed' &&
                    payment.isRefunded != true)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showRefundDialog(context),
                      icon: const Icon(Icons.undo),
                      label: const Text('Refund Payment'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                if (payment.paymentStatus == 'completed' &&
                    payment.isRefunded != true)
                  const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _printPayment(context),
                    icon: const Icon(Icons.print),
                    label: const Text('Print'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w400),
            ),
          ),
        ],
      ),
    );
  }

  void _showRefundDialog(BuildContext context) {
    final refundController = TextEditingController();
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Refund Payment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Payment: ${_formatCurrency(payment.amount, payment.currency)}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: refundController,
              decoration: const InputDecoration(
                labelText: 'Refund Amount',
                border: OutlineInputBorder(),
                prefixText: '\$',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Refund Reason',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final refundAmount =
                  double.tryParse(refundController.text) ?? 0.0;
              if (refundAmount > 0) {
                // TODO: Implement refund functionality when RefundAccountPayment event is available
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Refund functionality coming soon'),
                    backgroundColor: Colors.orange,
                  ),
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Refund'),
          ),
        ],
      ),
    );
  }

  void _printPayment(BuildContext context) {
    // TODO: Implement print functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Print functionality coming soon'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'completed':
      case 'success':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'failed':
      case 'error':
        return Colors.red;
      case 'cancelled':
        return Colors.grey;
      case 'processing':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getPaymentIcon(String? type) {
    switch (type?.toLowerCase()) {
      case 'credit':
        return Icons.add_circle_outline;
      case 'debit':
        return Icons.remove_circle_outline;
      case 'refund':
        return Icons.undo;
      default:
        return Icons.payment;
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
}
