import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/account_payments_bloc.dart';
import '../bloc/account_payments_events.dart';
import '../bloc/account_payments_states.dart';
import '../pages/payment_detail_page.dart';

class AccountPaymentsWidget extends StatefulWidget {
  final String accountId;

  const AccountPaymentsWidget({Key? key, required this.accountId})
    : super(key: key);

  @override
  State<AccountPaymentsWidget> createState() => _AccountPaymentsWidgetState();
}

class _AccountPaymentsWidgetState extends State<AccountPaymentsWidget> {
  bool _paymentsLoaded = false;
  AccountPaymentsLoaded? _lastPaymentsState;

  @override
  void initState() {
    super.initState();
    _paymentsLoaded = false;
    print(
      '🔍 AccountPaymentsWidget: initState - triggering LoadAccountPayments',
    );
    // Trigger payments loading when widget initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AccountPaymentsBloc>().add(
        LoadAccountPayments(widget.accountId),
      );
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print(
      '🔍 AccountPaymentsWidget: Building with accountId: ${widget.accountId}',
    );

    return BlocListener<AccountPaymentsBloc, AccountPaymentsState>(
      listener: (context, state) {
        print('🔍 AccountPaymentsWidget: Received state: ${state.runtimeType}');
        print('🔍 AccountPaymentsWidget: State details: $state');
        if (state is AccountPaymentsLoaded) {
          print(
            '🔍 AccountPaymentsWidget: Received AccountPaymentsLoaded with ${state.payments.length} payments',
          );
          _paymentsLoaded = true;
          _lastPaymentsState = state;
        } else if (state is AccountPaymentRefunded) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Payment refunded successfully'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
        } else if (state is AccountPaymentRefundFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Refund failed: ${state.message}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      },
      child: BlocBuilder<AccountPaymentsBloc, AccountPaymentsState>(
        builder: (context, state) {
          print(
            '🔍 AccountPaymentsWidget: Building with state: ${state.runtimeType}',
          );
          print('🔍 AccountPaymentsWidget: State details in builder: $state');
          print(
            '🔍 AccountPaymentsWidget: _paymentsLoaded: $_paymentsLoaded, _lastPaymentsState: ${_lastPaymentsState?.payments.length ?? 'null'}',
          );

          // Check for AccountPaymentsLoaded first to prioritize it over AccountDetailsLoaded
          if (state is AccountPaymentsLoaded) {
            print(
              '🔍 AccountPaymentsWidget: Building AccountPaymentsLoaded with ${state.payments.length} payments',
            );
            return Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Payments (${state.payments.length})',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                // Payments list
                Expanded(
                  child: state.payments.isEmpty
                      ? _buildEmptyState(context)
                      : RefreshIndicator(
                          onRefresh: () async {
                            context.read<AccountPaymentsBloc>().add(
                              RefreshAccountPayments(widget.accountId),
                            );
                          },
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                            ),
                            itemCount: state.payments.length,
                            itemBuilder: (context, index) {
                              final payment = state.payments[index];
                              return _buildPaymentCard(context, payment);
                            },
                          ),
                        ),
                ),
              ],
            );
          }

          if (state is AccountPaymentsLoading) {
            print('🔍 AccountPaymentsWidget: Showing loading indicator');
            return Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Payments',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                // Loading indicator for payments section only
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 16),
                        Text(
                          'Loading payments...',
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.7),
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }

          if (state is AccountPaymentsFailure) {
            print('🔍 AccountPaymentsWidget: Showing failure state');
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
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
                    ElevatedButton.icon(
                      onPressed: () {
                        context.read<AccountPaymentsBloc>().add(
                          LoadAccountPayments(widget.accountId),
                        );
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          // Default state - show loading
          print(
            '🔍 AccountPaymentsWidget: Fallback case - showing loading for state: ${state.runtimeType}',
          );
          return Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Payments',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              // Loading indicator for payments section only
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      Text(
                        'Loading payments...',
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
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
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
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'This account doesn\'t have any payments yet.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentCard(BuildContext context, dynamic payment) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: () => _showPaymentDetails(context, payment),
        borderRadius: BorderRadius.circular(8.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      payment.paymentType ?? 'Unknown Type',
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
                      color: _getStatusColor(payment.paymentStatus),
                      borderRadius: BorderRadius.circular(12),
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
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Amount: ${_formatCurrency(payment.amount, payment.currency)}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (payment.isRefunded == true)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Refunded',
                        style: TextStyle(
                          color: Colors.orange[800],
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              if (payment.paymentMethodName != null) ...[
                Text(
                  'Method: ${payment.paymentMethodName}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
              if (payment.paymentDate != null) ...[
                Text(
                  'Date: ${_formatDate(payment.paymentDate)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
              if (payment.description != null) ...[
                const SizedBox(height: 4),
                Text(
                  payment.description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.7),
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  if (payment.paymentStatus == 'completed' &&
                      payment.isRefunded != true)
                    TextButton.icon(
                      onPressed: () => _showRefundDialog(context, payment),
                      icon: const Icon(Icons.undo, size: 16),
                      label: const Text('Refund'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.orange,
                      ),
                    ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () => _showPaymentDetails(context, payment),
                    icon: const Icon(Icons.info_outline, size: 16),
                    label: const Text('Details'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRefundDialog(BuildContext context, dynamic payment) {
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

  void _showPaymentDetails(BuildContext context, dynamic payment) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            PaymentDetailPage(payment: payment, accountId: widget.accountId),
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
