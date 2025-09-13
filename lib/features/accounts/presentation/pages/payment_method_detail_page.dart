import 'package:flutter/material.dart';
import '../../domain/entities/account_payment_method.dart';

class PaymentMethodDetailPage extends StatelessWidget {
  final AccountPaymentMethod paymentMethod;
  final String accountId;

  const PaymentMethodDetailPage({
    Key? key,
    required this.paymentMethod,
    required this.accountId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment Method Details'),
        actions: [
          if (!paymentMethod.isDefault && paymentMethod.isActive)
            IconButton(
              icon: const Icon(Icons.star),
              onPressed: () => _showSetDefaultDialog(context),
              tooltip: 'Set as Default',
            ),
          if (paymentMethod.isActive)
            IconButton(
              icon: const Icon(Icons.pause),
              onPressed: () => _showDeactivateDialog(context),
              tooltip: 'Deactivate',
            )
          else
            IconButton(
              icon: const Icon(Icons.play_arrow),
              onPressed: () => _showReactivateDialog(context),
              tooltip: 'Reactivate',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPaymentMethodHeader(context),
            const SizedBox(height: 24),
            _buildPaymentMethodInfoCard(context),
            const SizedBox(height: 16),
            _buildCardDetailsCard(context),
            const SizedBox(height: 16),
            _buildBankDetailsCard(context),
            const SizedBox(height: 16),
            _buildStatusCard(context),
            const SizedBox(height: 16),
            _buildActionsCard(context),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodHeader(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getPaymentMethodColor(
                  paymentMethod.paymentMethodType,
                ).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _getPaymentMethodColor(
                    paymentMethod.paymentMethodType,
                  ),
                  width: 2,
                ),
              ),
              child: Icon(
                _getPaymentMethodIcon(paymentMethod.paymentMethodType),
                size: 32,
                color: _getPaymentMethodColor(paymentMethod.paymentMethodType),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    paymentMethod.paymentMethodName,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    paymentMethod.paymentMethodType,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (paymentMethod.isDefault)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            'Default',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      if (paymentMethod.isDefault) const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: paymentMethod.isActive
                              ? Colors.green
                              : Colors.red,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          paymentMethod.isActive ? 'Active' : 'Inactive',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodInfoCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Payment Method Information',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('ID', paymentMethod.id),
            _buildInfoRow('Name', paymentMethod.paymentMethodName),
            _buildInfoRow('Type', paymentMethod.paymentMethodType),
            _buildInfoRow('Account ID', paymentMethod.accountId),
            _buildInfoRow('Created', _formatDateTime(paymentMethod.createdAt)),
            if (paymentMethod.updatedAt != null)
              _buildInfoRow(
                'Updated',
                _formatDateTime(paymentMethod.updatedAt!),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardDetailsCard(BuildContext context) {
    if (paymentMethod.cardLastFourDigits == null &&
        paymentMethod.cardBrand == null) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.credit_card,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Card Details',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (paymentMethod.cardBrand != null)
              _buildInfoRow('Brand', paymentMethod.cardBrand!),
            if (paymentMethod.cardLastFourDigits != null)
              _buildInfoRow(
                'Last 4 Digits',
                '•••• ${paymentMethod.cardLastFourDigits}',
              ),
            if (paymentMethod.cardExpiryMonth != null &&
                paymentMethod.cardExpiryYear != null)
              _buildInfoRow(
                'Expiry',
                '${paymentMethod.cardExpiryMonth}/${paymentMethod.cardExpiryYear}',
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBankDetailsCard(BuildContext context) {
    if (paymentMethod.bankName == null &&
        paymentMethod.bankAccountLastFourDigits == null) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.account_balance,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Bank Details',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (paymentMethod.bankName != null)
              _buildInfoRow('Bank Name', paymentMethod.bankName!),
            if (paymentMethod.bankAccountLastFourDigits != null)
              _buildInfoRow(
                'Account Last 4',
                '•••• ${paymentMethod.bankAccountLastFourDigits}',
              ),
            if (paymentMethod.bankAccountType != null)
              _buildInfoRow('Account Type', paymentMethod.bankAccountType!),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Status Information',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Is Default', paymentMethod.isDefault ? 'Yes' : 'No'),
            _buildInfoRow('Is Active', paymentMethod.isActive ? 'Yes' : 'No'),
            _buildInfoRow(
              'Status',
              paymentMethod.isActive ? 'Active' : 'Inactive',
            ),
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
                if (!paymentMethod.isDefault && paymentMethod.isActive)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showSetDefaultDialog(context),
                      icon: const Icon(Icons.star),
                      label: const Text('Set as Default'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                if (!paymentMethod.isDefault && paymentMethod.isActive)
                  const SizedBox(width: 12),
                Expanded(
                  child: paymentMethod.isActive
                      ? OutlinedButton.icon(
                          onPressed: () => _showDeactivateDialog(context),
                          icon: const Icon(Icons.pause),
                          label: const Text('Deactivate'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Theme.of(
                              context,
                            ).colorScheme.error,
                          ),
                        )
                      : OutlinedButton.icon(
                          onPressed: () => _showReactivateDialog(context),
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Reactivate'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Theme.of(
                              context,
                            ).colorScheme.primary,
                          ),
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

  void _showSetDefaultDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set as Default Payment Method'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Do you want to set "${paymentMethod.paymentMethodName}" as your default payment method?',
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Checkbox(
                  value: false,
                  onChanged: (value) {
                    // Handle checkbox state
                  },
                ),
                const Expanded(
                  child: Text(
                    'Pay all unpaid invoices with this payment method',
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement set default functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Set as default functionality coming soon'),
                  backgroundColor: Colors.blue,
                ),
              );
            },
            child: const Text('Set as Default'),
          ),
        ],
      ),
    );
  }

  void _showDeactivateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deactivate Payment Method'),
        content: Text(
          'Are you sure you want to deactivate "${paymentMethod.paymentMethodName}"? This will prevent it from being used for future payments.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement deactivate functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Deactivate functionality coming soon'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('Deactivate'),
          ),
        ],
      ),
    );
  }

  void _showReactivateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reactivate Payment Method'),
        content: Text(
          'Are you sure you want to reactivate "${paymentMethod.paymentMethodName}"? This will allow it to be used for future payments again.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement reactivate functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Reactivate functionality coming soon'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Reactivate'),
          ),
        ],
      ),
    );
  }

  IconData _getPaymentMethodIcon(String type) {
    switch (type.toUpperCase()) {
      case 'CREDIT_CARD':
      case 'DEBIT_CARD':
        return Icons.credit_card;
      case 'BANK_ACCOUNT':
      case 'ACH':
        return Icons.account_balance;
      case 'PAYPAL':
        return Icons.payment;
      case 'CASH':
        return Icons.money;
      case 'CHECK':
        return Icons.receipt;
      default:
        return Icons.payment;
    }
  }

  Color _getPaymentMethodColor(String type) {
    switch (type.toUpperCase()) {
      case 'CREDIT_CARD':
      case 'DEBIT_CARD':
        return Colors.blue;
      case 'BANK_ACCOUNT':
      case 'ACH':
        return Colors.green;
      case 'PAYPAL':
        return Colors.indigo;
      case 'CASH':
        return Colors.orange;
      case 'CHECK':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}
