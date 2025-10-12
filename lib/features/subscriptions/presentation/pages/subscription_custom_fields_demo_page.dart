import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/subscriptions_bloc.dart';
import '../bloc/subscriptions_event.dart';
import '../bloc/subscriptions_state.dart';
import '../../domain/entities/subscription_custom_field.dart';

class SubscriptionCustomFieldsDemoPage extends StatefulWidget {
  const SubscriptionCustomFieldsDemoPage({super.key});

  @override
  State<SubscriptionCustomFieldsDemoPage> createState() =>
      _SubscriptionCustomFieldsDemoPageState();
}

class _SubscriptionCustomFieldsDemoPageState
    extends State<SubscriptionCustomFieldsDemoPage> {
  final TextEditingController _subscriptionIdController =
      TextEditingController();
  final TextEditingController _customFieldNameController =
      TextEditingController();
  final TextEditingController _customFieldValueController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _subscriptionIdController.text = '41b74b4b-4a19-4a5c-9be7-20b805e08c14';
    _customFieldNameController.text = 'field3';
    _customFieldValueController.text = 'value3';
  }

  @override
  void dispose() {
    _subscriptionIdController.dispose();
    _customFieldNameController.dispose();
    _customFieldValueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom Fields'),
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
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.settings_input_component,
                              color: Theme.of(context).colorScheme.primary,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Subscription Custom Fields',
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'This demo allows you to manage custom fields for subscriptions:',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 8),
                        _buildFeatureItem(
                          '• Add custom fields to subscriptions',
                        ),
                        _buildFeatureItem('• Retrieve existing custom fields'),
                        _buildFeatureItem('• Update custom field values'),
                        _buildFeatureItem('• Remove custom fields'),
                        _buildFeatureItem('• Handle all CRUD operations'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _subscriptionIdController,
                  decoration: InputDecoration(
                    labelText: 'Subscription ID',
                    hintText: 'Enter the subscription ID',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.fingerprint_rounded),
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerHighest,
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
                        controller: _customFieldNameController,
                        decoration: InputDecoration(
                          labelText: 'Field Name',
                          hintText: 'Enter field name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.label_rounded),
                          filled: true,
                          fillColor: theme.colorScheme.surfaceContainerHighest,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a field name';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _customFieldValueController,
                        decoration: InputDecoration(
                          labelText: 'Field Value',
                          hintText: 'Enter field value',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.input_rounded),
                          filled: true,
                          fillColor: theme.colorScheme.surfaceContainerHighest,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a field value';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _addCustomFields,
                        icon: const Icon(Icons.add_rounded),
                        label: const Text('Add Fields'),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _getCustomFields,
                        icon: const Icon(Icons.list_rounded),
                        label: const Text('Get Fields'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          foregroundColor: theme.colorScheme.primary,
                          side: BorderSide(color: theme.colorScheme.primary),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _updateCustomFields,
                        icon: const Icon(Icons.edit_rounded),
                        label: const Text('Update Fields'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          foregroundColor: theme.colorScheme.tertiary,
                          side: BorderSide(color: theme.colorScheme.tertiary),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _removeCustomFields,
                        icon: const Icon(Icons.delete_rounded),
                        label: const Text('Remove Fields'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          foregroundColor: theme.colorScheme.error,
                          side: BorderSide(color: theme.colorScheme.error),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),
                Text(
                  'Sample Subscription ID for testing:',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                _buildSampleId(
                  '41b74b4b-4a19-4a5c-9be7-20b805e08c14',
                  'Sample subscription with custom fields',
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withValues(
                      alpha: 0.1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.api_rounded,
                            color: theme.colorScheme.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'API Endpoints:',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _buildApiEndpoint(
                        'POST',
                        '/api/subscriptions/{id}/customFields',
                        'Add custom fields',
                      ),
                      _buildApiEndpoint(
                        'GET',
                        '/api/subscriptions/{id}/customFields',
                        'Get custom fields',
                      ),
                      _buildApiEndpoint(
                        'PUT',
                        '/api/subscriptions/{id}/customFields',
                        'Update custom fields',
                      ),
                      _buildApiEndpoint(
                        'DELETE',
                        '/api/subscriptions/{id}/customFields',
                        'Remove custom fields',
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

  Widget _buildFeatureItem(String text) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildSampleId(String id, String description) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          setState(() {
            _subscriptionIdController.text = id;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(
                context,
              ).colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                id,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildApiEndpoint(String method, String endpoint, String description) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getMethodColor(method),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  method,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  endpoint,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Color _getMethodColor(String method) {
    switch (method) {
      case 'GET':
        return Colors.blue;
      case 'POST':
        return Colors.green;
      case 'PUT':
        return Colors.orange;
      case 'DELETE':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _addCustomFields() {
    if (_formKey.currentState!.validate()) {
      final subscriptionId = _subscriptionIdController.text.trim();
      final customFields = [
        {
          'name': _customFieldNameController.text.trim(),
          'value': _customFieldValueController.text.trim(),
        },
      ];

      context.read<SubscriptionsBloc>().add(
        AddSubscriptionCustomFields(
          subscriptionId: subscriptionId,
          customFields: customFields,
        ),
      );

      _showResultDialog('Add Custom Fields', 'Adding custom fields...');
    }
  }

  void _getCustomFields() {
    if (_formKey.currentState!.validate()) {
      final subscriptionId = _subscriptionIdController.text.trim();

      context.read<SubscriptionsBloc>().add(
        GetSubscriptionCustomFields(subscriptionId),
      );

      _showResultDialog('Get Custom Fields', 'Loading custom fields...');
    }
  }

  void _updateCustomFields() {
    if (_formKey.currentState!.validate()) {
      final subscriptionId = _subscriptionIdController.text.trim();
      final customFields = [
        {
          'customFieldId': 'a1571a46-29f9-4514-8a8d-894e1ffd8dfc', // Sample ID
          'name': _customFieldNameController.text.trim(),
          'value': _customFieldValueController.text.trim(),
        },
      ];

      context.read<SubscriptionsBloc>().add(
        UpdateSubscriptionCustomFields(
          subscriptionId: subscriptionId,
          customFields: customFields,
        ),
      );

      _showResultDialog('Update Custom Fields', 'Updating custom fields...');
    }
  }

  void _removeCustomFields() {
    if (_formKey.currentState!.validate()) {
      final subscriptionId = _subscriptionIdController.text.trim();
      final customFieldIds =
          'a1571a46-29f9-4514-8a8d-894e1ffd8dfc'; // Sample ID

      context.read<SubscriptionsBloc>().add(
        RemoveSubscriptionCustomFields(
          subscriptionId: subscriptionId,
          customFieldIds: customFieldIds,
        ),
      );

      _showResultDialog('Remove Custom Fields', 'Removing custom fields...');
    }
  }

  void _showResultDialog(String title, String initialMessage) {
    final bloc = context.read<SubscriptionsBloc>();
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: bloc,
        child: BlocBuilder<SubscriptionsBloc, SubscriptionsState>(
          builder: (context, state) {
            if (state is AddSubscriptionCustomFieldsLoading ||
                state is SubscriptionCustomFieldsLoading ||
                state is UpdateSubscriptionCustomFieldsLoading ||
                state is RemoveSubscriptionCustomFieldsLoading) {
              return AlertDialog(
                title: Text(title),
                content: const Center(child: CircularProgressIndicator()),
              );
            } else if (state is AddSubscriptionCustomFieldsSuccess) {
              return AlertDialog(
                title: const Text('Success!'),
                content: _buildCustomFieldsList(state.customFields),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('OK'),
                  ),
                ],
              );
            } else if (state is SubscriptionCustomFieldsLoaded) {
              return AlertDialog(
                title: const Text('Custom Fields'),
                content: _buildCustomFieldsList(state.customFields),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('OK'),
                  ),
                ],
              );
            } else if (state is UpdateSubscriptionCustomFieldsSuccess) {
              return AlertDialog(
                title: const Text('Success!'),
                content: _buildCustomFieldsList(state.customFields),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('OK'),
                  ),
                ],
              );
            } else if (state is RemoveSubscriptionCustomFieldsSuccess) {
              return AlertDialog(
                title: const Text('Success!'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Removed custom fields from subscription:'),
                    const SizedBox(height: 8),
                    Text('Subscription ID: ${state.result['subscriptionId']}'),
                    Text(
                      'Removed Fields: ${state.result['removedCustomFields'].join(', ')}',
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('OK'),
                  ),
                ],
              );
            } else if (state is AddSubscriptionCustomFieldsError ||
                state is SubscriptionCustomFieldsError ||
                state is UpdateSubscriptionCustomFieldsError ||
                state is RemoveSubscriptionCustomFieldsError) {
              String errorMessage = '';
              if (state is AddSubscriptionCustomFieldsError) {
                errorMessage = state.message;
              } else if (state is SubscriptionCustomFieldsError) {
                errorMessage = state.message;
              } else if (state is UpdateSubscriptionCustomFieldsError) {
                errorMessage = state.message;
              } else if (state is RemoveSubscriptionCustomFieldsError) {
                errorMessage = state.message;
              }

              return AlertDialog(
                title: const Text('Error'),
                content: Text('Failed to perform operation: $errorMessage'),
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
      ),
    );
  }

  Widget _buildCustomFieldsList(List<SubscriptionCustomField> customFields) {
    if (customFields.isEmpty) {
      return const Text('No custom fields found.');
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Found ${customFields.length} custom field(s):'),
        const SizedBox(height: 8),
        ...customFields.map(
          (field) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (field.customFieldId != null)
                  Text(
                    'ID: ${field.customFieldId}',
                    style: const TextStyle(fontSize: 12),
                  ),
                Text(
                  'Name: ${field.name}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text('Value: ${field.value}'),
                if (field.objectType != null)
                  Text(
                    'Type: ${field.objectType}',
                    style: const TextStyle(fontSize: 12),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
