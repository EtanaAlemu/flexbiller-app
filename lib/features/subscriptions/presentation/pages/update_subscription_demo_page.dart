import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../bloc/subscriptions_bloc.dart';
import '../bloc/subscriptions_event.dart';
import '../bloc/subscriptions_state.dart';
import '../widgets/update_subscription_form.dart';

class UpdateSubscriptionDemoPage extends StatefulWidget {
  const UpdateSubscriptionDemoPage({super.key});

  @override
  State<UpdateSubscriptionDemoPage> createState() =>
      _UpdateSubscriptionDemoPageState();
}

class _UpdateSubscriptionDemoPageState
    extends State<UpdateSubscriptionDemoPage> {
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
    return BlocProvider(
      create: (context) => GetIt.instance<SubscriptionsBloc>(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Update Subscription Demo')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Enter Subscription ID to update',
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _subscriptionIdController,
                  decoration: const InputDecoration(
                    labelText: 'Subscription ID',
                    hintText: 'Enter the subscription ID to update',
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
                  onPressed: _loadSubscription,
                  icon: const Icon(Icons.search),
                  label: const Text('Load Subscription for Update'),
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
          _loadSubscription();
        },
      ),
    );
  }

  void _loadSubscription() {
    if (_formKey.currentState!.validate()) {
      final subscriptionId = _subscriptionIdController.text.trim();

      // Load the subscription first
      context.read<SubscriptionsBloc>().add(
        GetSubscriptionById(subscriptionId),
      );

      // Show a dialog with the update form
      showDialog(
        context: context,
        builder: (context) =>
            BlocBuilder<SubscriptionsBloc, SubscriptionsState>(
              builder: (context, state) {
                if (state is SingleSubscriptionLoading) {
                  return const AlertDialog(
                    content: Center(child: CircularProgressIndicator()),
                  );
                } else if (state is SingleSubscriptionLoaded) {
                  return Dialog(
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.9,
                      height: MediaQuery.of(context).size.height * 0.8,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Update Subscription',
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
                              child: UpdateSubscriptionForm(
                                subscription: state.subscription,
                                onSuccess: () {
                                  Navigator.of(context).pop();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Subscription updated successfully!',
                                      ),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                } else if (state is SingleSubscriptionError) {
                  return AlertDialog(
                    title: const Text('Error'),
                    content: Text(
                      'Failed to load subscription: ${state.message}',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('OK'),
                      ),
                    ],
                  );
                }
                return const AlertDialog(
                  content: Text('No subscription loaded'),
                );
              },
            ),
      );
    }
  }
}
