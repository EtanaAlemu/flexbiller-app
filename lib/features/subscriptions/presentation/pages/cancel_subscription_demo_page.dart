import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../bloc/subscriptions_bloc.dart';
import '../widgets/cancel_subscription_dialog.dart';

class CancelSubscriptionDemoPage extends StatefulWidget {
  const CancelSubscriptionDemoPage({super.key});

  @override
  State<CancelSubscriptionDemoPage> createState() =>
      _CancelSubscriptionDemoPageState();
}

class _CancelSubscriptionDemoPageState
    extends State<CancelSubscriptionDemoPage> {
  final TextEditingController _subscriptionIdController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Pre-fill with a sample subscription ID for testing
    _subscriptionIdController.text = '41b74b4b-4a19-4a5c-9be7-20b805e08c14';
  }

  @override
  void dispose() {
    _subscriptionIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider(
      create: (context) => GetIt.instance<SubscriptionsBloc>(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Cancel Subscription'),
          backgroundColor: theme.colorScheme.surface,
          foregroundColor: theme.colorScheme.onSurface,
          elevation: 0,
          scrolledUnderElevation: 1,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Enter Subscription ID to cancel',
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _subscriptionIdController,
                  decoration: const InputDecoration(
                    labelText: 'Subscription ID',
                    hintText: 'Enter the subscription ID to cancel',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.subscriptions),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a subscription ID';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _showCancelDialog,
                  icon: const Icon(Icons.cancel_outlined),
                  label: const Text('Show Cancel Dialog'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Theme.of(context).colorScheme.error,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                Text(
                  'Sample Subscription IDs for testing:',
                  style: Theme.of(context).textTheme.titleSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                _buildSampleSubscriptionId(
                  '41b74b4b-4a19-4a5c-9be7-20b805e08c14',
                  'Sample Subscription 1',
                ),
                _buildSampleSubscriptionId(
                  '8a0075a7-104c-4dfc-9e9a-6737c51cd59c',
                  'Sample Subscription 2',
                ),
                _buildSampleSubscriptionId(
                  '12345678-1234-1234-1234-123456789abc',
                  'Sample Subscription 3',
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.errorContainer.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.error.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            color: Theme.of(context).colorScheme.error,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Important Notes:',
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).colorScheme.error,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '• Cancelling a subscription is irreversible\n'
                        '• Billing will stop at the end of the current period\n'
                        '• The subscription will be marked as cancelled\n'
                        '• You can still view cancelled subscriptions',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSampleSubscriptionId(String subscriptionId, String label) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: const Icon(Icons.subscriptions_outlined),
        title: Text(label),
        subtitle: Text(
          subscriptionId,
          style: const TextStyle(fontFamily: 'monospace'),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.copy),
          onPressed: () {
            _subscriptionIdController.text = subscriptionId;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Subscription ID copied to input field'),
                duration: Duration(seconds: 1),
              ),
            );
          },
        ),
        onTap: () {
          _subscriptionIdController.text = subscriptionId;
          _showCancelDialog();
        },
      ),
    );
  }

  void _showCancelDialog() {
    if (_formKey.currentState!.validate()) {
      final subscriptionId = _subscriptionIdController.text.trim();

      showDialog(
        context: context,
        builder: (context) => BlocProvider(
          create: (context) => context.read<SubscriptionsBloc>(),
          child: CancelSubscriptionDialog(
            subscriptionId: subscriptionId,
            subscriptionName: 'Subscription $subscriptionId.substring(0, 8)',
            onSuccess: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Subscription cancelled successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
          ),
        ),
      );
    }
  }
}
