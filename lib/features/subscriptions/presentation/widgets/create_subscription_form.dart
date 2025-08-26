import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/subscriptions_bloc.dart';
import '../bloc/subscriptions_event.dart';
import '../bloc/subscriptions_state.dart';

class CreateSubscriptionForm extends StatefulWidget {
  final String? initialAccountId;
  final VoidCallback? onSuccess;

  const CreateSubscriptionForm({
    super.key,
    this.initialAccountId,
    this.onSuccess,
  });

  @override
  State<CreateSubscriptionForm> createState() => _CreateSubscriptionFormState();
}

class _CreateSubscriptionFormState extends State<CreateSubscriptionForm> {
  final _formKey = GlobalKey<FormState>();
  final _accountIdController = TextEditingController();
  final _planNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialAccountId != null) {
      _accountIdController.text = widget.initialAccountId!;
    }
  }

  @override
  void dispose() {
    _accountIdController.dispose();
    _planNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SubscriptionsBloc, SubscriptionsState>(
      listener: (context, state) {
        if (state is CreateSubscriptionSuccess) {
          _showSuccessDialog(context, state.subscription);
          widget.onSuccess?.call();
        } else if (state is CreateSubscriptionError) {
          _showErrorSnackBar(context, state.message);
        }
      },
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Create New Subscription',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
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
            const SizedBox(height: 16),
            TextFormField(
              controller: _planNameController,
              decoration: const InputDecoration(
                labelText: 'Plan Name',
                hintText: 'e.g., Premium-Monthly, Standard-Weekly',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.subscriptions),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a plan name';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            BlocBuilder<SubscriptionsBloc, SubscriptionsState>(
              builder: (context, state) {
                final isLoading = state is CreateSubscriptionLoading;

                return ElevatedButton.icon(
                  onPressed: isLoading ? null : _createSubscription,
                  icon: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.add),
                  label: Text(
                    isLoading ? 'Creating...' : 'Create Subscription',
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            _buildSamplePlans(),
          ],
        ),
      ),
    );
  }

  Widget _buildSamplePlans() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Sample Plans:', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            _buildPlanChip('Premium-Monthly'),
            _buildPlanChip('Premium-Yearly'),
            _buildPlanChip('Standard-Monthly'),
            _buildPlanChip('Standard-Weekly'),
            _buildPlanChip('Basic-Monthly'),
          ],
        ),
      ],
    );
  }

  Widget _buildPlanChip(String planName) {
    return ActionChip(
      label: Text(planName),
      onPressed: () {
        _planNameController.text = planName;
      },
      avatar: const Icon(Icons.subscriptions, size: 16),
    );
  }

  void _createSubscription() {
    if (_formKey.currentState!.validate()) {
      final accountId = _accountIdController.text.trim();
      final planName = _planNameController.text.trim();

      context.read<SubscriptionsBloc>().add(
        CreateSubscription(accountId: accountId, planName: planName),
      );
    }
  }

  void _showSuccessDialog(BuildContext context, dynamic subscription) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Subscription Created Successfully!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Subscription ID: ${subscription.subscriptionId}'),
            Text('Plan: ${subscription.planName}'),
            Text('Status: ${subscription.state}'),
            Text('Start Date: ${subscription.startDate}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Clear the form
              _planNameController.clear();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error: $message'),
        backgroundColor: Theme.of(context).colorScheme.error,
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
}
