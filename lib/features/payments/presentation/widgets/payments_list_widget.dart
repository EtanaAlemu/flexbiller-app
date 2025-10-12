import 'package:flexbiller_app/features/payments/presentation/bloc/states/payment_multiselect_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/payment.dart';
import '../pages/payment_detail_page.dart';
import '../bloc/payment_multiselect_bloc.dart';
import '../bloc/events/payment_multiselect_events.dart';

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
    return BlocBuilder<PaymentMultiSelectBloc, PaymentMultiSelectState>(
      builder: (context, state) {
        final multiSelectBloc = context.read<PaymentMultiSelectBloc>();
        final isMultiSelectMode = multiSelectBloc.isMultiSelectMode;
        final isSelected = multiSelectBloc.isPaymentSelected(payment);

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
                _navigateToPaymentDetail(context);
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

                  // Payment Info
                  Expanded(child: _buildPaymentInfo(context)),

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
    final latestTransaction = payment.transactions.isNotEmpty
        ? payment.transactions.first
        : null;

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: _getStatusColor(latestTransaction?.status),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Icon(
        _getStatusIcon(latestTransaction?.status),
        color: Colors.white,
        size: 24,
      ),
    );
  }

  Widget _buildPaymentInfo(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: payment.currency);
    final dateFormat = DateFormat('MMM dd, yyyy');
    final latestTransaction = payment.transactions.isNotEmpty
        ? payment.transactions.first
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment #${payment.paymentNumber}',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text(
          currencyFormat.format(payment.purchasedAmount),
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 2),
        if (latestTransaction != null)
          Text(
            '${latestTransaction.status} • ${dateFormat.format(latestTransaction.effectiveDate)}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
      ],
    );
  }

  void _toggleSelection(BuildContext context) {
    final multiSelectBloc = context.read<PaymentMultiSelectBloc>();
    if (multiSelectBloc.isPaymentSelected(payment)) {
      multiSelectBloc.add(DeselectPayment(payment));
    } else {
      multiSelectBloc.add(SelectPayment(payment));
    }
  }

  void _enableMultiSelectModeAndSelect(BuildContext context) {
    context.read<PaymentMultiSelectBloc>().add(
      EnableMultiSelectModeAndSelect(payment),
    );
  }

  void _navigateToPaymentDetail(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PaymentDetailPage(payment: payment),
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
