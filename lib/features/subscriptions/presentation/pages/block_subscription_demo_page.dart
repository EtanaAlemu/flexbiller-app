import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../bloc/subscriptions_bloc.dart';
import '../bloc/subscriptions_event.dart';
import '../bloc/subscriptions_state.dart';
import '../../domain/entities/subscription_blocking_state.dart';

class BlockSubscriptionDemoPage extends StatefulWidget {
  const BlockSubscriptionDemoPage({super.key});

  @override
  State<BlockSubscriptionDemoPage> createState() =>
      _BlockSubscriptionDemoPageState();
}

class _BlockSubscriptionDemoPageState extends State<BlockSubscriptionDemoPage> {
  final TextEditingController _subscriptionIdController = TextEditingController();
  final TextEditingController _stateNameController = TextEditingController();
  final TextEditingController _serviceController = TextEditingController();
  final TextEditingController _effectiveDateController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isBlockChange = true;
  bool _isBlockEntitlement = true;
  bool _isBlockBilling = true;

  @override
  void initState() {
    super.initState();
    _subscriptionIdController.text = '41b74b4b-4a19-4a5c-9be7-20b805e08c14';
    _stateNameController.text = 'BLOCKED';
    _serviceController.text = 'PAYMENT';
    _effectiveDateController.text = DateTime.now().toIso8601String();
  }

  @override
  void dispose() {
    _subscriptionIdController.dispose();
    _stateNameController.dispose();
    _serviceController.dispose();
    _effectiveDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GetIt.instance<SubscriptionsBloc>(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Block Subscription Demo')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'This demo allows you to block a subscription with specific blocking states.',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _subscriptionIdController,
                    decoration: const InputDecoration(
                      labelText: 'Subscription ID',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a subscription ID';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _stateNameController,
                    decoration: const InputDecoration(
                      labelText: 'State Name',
                      border: OutlineInputBorder(),
                      hintText: 'e.g., BLOCKED',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a state name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _serviceController,
                    decoration: const InputDecoration(
                      labelText: 'Service',
                      border: OutlineInputBorder(),
                      hintText: 'e.g., PAYMENT',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a service';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _effectiveDateController,
                    decoration: const InputDecoration(
                      labelText: 'Effective Date (ISO 8601)',
                      border: OutlineInputBorder(),
                      hintText: 'e.g., 2025-04-17T14:07:40.222Z',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter an effective date';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Blocking Options:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          CheckboxListTile(
                            title: const Text('Block Change'),
                            value: _isBlockChange,
                            onChanged: (value) {
                              setState(() {
                                _isBlockChange = value ?? true;
                              });
                            },
                          ),
                          CheckboxListTile(
                            title: const Text('Block Entitlement'),
                            value: _isBlockEntitlement,
                            onChanged: (value) {
                              setState(() {
                                _isBlockEntitlement = value ?? true;
                              });
                            },
                          ),
                          CheckboxListTile(
                            title: const Text('Block Billing'),
                            value: _isBlockBilling,
                            onChanged: (value) {
                              setState(() {
                                _isBlockBilling = value ?? true;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _blockSubscription,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Block Subscription'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _blockSubscription() {
    if (_formKey.currentState!.validate()) {
      final subscriptionId = _subscriptionIdController.text.trim();
      final blockingData = {
        'stateName': _stateNameController.text.trim(),
        'service': _serviceController.text.trim(),
        'isBlockChange': _isBlockChange,
        'isBlockEntitlement': _isBlockEntitlement,
        'isBlockBilling': _isBlockBilling,
        'effectiveDate': _effectiveDateController.text.trim(),
        'type': 'SUBSCRIPTION',
      };

      context.read<SubscriptionsBloc>().add(BlockSubscription(
        subscriptionId: subscriptionId,
        blockingData: blockingData,
      ));

      _showResultDialog('Block Subscription', 'Blocking subscription...');
    }
  }

  void _showResultDialog(String title, String initialMessage) {
    showDialog(
      context: context,
      builder: (context) => BlocBuilder<SubscriptionsBloc, SubscriptionsState>(
        builder: (context, state) {
          if (state is BlockSubscriptionLoading) {
            return AlertDialog(
              title: Text(title),
              content: const Center(child: CircularProgressIndicator()),
            );
          } else if (state is BlockSubscriptionSuccess) {
            return AlertDialog(
              title: const Text('Success!'),
              content: _buildBlockingStateInfo(state.blockingState),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            );
          } else if (state is BlockSubscriptionError) {
            return AlertDialog(
              title: const Text('Error'),
              content: Text('Failed to block subscription: ${state.message}'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            );
          }

          return AlertDialog(
            title: Text(title),
            content: Text(initialMessage),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBlockingStateInfo(SubscriptionBlockingState blockingState) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('State Name: ${blockingState.stateName ?? 'N/A'}'),
        Text('Service: ${blockingState.service ?? 'N/A'}'),
        Text('Type: ${blockingState.type ?? 'N/A'}'),
        Text('Block Change: ${blockingState.isBlockChange ?? false}'),
        Text('Block Entitlement: ${blockingState.isBlockEntitlement ?? false}'),
        Text('Block Billing: ${blockingState.isBlockBilling ?? false}'),
        if (blockingState.effectiveDate != null)
          Text('Effective Date: ${blockingState.effectiveDate!.toIso8601String()}'),
      ],
    );
  }
}
