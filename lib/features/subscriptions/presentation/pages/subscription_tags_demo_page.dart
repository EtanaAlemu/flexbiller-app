import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../bloc/subscriptions_bloc.dart';
import '../widgets/subscription_tags_widget.dart';

class SubscriptionTagsDemoPage extends StatefulWidget {
  const SubscriptionTagsDemoPage({super.key});

  @override
  State<SubscriptionTagsDemoPage> createState() =>
      _SubscriptionTagsDemoPageState();
}

class _SubscriptionTagsDemoPageState
    extends State<SubscriptionTagsDemoPage> {
  final TextEditingController _subscriptionIdController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Pre-fill with a sample subscription ID for testing
    _subscriptionIdController.text = '6244612b-6f25-4757-a0b5-aff912d65a08';
  }

  @override
  void dispose() {
    _subscriptionIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GetIt.instance<SubscriptionsBloc>(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Subscription Tags Demo')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Enter Subscription ID to view tags',
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _subscriptionIdController,
                  decoration: const InputDecoration(
                    labelText: 'Subscription ID',
                    hintText: 'Enter the subscription ID to view tags',
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
                  onPressed: _viewTags,
                  icon: const Icon(Icons.label),
                  label: const Text('View Subscription Tags'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
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
                  '6244612b-6f25-4757-a0b5-aff912d65a08',
                  'Sample Subscription 1',
                ),
                _buildSampleSubscriptionId(
                  '41b74b4b-4a19-4a5c-9be7-20b805e08c14',
                  'Sample Subscription 2',
                ),
                _buildSampleSubscriptionId(
                  '8a0075a7-104c-4dfc-9e9a-6737c51cd59c',
                  'Sample Subscription 3',
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer.withValues(
                      alpha: 0.1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary.withValues(
                        alpha: 0.3,
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Theme.of(context).colorScheme.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'About Subscription Tags:',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '• Tags help organize and categorize subscriptions\n'
                        '• You can view all tags associated with a subscription\n'
                        '• Tags are displayed in a clean, organized format\n'
                        '• Use the refresh button to reload tags\n'
                        '• Empty state is shown when no tags exist',
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
          _viewTags();
        },
      ),
    );
  }

  void _viewTags() {
    if (_formKey.currentState!.validate()) {
      final subscriptionId = _subscriptionIdController.text.trim();
      
      // Show a dialog with the tags widget
      showDialog(
        context: context,
        builder: (context) => Dialog(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.7,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Subscription Tags',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const Divider(),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Subscription info header
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.subscriptions,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Subscription ID',
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: Theme.of(context).colorScheme.outline.withValues(
                                            alpha: 0.7,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        subscriptionId,
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          fontWeight: FontWeight.w500,
                                          fontFamily: 'monospace',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Tags widget
                        SubscriptionTagsWidget(
                          subscriptionId: subscriptionId,
                          subscriptionName: 'Subscription ${subscriptionId.substring(0, 8)}',
                          onRefresh: () {
                            // Optionally refresh the dialog or show a message
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Tags refreshed!'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
}
