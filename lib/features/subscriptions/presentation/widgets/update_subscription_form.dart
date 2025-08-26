import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/subscriptions_bloc.dart';
import '../bloc/subscriptions_event.dart';
import '../bloc/subscriptions_state.dart';
import '../../domain/entities/subscription.dart';

class UpdateSubscriptionForm extends StatefulWidget {
  final Subscription subscription;
  final VoidCallback? onSuccess;

  const UpdateSubscriptionForm({
    super.key,
    required this.subscription,
    this.onSuccess,
  });

  @override
  State<UpdateSubscriptionForm> createState() => _UpdateSubscriptionFormState();
}

class _UpdateSubscriptionFormState extends State<UpdateSubscriptionForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _productNameController;
  late TextEditingController _planNameController;
  late TextEditingController _billingPeriodController;
  late TextEditingController _phaseTypeController;
  late TextEditingController _stateController;
  late TextEditingController _quantityController;
  late TextEditingController _billCycleDayController;
  late TextEditingController _chargedThroughController;

  @override
  void initState() {
    super.initState();
    _productNameController = TextEditingController(
      text: widget.subscription.productName,
    );
    _planNameController = TextEditingController(
      text: widget.subscription.planName,
    );
    _billingPeriodController = TextEditingController(
      text: widget.subscription.billingPeriod,
    );
    _phaseTypeController = TextEditingController(
      text: widget.subscription.phaseType,
    );
    _stateController = TextEditingController(text: widget.subscription.state);
    _quantityController = TextEditingController(
      text: widget.subscription.quantity.toString(),
    );
    _billCycleDayController = TextEditingController(
      text: widget.subscription.billCycleDayLocal.toString(),
    );
    _chargedThroughController = TextEditingController(
      text: widget.subscription.chargedThroughDate,
    );
  }

  @override
  void dispose() {
    _productNameController.dispose();
    _planNameController.dispose();
    _billingPeriodController.dispose();
    _phaseTypeController.dispose();
    _stateController.dispose();
    _quantityController.dispose();
    _billCycleDayController.dispose();
    _chargedThroughController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SubscriptionsBloc, SubscriptionsState>(
      listener: (context, state) {
        if (state is UpdateSubscriptionSuccess) {
          _showSuccessDialog(context, state.subscription);
          widget.onSuccess?.call();
        } else if (state is UpdateSubscriptionError) {
          _showErrorSnackBar(context, state.message);
        }
      },
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Update Subscription',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'ID: ${widget.subscription.subscriptionId}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(
                  context,
                ).textTheme.bodySmall?.color?.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            _buildBasicInfoSection(),
            const SizedBox(height: 16),
            _buildBillingInfoSection(),
            const SizedBox(height: 24),
            BlocBuilder<SubscriptionsBloc, SubscriptionsState>(
              builder: (context, state) {
                final isLoading = state is UpdateSubscriptionLoading;

                return ElevatedButton.icon(
                  onPressed: isLoading ? null : _updateSubscription,
                  icon: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save),
                  label: Text(
                    isLoading ? 'Updating...' : 'Update Subscription',
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            _buildSampleValues(),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Basic Information',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _productNameController,
                    decoration: const InputDecoration(
                      labelText: 'Product Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter product name';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _planNameController,
                    decoration: const InputDecoration(
                      labelText: 'Plan Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter plan name';
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
                    controller: _billingPeriodController,
                    decoration: const InputDecoration(
                      labelText: 'Billing Period',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter billing period';
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
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter phase type';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBillingInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Billing Information',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _stateController,
                    decoration: const InputDecoration(
                      labelText: 'State',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter state';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _quantityController,
                    decoration: const InputDecoration(
                      labelText: 'Quantity',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter quantity';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Please enter a valid number';
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
                    controller: _billCycleDayController,
                    decoration: const InputDecoration(
                      labelText: 'Bill Cycle Day',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter bill cycle day';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _chargedThroughController,
                    decoration: const InputDecoration(
                      labelText: 'Charged Through',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSampleValues() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Sample Values:', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            _buildSampleChip('Billing Period', [
              'MONTHLY',
              'WEEKLY',
              'DAILY',
              'YEARLY',
            ]),
            _buildSampleChip('Phase Type', ['TRIAL', 'EVERGREEN', 'DISCOUNT']),
            _buildSampleChip('State', [
              'ACTIVE',
              'PENDING',
              'BLOCKED',
              'CANCELLED',
            ]),
          ],
        ),
      ],
    );
  }

  Widget _buildSampleChip(String label, List<String> values) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 4),
        Wrap(
          spacing: 4,
          children: values
              .map(
                (value) => ActionChip(
                  label: Text(value),
                  onPressed: () {
                    switch (label) {
                      case 'Billing Period':
                        _billingPeriodController.text = value;
                        break;
                      case 'Phase Type':
                        _phaseTypeController.text = value;
                        break;
                      case 'State':
                        _stateController.text = value;
                        break;
                    }
                  },
                  avatar: const Icon(Icons.edit, size: 16),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  void _updateSubscription() {
    if (_formKey.currentState!.validate()) {
      final updateData = {
        'accountId': widget.subscription.accountId,
        'bundleId': widget.subscription.bundleId,
        'bundleExternalKey': widget.subscription.bundleExternalKey,
        'subscriptionId': widget.subscription.subscriptionId,
        'externalKey': widget.subscription.externalKey,
        'startDate': widget.subscription.startDate.toIso8601String(),
        'productName': _productNameController.text.trim(),
        'productCategory': widget.subscription.productCategory,
        'billingPeriod': _billingPeriodController.text.trim(),
        'phaseType': _phaseTypeController.text.trim(),
        'priceList': widget.subscription.priceList,
        'planName': _planNameController.text.trim(),
        'state': _stateController.text.trim(),
        'sourceType': widget.subscription.sourceType,
        'cancelledDate': widget.subscription.cancelledDate?.toIso8601String(),
        'chargedThroughDate': _chargedThroughController.text.trim().isNotEmpty
            ? _chargedThroughController.text.trim()
            : null,
        'billingStartDate': widget.subscription.billingStartDate
            .toIso8601String(),
        'billingEndDate': widget.subscription.billingEndDate?.toIso8601String(),
        'billCycleDayLocal': int.parse(_billCycleDayController.text.trim()),
        'quantity': int.parse(_quantityController.text.trim()),
        'events': widget.subscription.events
            .map(
              (e) => {
                'eventId': e.eventId,
                'billingPeriod': e.billingPeriod,
                'effectiveDate': e.effectiveDate.toIso8601String(),
                'catalogEffectiveDate': e.catalogEffectiveDate
                    .toIso8601String(),
                'plan': e.plan,
                'product': e.product,
                'priceList': e.priceList,
                'eventType': e.eventType,
                'isBlockedBilling': e.isBlockedBilling,
                'isBlockedEntitlement': e.isBlockedEntitlement,
                'serviceName': e.serviceName,
                'serviceStateName': e.serviceStateName,
                'phase': e.phase,
                'auditLogs': e.auditLogs ?? [],
              },
            )
            .toList(),
        'priceOverrides': widget.subscription.priceOverrides,
        'prices': widget.subscription.prices,
        'auditLogs': widget.subscription.auditLogs,
      };

      context.read<SubscriptionsBloc>().add(
        UpdateSubscription(
          subscriptionId: widget.subscription.subscriptionId,
          updateData: updateData,
        ),
      );
    }
  }

  void _showSuccessDialog(BuildContext context, dynamic subscription) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Subscription Updated Successfully!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Subscription ID: ${subscription.subscriptionId}'),
            Text('Plan: ${subscription.planName}'),
            Text('State: ${subscription.state}'),
            Text('Product: ${subscription.productName}'),
            Text('Billing Period: ${subscription.billingPeriod}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
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
