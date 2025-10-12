import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/payment.dart';

class PaymentsListWidget extends StatelessWidget {
  final List<Payment> payments;
  final bool isRefreshing;

  const PaymentsListWidget({
    super.key,
    required this.payments,
    this.isRefreshing = false,
  });

  @override
  Widget build(BuildContext context) {
    if (payments.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.payment_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No payments available',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: () async {
            // This will be handled by the parent widget
          },
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: payments.length,
            itemBuilder: (context, index) {
              final payment = payments[index];
              return PaymentListItem(payment: payment);
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

class PaymentListItem extends StatelessWidget {
  final Payment payment;

  const PaymentListItem({super.key, required this.payment});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: payment.currency);
    final dateFormat = DateFormat('MMM dd, yyyy');

    // Get the latest transaction for display
    final latestTransaction = payment.transactions.isNotEmpty
        ? payment.transactions.first
        : null;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(latestTransaction?.status),
          child: Icon(
            _getStatusIcon(latestTransaction?.status),
            color: Colors.white,
          ),
        ),
        title: Text(
          'Payment #${payment.paymentNumber}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Amount: ${currencyFormat.format(payment.purchasedAmount)}'),
            if (latestTransaction != null) ...[
              Text('Status: ${latestTransaction.status}'),
              Text(
                'Date: ${dateFormat.format(latestTransaction.effectiveDate)}',
              ),
            ],
            Text('Account: ${payment.accountId.substring(0, 8)}...'),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              currencyFormat.format(payment.purchasedAmount),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            if (payment.refundedAmount > 0)
              Text(
                'Refunded: ${currencyFormat.format(payment.refundedAmount)}',
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
          ],
        ),
        onTap: () {
          // TODO: Navigate to payment detail page
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Payment ${payment.paymentNumber} details')),
          );
        },
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toUpperCase()) {
      case 'SUCCESS':
        return Colors.green;
      case 'FAILED':
        return Colors.red;
      case 'PENDING':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String? status) {
    switch (status?.toUpperCase()) {
      case 'SUCCESS':
        return Icons.check_circle;
      case 'FAILED':
        return Icons.error;
      case 'PENDING':
        return Icons.schedule;
      default:
        return Icons.payment;
    }
  }
}
