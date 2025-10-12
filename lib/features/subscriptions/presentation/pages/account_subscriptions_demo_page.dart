import 'package:flutter/material.dart';
import 'account_subscriptions_page.dart';

class AccountSubscriptionsDemoPage extends StatefulWidget {
  const AccountSubscriptionsDemoPage({super.key});

  @override
  State<AccountSubscriptionsDemoPage> createState() =>
      _AccountSubscriptionsDemoPageState();
}

class _AccountSubscriptionsDemoPageState
    extends State<AccountSubscriptionsDemoPage> {
  final TextEditingController _accountIdController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Pre-fill with a sample account ID for testing
    _accountIdController.text = '6609f1e0-2d9c-4d4d-8e77-c8f97a3fe14f';
  }

  @override
  void dispose() {
    _accountIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Subscriptions'),
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
                'Enter Account ID to view subscriptions',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _accountIdController,
                decoration: const InputDecoration(
                  labelText: 'Account ID',
                  hintText: 'Enter the account ID',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.account_circle),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter an account ID';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _viewSubscriptions,
                icon: const Icon(Icons.subscriptions),
                label: const Text('View Account Subscriptions'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              Text(
                'Sample Account IDs for testing:',
                style: Theme.of(context).textTheme.titleSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              _buildSampleAccountId(
                '6609f1e0-2d9c-4d4d-8e77-c8f97a3fe14f',
                'Sample Account 1',
              ),
              _buildSampleAccountId(
                '9f08942f-8d8f-460d-a6a9-422038d7675f',
                'Sample Account 2',
              ),
              _buildSampleAccountId(
                '358b75e3-24d2-40a3-b7d4-cbd70887e954',
                'Sample Account 3',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSampleAccountId(String accountId, String label) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: const Icon(Icons.account_circle_outlined),
        title: Text(label),
        subtitle: Text(
          accountId,
          style: const TextStyle(fontFamily: 'monospace'),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.copy),
          onPressed: () {
            _accountIdController.text = accountId;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Account ID copied to input field'),
                duration: Duration(seconds: 1),
              ),
            );
          },
        ),
        onTap: () {
          _accountIdController.text = accountId;
          _viewSubscriptions();
        },
      ),
    );
  }

  void _viewSubscriptions() {
    if (_formKey.currentState!.validate()) {
      final accountId = _accountIdController.text.trim();
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => AccountSubscriptionsPage(
            accountId: accountId,
            accountName: 'Account $accountId.substring(0, 8)',
          ),
        ),
      );
    }
  }
}
