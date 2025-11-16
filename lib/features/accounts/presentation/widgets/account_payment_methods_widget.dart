import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import '../../domain/entities/account_payment_method.dart';
import '../bloc/account_payment_methods_bloc.dart';
import '../bloc/events/account_payment_methods_events.dart';
import '../bloc/states/account_payment_methods_states.dart';
import '../pages/payment_method_detail_page.dart';

class AccountPaymentMethodsWidget extends StatefulWidget {
  final String accountId;

  const AccountPaymentMethodsWidget({Key? key, required this.accountId})
    : super(key: key);

  @override
  State<AccountPaymentMethodsWidget> createState() =>
      _AccountPaymentMethodsWidgetState();
}

class _AccountPaymentMethodsWidgetState
    extends State<AccountPaymentMethodsWidget> {
  final Logger _logger = Logger();

  @override
  void initState() {
    super.initState();
    _logger.d(
      '🔍 AccountPaymentMethodsWidget: initState - triggering LoadAccountPaymentMethods',
    );
    // Trigger payment methods loading when widget initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AccountPaymentMethodsBloc>().add(
        LoadAccountPaymentMethods(widget.accountId),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    _logger.d(
      '🔍 AccountPaymentMethodsWidget: Building with accountId: ${widget.accountId}',
    );

    return BlocListener<AccountPaymentMethodsBloc, AccountPaymentMethodsState>(
      listener: (context, state) {
        _logger.d(
          '🔍 AccountPaymentMethodsWidget: Received state: ${state.runtimeType}',
        );
        _logger.d('🔍 AccountPaymentMethodsWidget: State details: $state');

        if (state is DefaultPaymentMethodSet) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Default payment method set successfully'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
        } else if (state is DefaultPaymentMethodSetFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Failed to set default payment method: ${state.message}',
              ),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        } else if (state is PaymentMethodDeactivated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Payment method deactivated successfully'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
        } else if (state is PaymentMethodDeactivationFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Failed to deactivate payment method: ${state.message}',
              ),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        } else if (state is PaymentMethodReactivated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Payment method reactivated successfully'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
        } else if (state is PaymentMethodReactivationFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Failed to reactivate payment method: ${state.message}',
              ),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        } else if (state is PaymentMethodsSynced) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Payment methods synced successfully'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
        } else if (state is PaymentMethodsSyncFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to sync payment methods: ${state.message}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      },
      child: BlocBuilder<AccountPaymentMethodsBloc, AccountPaymentMethodsState>(
        builder: (context, state) {
          _logger.d(
            '🔍 AccountPaymentMethodsWidget: Building with state: ${state.runtimeType}',
          );
          _logger.d(
            '🔍 AccountPaymentMethodsWidget: State details in builder: $state',
          );

          // Check for AccountPaymentMethodsLoaded first to prioritize it
          if (state is AccountPaymentMethodsLoaded) {
            _logger.d(
              '🔍 AccountPaymentMethodsWidget: Building AccountPaymentMethodsLoaded with ${state.paymentMethods.length} payment methods',
            );
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Payment Methods (${state.paymentMethods.length})',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: () {
                        context.read<AccountPaymentMethodsBloc>().add(
                          RefreshAccountPaymentMethods(widget.accountId),
                        );
                      },
                      tooltip: 'Refresh Payment Methods',
                    ),
                    IconButton(
                      icon: const Icon(Icons.sync),
                      onPressed: () {
                        context.read<AccountPaymentMethodsBloc>().add(
                          SyncPaymentMethods(widget.accountId),
                        );
                      },
                      tooltip: 'Sync with External Processors',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (state.paymentMethods.isEmpty)
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.payment_outlined,
                          size: 64,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No payment methods found',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'This account has no payment methods configured',
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            context.read<AccountPaymentMethodsBloc>().add(
                              SyncPaymentMethods(widget.accountId),
                            );
                          },
                          icon: const Icon(Icons.sync),
                          label: const Text('Sync Payment Methods'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primary,
                            foregroundColor: Theme.of(
                              context,
                            ).colorScheme.onPrimary,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Expanded(
                    child: ListView.builder(
                      itemCount: state.paymentMethods.length,
                      itemBuilder: (context, index) {
                        final method = state.paymentMethods[index];
                        return _buildPaymentMethodCard(context, method);
                      },
                    ),
                  ),
              ],
            );
          }

          if (state is AccountPaymentMethodsLoading) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Payment Methods',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const Spacer(),
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text(
                        'Syncing payment methods with external processors...',
                      ),
                    ],
                  ),
                ),
              ],
            );
          }

          if (state is PaymentMethodsSynced) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Payment Methods (${state.paymentMethods.length})',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 16,
                            color: Colors.green,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Synced',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: () {
                        context.read<AccountPaymentMethodsBloc>().add(
                          RefreshAccountPaymentMethods(widget.accountId),
                        );
                      },
                      tooltip: 'Refresh Payment Methods',
                    ),
                    IconButton(
                      icon: const Icon(Icons.sync),
                      onPressed: () {
                        context.read<AccountPaymentMethodsBloc>().add(
                          SyncPaymentMethods(widget.accountId),
                        );
                      },
                      tooltip: 'Sync with External Processors',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (state.paymentMethods.isEmpty)
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.payment_outlined,
                          size: 64,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No payment methods found',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'This account has no payment methods configured',
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                else
                  Expanded(
                    child: ListView.builder(
                      itemCount: state.paymentMethods.length,
                      itemBuilder: (context, index) {
                        final method = state.paymentMethods[index];
                        return _buildPaymentMethodCard(context, method);
                      },
                    ),
                  ),
              ],
            );
          }

          if (state is AccountPaymentMethodsFailure) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Payment Methods',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: () {
                        context.read<AccountPaymentMethodsBloc>().add(
                          RefreshAccountPaymentMethods(widget.accountId),
                        );
                      },
                      tooltip: 'Refresh Payment Methods',
                    ),
                    IconButton(
                      icon: const Icon(Icons.sync),
                      onPressed: () {
                        context.read<AccountPaymentMethodsBloc>().add(
                          SyncPaymentMethods(widget.accountId),
                        );
                      },
                      tooltip: 'Sync with External Processors',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Center(
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
                        'Failed to sync payment methods',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        state.message,
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          context.read<AccountPaymentMethodsBloc>().add(
                            SyncPaymentMethods(widget.accountId),
                          );
                        },
                        icon: const Icon(Icons.sync),
                        label: const Text('Retry Sync'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                          foregroundColor: Theme.of(
                            context,
                          ).colorScheme.onPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }

          return const Center(child: Text('No payment method data available'));
        },
      ),
    );
  }

  Widget _buildPaymentMethodCard(
    BuildContext context,
    AccountPaymentMethod method,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: InkWell(
        onTap: () => _showPaymentMethodDetails(context, method),
        borderRadius: BorderRadius.circular(8.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _getPaymentMethodIcon(method.paymentMethodType),
                    color: _getPaymentMethodColor(method.paymentMethodType),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      method.paymentMethodName,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  if (method.isDefault)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Default',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  if (!method.isActive)
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.error.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Inactive',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.error,
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
                    Icons.category,
                    size: 16,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.6),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Type: ${method.paymentMethodType}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.schedule,
                    size: 16,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.6),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Added: ${_formatDateTime(method.createdAt)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
              if (method.cardLastFourDigits != null ||
                  method.cardBrand != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (method.cardBrand != null) ...[
                      Icon(
                        Icons.credit_card,
                        size: 16,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.6),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${method.cardBrand}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(width: 8),
                    ],
                    if (method.cardLastFourDigits != null) ...[
                      Text(
                        '•••• ${method.cardLastFourDigits}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      if (method.cardExpiryMonth != null &&
                          method.cardExpiryYear != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          'Expires: ${method.cardExpiryMonth}/${method.cardExpiryYear}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.6),
                              ),
                        ),
                      ],
                    ],
                  ],
                ),
              ],
              if (method.bankName != null ||
                  method.bankAccountLastFourDigits != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (method.bankName != null) ...[
                      Icon(
                        Icons.account_balance,
                        size: 16,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.6),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${method.bankName}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(width: 8),
                    ],
                    if (method.bankAccountLastFourDigits != null) ...[
                      Text(
                        '•••• ${method.bankAccountLastFourDigits}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      if (method.bankAccountType != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          '(${method.bankAccountType})',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.6),
                              ),
                        ),
                      ],
                    ],
                  ],
                ),
              ],
              if (method.paypalEmail != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.email,
                      size: 16,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.6),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'PayPal: ${method.paypalEmail}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  if (!method.isDefault && method.isActive)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showSetDefaultDialog(context, method),
                        icon: const Icon(Icons.star),
                        label: const Text('Set as Default'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                          foregroundColor: Theme.of(
                            context,
                          ).colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  if (method.isActive)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showDeactivateDialog(context, method),
                        icon: const Icon(Icons.pause),
                        label: const Text('Deactivate'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showReactivateDialog(context, method),
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
      ),
    );
  }

  void _showPaymentMethodDetails(
    BuildContext context,
    AccountPaymentMethod method,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PaymentMethodDetailPage(
          paymentMethod: method,
          accountId: widget.accountId,
        ),
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

  void _showSetDefaultDialog(
    BuildContext context,
    AccountPaymentMethod method,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set as Default Payment Method'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Do you want to set "${method.paymentMethodName}" as your default payment method?',
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
              context.read<AccountPaymentMethodsBloc>().add(
                SetDefaultPaymentMethod(
                  accountId: widget.accountId,
                  paymentMethodId: method.id,
                  payAllUnpaidInvoices: false, // TODO: Get from checkbox
                ),
              );
            },
            child: const Text('Set as Default'),
          ),
        ],
      ),
    );
  }

  void _showDeactivateDialog(
    BuildContext context,
    AccountPaymentMethod method,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deactivate Payment Method'),
        content: Text(
          'Are you sure you want to deactivate "${method.paymentMethodName}"? This will prevent it from being used for future payments.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<AccountPaymentMethodsBloc>().add(
                DeactivatePaymentMethod(
                  accountId: widget.accountId,
                  paymentMethodId: method.id,
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

  void _showReactivateDialog(
    BuildContext context,
    AccountPaymentMethod method,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reactivate Payment Method'),
        content: Text(
          'Are you sure you want to reactivate "${method.paymentMethodName}"? This will allow it to be used for future payments again.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<AccountPaymentMethodsBloc>().add(
                ReactivatePaymentMethod(
                  accountId: widget.accountId,
                  paymentMethodId: method.id,
                ),
              );
            },
            child: const Text('Reactivate'),
          ),
        ],
      ),
    );
  }
}
