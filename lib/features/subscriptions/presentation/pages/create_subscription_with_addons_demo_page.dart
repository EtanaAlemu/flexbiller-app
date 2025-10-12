import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../bloc/subscriptions_bloc.dart';
import '../bloc/subscriptions_event.dart';
import '../bloc/subscriptions_state.dart';

class CreateSubscriptionWithAddOnsDemoPage extends StatefulWidget {
  const CreateSubscriptionWithAddOnsDemoPage({super.key});

  @override
  State<CreateSubscriptionWithAddOnsDemoPage> createState() =>
      _CreateSubscriptionWithAddOnsDemoPageState();
}

class _CreateSubscriptionWithAddOnsDemoPageState
    extends State<CreateSubscriptionWithAddOnsDemoPage> {
  final List<Map<String, TextEditingController>> _addonControllers = [];
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _addAddonProduct(); // Add one initial add-on product
  }

  @override
  void dispose() {
    for (var controllers in _addonControllers) {
      controllers.values.forEach((controller) => controller.dispose());
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider(
      create: (context) => GetIt.instance<SubscriptionsBloc>(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Create with Add-ons'),
          backgroundColor: theme.colorScheme.surface,
          foregroundColor: theme.colorScheme.onSurface,
          elevation: 0,
          scrolledUnderElevation: 1,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'This demo allows you to create a subscription with multiple add-on products.',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  _buildAddonProductsList(),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _addAddonProduct,
                          icon: const Icon(Icons.add),
                          label: const Text('Add Add-on Product'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _removeLastAddon,
                          icon: const Icon(Icons.remove),
                          label: const Text('Remove Last'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _createSubscriptionWithAddOns,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Create Subscription with Add-ons'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddonProductsList() {
    return Column(
      children: _addonControllers.asMap().entries.map((entry) {
        final index = entry.key;
        final controllers = entry.value;

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Add-on Product ${index + 1}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    if (_addonControllers.length > 1)
                      IconButton(
                        onPressed: () => _removeAddonAt(index),
                        icon: const Icon(Icons.delete, color: Colors.red),
                        tooltip: 'Remove this add-on',
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: controllers['accountId']!,
                        decoration: const InputDecoration(
                          labelText: 'Account ID',
                          border: OutlineInputBorder(),
                          hintText:
                              'e.g., 358b75e3-24d2-40a3-b7d4-cbd70887e954',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter an account ID';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: controllers['productName']!,
                        decoration: const InputDecoration(
                          labelText: 'Product Name',
                          border: OutlineInputBorder(),
                          hintText: 'e.g., Premium',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a product name';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: controllers['productCategory']!,
                        decoration: const InputDecoration(
                          labelText: 'Product Category',
                          border: OutlineInputBorder(),
                          hintText: 'e.g., BASE',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a product category';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: controllers['billingPeriod']!,
                        decoration: const InputDecoration(
                          labelText: 'Billing Period',
                          border: OutlineInputBorder(),
                          hintText: 'e.g., MONTHLY',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a billing period';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: controllers['priceList']!,
                  decoration: const InputDecoration(
                    labelText: 'Price List',
                    border: OutlineInputBorder(),
                    hintText: 'e.g., DEFAULT',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a price list';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  void _addAddonProduct() {
    setState(() {
      _addonControllers.add({
        'accountId': TextEditingController(
          text: '358b75e3-24d2-40a3-b7d4-cbd70887e954',
        ),
        'productName': TextEditingController(text: 'Premium'),
        'productCategory': TextEditingController(text: 'BASE'),
        'billingPeriod': TextEditingController(text: 'MONTHLY'),
        'priceList': TextEditingController(text: 'DEFAULT'),
      });
    });
  }

  void _removeAddonAt(int index) {
    setState(() {
      final controllers = _addonControllers.removeAt(index);
      controllers.values.forEach((controller) => controller.dispose());
    });
  }

  void _removeLastAddon() {
    if (_addonControllers.length > 1) {
      _removeAddonAt(_addonControllers.length - 1);
    }
  }

  void _createSubscriptionWithAddOns() {
    if (_formKey.currentState!.validate()) {
      final addonProducts = _addonControllers.map((controllers) {
        return {
          'accountId': controllers['accountId']!.text.trim(),
          'productName': controllers['productName']!.text.trim(),
          'productCategory': controllers['productCategory']!.text.trim(),
          'billingPeriod': controllers['billingPeriod']!.text.trim(),
          'priceList': controllers['priceList']!.text.trim(),
        };
      }).toList();

      context.read<SubscriptionsBloc>().add(
        CreateSubscriptionWithAddOns(addonProducts: addonProducts),
      );

      _showResultDialog(
        'Create Subscription with Add-ons',
        'Creating subscription...',
      );
    }
  }

  void _showResultDialog(String title, String initialMessage) {
    showDialog(
      context: context,
      builder: (context) => BlocBuilder<SubscriptionsBloc, SubscriptionsState>(
        builder: (context, state) {
          if (state is CreateSubscriptionWithAddOnsLoading) {
            return AlertDialog(
              title: Text(title),
              content: const Center(child: CircularProgressIndicator()),
            );
          } else if (state is CreateSubscriptionWithAddOnsSuccess) {
            return AlertDialog(
              title: const Text('Success!'),
              content: _buildSuccessInfo(state.result),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            );
          } else if (state is CreateSubscriptionWithAddOnsError) {
            return AlertDialog(
              title: const Text('Error'),
              content: Text('Failed to create subscription: ${state.message}'),
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

  Widget _buildSuccessInfo(Map<String, dynamic> result) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Success: ${result['success'] ?? 'N/A'}'),
        Text('Code: ${result['code'] ?? 'N/A'}'),
        Text('Data: ${result['data'] ?? 'N/A'}'),
        Text('Message: ${result['message'] ?? 'N/A'}'),
      ],
    );
  }
}
