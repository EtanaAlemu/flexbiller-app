import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../bloc/subscriptions_bloc.dart';
import '../bloc/subscriptions_event.dart';
import '../bloc/subscriptions_state.dart';

class UpdateSubscriptionBcdDemoPage extends StatefulWidget {
  const UpdateSubscriptionBcdDemoPage({super.key});

  @override
  State<UpdateSubscriptionBcdDemoPage> createState() =>
      _UpdateSubscriptionBcdDemoPageState();
}

class _UpdateSubscriptionBcdDemoPageState
    extends State<UpdateSubscriptionBcdDemoPage> {
  final TextEditingController _subscriptionIdController = TextEditingController();
  final TextEditingController _accountIdController = TextEditingController();
  final TextEditingController _bundleIdController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _productCategoryController = TextEditingController();
  final TextEditingController _billingPeriodController = TextEditingController();
  final TextEditingController _priceListController = TextEditingController();
  final TextEditingController _phaseTypeController = TextEditingController();
  final TextEditingController _billCycleDayLocalController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _subscriptionIdController.text = '41b74b4b-4a19-4a5c-9be7-20b805e08c14';
    _accountIdController.text = '0f2ba9db-56c2-4a25-ac4e-11c12540852a';
    _bundleIdController.text = '7fcc23c9-4237-460f-8039-f4a82ade8366';
    _startDateController.text = '2023-01-01';
    _productNameController.text = 'Premium Plan';
    _productCategoryController.text = 'BASE';
    _billingPeriodController.text = 'MONTHLY';
    _priceListController.text = 'DEFAULT';
    _phaseTypeController.text = 'EVERGREEN';
    _billCycleDayLocalController.text = '15';
  }

  @override
  void dispose() {
    _subscriptionIdController.dispose();
    _accountIdController.dispose();
    _bundleIdController.dispose();
    _startDateController.dispose();
    _productNameController.dispose();
    _productCategoryController.dispose();
    _billingPeriodController.dispose();
    _priceListController.dispose();
    _phaseTypeController.dispose();
    _billCycleDayLocalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GetIt.instance<SubscriptionsBloc>(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Update Subscription BCD Demo')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'This demo allows you to update the Billing Cycle Day (BCD) for a subscription.',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _subscriptionIdController,
                    decoration: const InputDecoration(
                      labelText: 'Subscription ID',
                      border: OutlineInputBorder(),
                      hintText: 'e.g., 41b74b4b-4a19-4a5c-9be7-20b805e08c14',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a subscription ID';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _accountIdController,
                          decoration: const InputDecoration(
                            labelText: 'Account ID',
                            border: OutlineInputBorder(),
                            hintText: 'e.g., 0f2ba9db-56c2-4a25-ac4e-11c12540852a',
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
                          controller: _bundleIdController,
                          decoration: const InputDecoration(
                            labelText: 'Bundle ID',
                            border: OutlineInputBorder(),
                            hintText: 'e.g., 7fcc23c9-4237-460f-8039-f4a82ade8366',
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter a bundle ID';
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
                          controller: _startDateController,
                          decoration: const InputDecoration(
                            labelText: 'Start Date (YYYY-MM-DD)',
                            border: OutlineInputBorder(),
                            hintText: 'e.g., 2023-01-01',
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter a start date';
                            }
                            try {
                              DateTime.parse(value);
                            } catch (e) {
                              return 'Please enter a valid date (YYYY-MM-DD)';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _productNameController,
                          decoration: const InputDecoration(
                            labelText: 'Product Name',
                            border: OutlineInputBorder(),
                            hintText: 'e.g., Premium Plan',
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
                          controller: _productCategoryController,
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
                          controller: _billingPeriodController,
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
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _priceListController,
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
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _phaseTypeController,
                          decoration: const InputDecoration(
                            labelText: 'Phase Type',
                            border: OutlineInputBorder(),
                            hintText: 'e.g., EVERGREEN',
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter a phase type';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _billCycleDayLocalController,
                    decoration: const InputDecoration(
                      labelText: 'Bill Cycle Day Local (1-31)',
                      border: OutlineInputBorder(),
                      hintText: 'e.g., 15',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a bill cycle day';
                      }
                      final day = int.tryParse(value);
                      if (day == null || day < 1 || day > 31) {
                        return 'Please enter a valid day (1-31)';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _updateSubscriptionBcd,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Update Subscription BCD'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _updateSubscriptionBcd() {
    if (_formKey.currentState!.validate()) {
      final bcdData = {
        'accountId': _accountIdController.text.trim(),
        'bundleId': _bundleIdController.text.trim(),
        'subscriptionId': _subscriptionIdController.text.trim(),
        'startDate': _startDateController.text.trim(),
        'productName': _productNameController.text.trim(),
        'productCategory': _productCategoryController.text.trim(),
        'billingPeriod': _billingPeriodController.text.trim(),
        'priceList': _priceListController.text.trim(),
        'phaseType': _phaseTypeController.text.trim(),
        'billCycleDayLocal': int.parse(_billCycleDayLocalController.text.trim()),
      };

      context.read<SubscriptionsBloc>().add(UpdateSubscriptionBcd(
        subscriptionId: _subscriptionIdController.text.trim(),
        bcdData: bcdData,
      ));

      _showResultDialog('Update Subscription BCD', 'Updating subscription BCD...');
    }
  }

  void _showResultDialog(String title, String initialMessage) {
    showDialog(
      context: context,
      builder: (context) => BlocBuilder<SubscriptionsBloc, SubscriptionsState>(
        builder: (context, state) {
          if (state is UpdateSubscriptionBcdLoading) {
            return AlertDialog(
              title: Text(title),
              content: const Center(child: CircularProgressIndicator()),
            );
          } else if (state is UpdateSubscriptionBcdSuccess) {
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
          } else if (state is UpdateSubscriptionBcdError) {
            return AlertDialog(
              title: const Text('Error'),
              content: Text('Failed to update subscription BCD: ${state.message}'),
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
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Success: ${result['success'] ?? 'N/A'}'),
          Text('Code: ${result['code'] ?? 'N/A'}'),
          Text('Message: ${result['message'] ?? 'N/A'}'),
          if (result['data'] != null) ...[
            const SizedBox(height: 16),
            const Text(
              'Updated Subscription Details:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Account ID: ${result['data']['accountId'] ?? 'N/A'}'),
            Text('Bundle ID: ${result['data']['bundleId'] ?? 'N/A'}'),
            Text('Subscription ID: ${result['data']['subscriptionId'] ?? 'N/A'}'),
            Text('Product Name: ${result['data']['productName'] ?? 'N/A'}'),
            Text('Product Category: ${result['data']['productCategory'] ?? 'N/A'}'),
            Text('Billing Period: ${result['data']['billingPeriod'] ?? 'N/A'}'),
            Text('Phase Type: ${result['data']['phaseType'] ?? 'N/A'}'),
            Text('Price List: ${result['data']['priceList'] ?? 'N/A'}'),
            Text('Plan Name: ${result['data']['planName'] ?? 'N/A'}'),
            Text('State: ${result['data']['state'] ?? 'N/A'}'),
            Text('Bill Cycle Day: ${result['data']['billCycleDayLocal'] ?? 'N/A'}'),
            Text('Quantity: ${result['data']['quantity'] ?? 'N/A'}'),
          ],
        ],
      ),
    );
  }
}
