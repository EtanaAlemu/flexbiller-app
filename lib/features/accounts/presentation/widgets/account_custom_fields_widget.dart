import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/account_custom_field.dart';
import '../bloc/accounts_bloc.dart';
import '../bloc/accounts_event.dart';
import '../bloc/accounts_state.dart';

class AccountCustomFieldsWidget extends StatelessWidget {
  final String accountId;

  const AccountCustomFieldsWidget({Key? key, required this.accountId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccountsBloc, AccountsState>(
      builder: (context, state) {
        if (state is AccountCustomFieldsLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (state is AccountCustomFieldsFailure) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'Failed to load custom fields',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  state.message,
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<AccountsBloc>().add(
                          RefreshAccountCustomFields(accountId),
                        );
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (state is AccountCustomFieldsLoaded) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Custom Fields (${state.customFields.length})',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.delete_sweep),
                        onPressed: () => _showDeleteMultipleCustomFieldsDialog(context, state.customFields),
                        tooltip: 'Delete Multiple Fields',
                        color: Colors.red[400],
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_note),
                        onPressed: () => _showEditMultipleCustomFieldsDialog(context, state.customFields),
                        tooltip: 'Edit Multiple Fields',
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () => _showAddMultipleCustomFieldsDialog(context),
                        tooltip: 'Add Multiple Fields',
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () => _showAddCustomFieldDialog(context),
                        tooltip: 'Add Custom Field',
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (state.customFields.isEmpty)
                Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.category_outlined,
                        size: 48,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No custom fields',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add custom fields to store additional information',
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => _showAddCustomFieldDialog(context),
                        icon: const Icon(Icons.add),
                        label: const Text('Add First Custom Field'),
                      ),
                    ],
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: state.customFields.length,
                  itemBuilder: (context, index) {
                    final customField = state.customFields[index];
                    return _buildCustomFieldCard(context, customField);
                  },
                ),
            ],
          );
        }

        return const Center(child: Text('No custom fields data available'));
      },
    );
  }

  Widget _buildCustomFieldCard(BuildContext context, AccountCustomField customField) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    customField.displayName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        _showEditCustomFieldDialog(context, customField);
                        break;
                      case 'delete':
                        _showDeleteCustomFieldDialog(context, customField);
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 20),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 20, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                  child: const Icon(Icons.more_vert),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              customField.displayValue,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (customField.hasAuditLogs) ...[
              const SizedBox(height: 16),
              Text(
                'History',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              ...customField.auditLogs.take(3).map((log) => _buildAuditLogItem(context, log)),
              if (customField.auditLogs.length > 3)
                TextButton(
                  onPressed: () => _showFullHistoryDialog(context, customField),
                  child: Text('View all ${customField.auditLogs.length} changes'),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAuditLogItem(BuildContext context, CustomFieldAuditLog log) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: _parseColor(log.changeTypeColor),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            _parseIcon(log.changeTypeIcon),
            size: 16,
            color: _parseColor(log.changeTypeColor),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${log.changeTypeDisplay} by ${log.changedBy}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          Text(
            log.formattedChangeDate,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddCustomFieldDialog(BuildContext context) {
    final nameController = TextEditingController();
    final valueController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Custom Field'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Field Name',
                hintText: 'Enter field name',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: valueController,
              decoration: const InputDecoration(
                labelText: 'Field Value',
                hintText: 'Enter field value',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty && valueController.text.isNotEmpty) {
                Navigator.of(context).pop();
                context.read<AccountsBloc>().add(
                      CreateAccountCustomField(
                        accountId,
                        nameController.text.trim(),
                        valueController.text.trim(),
                      ),
                    );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showAddMultipleCustomFieldsDialog(BuildContext context) {
    final List<Map<String, TextEditingController>> fieldControllers = [
      {'name': TextEditingController(), 'value': TextEditingController()},
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Multiple Custom Fields'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ...fieldControllers.map((controllers) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: controllers['name']!,
                          decoration: const InputDecoration(
                            labelText: 'Field Name',
                            hintText: 'Enter field name',
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: controllers['value']!,
                          decoration: const InputDecoration(
                            labelText: 'Field Value',
                            hintText: 'Enter field value',
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      fieldControllers.add({
                        'name': TextEditingController(),
                        'value': TextEditingController(),
                      });
                    });
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Another Field'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final customFields = <Map<String, String>>[];
                bool hasValidFields = false;

                for (final controllers in fieldControllers) {
                  final name = controllers['name']!.text.trim();
                  final value = controllers['value']!.text.trim();
                  if (name.isNotEmpty && value.isNotEmpty) {
                    customFields.add({'name': name, 'value': value});
                    hasValidFields = true;
                  }
                }

                if (hasValidFields) {
                  Navigator.of(context).pop();
                  if (customFields.length == 1) {
                    // Single field - use single creation
                    final field = customFields.first;
                    context.read<AccountsBloc>().add(
                          CreateAccountCustomField(
                            accountId,
                            field['name']!,
                            field['value']!,
                          ),
                        );
                  } else {
                    // Multiple fields - use bulk creation
                    context.read<AccountsBloc>().add(
                          CreateMultipleAccountCustomFields(accountId, customFields),
                        );
                  }
                }
              },
              child: const Text('Add Fields'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditCustomFieldDialog(BuildContext context, AccountCustomField customField) {
    final nameController = TextEditingController(text: customField.name);
    final valueController = TextEditingController(text: customField.value);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Custom Field'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Field Name',
                hintText: 'Enter field name',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: valueController,
              decoration: const InputDecoration(
                labelText: 'Field Value',
                hintText: 'Enter field value',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty && valueController.text.isNotEmpty) {
                Navigator.of(context).pop();
                context.read<AccountsBloc>().add(
                      UpdateAccountCustomField(
                        accountId,
                        customField.customFieldId,
                        nameController.text.trim(),
                        valueController.text.trim(),
                      ),
                    );
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showEditMultipleCustomFieldsDialog(BuildContext context, List<AccountCustomField> customFields) {
    final List<Map<String, dynamic>> fieldControllers = customFields.map((field) => {
      'customFieldId': field.customFieldId,
      'name': TextEditingController(text: field.name),
      'value': TextEditingController(text: field.value),
    }).toList();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit Multiple Custom Fields'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ...fieldControllers.map((controllers) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Field ID: ${controllers['customFieldId']}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: controllers['name'] as TextEditingController,
                              decoration: const InputDecoration(
                                labelText: 'Field Name',
                                hintText: 'Enter field name',
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: controllers['value'] as TextEditingController,
                              decoration: const InputDecoration(
                                labelText: 'Field Value',
                                hintText: 'Enter field value',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final updatedFields = <Map<String, dynamic>>[];
                bool hasValidFields = false;

                for (final controllers in fieldControllers) {
                  final customFieldId = controllers['customFieldId'] as String;
                  final name = (controllers['name'] as TextEditingController).text.trim();
                  final value = (controllers['value'] as TextEditingController).text.trim();
                  
                  if (name.isNotEmpty && value.isNotEmpty) {
                    updatedFields.add({
                      'customFieldId': customFieldId,
                      'name': name,
                      'value': value,
                    });
                    hasValidFields = true;
                  }
                }

                if (hasValidFields) {
                  Navigator.of(context).pop();
                  if (updatedFields.length == 1) {
                    // Single field - use single update
                    final field = updatedFields.first;
                    context.read<AccountsBloc>().add(
                          UpdateAccountCustomField(
                            accountId,
                            field['customFieldId'] as String,
                            field['name'] as String,
                            field['value'] as String,
                          ),
                        );
                  } else {
                    // Multiple fields - use bulk update
                    context.read<AccountsBloc>().add(
                          UpdateMultipleAccountCustomFields(accountId, updatedFields),
                        );
                  }
                }
              },
              child: const Text('Update Fields'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteCustomFieldDialog(BuildContext context, AccountCustomField customField) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Custom Field'),
        content: Text(
          'Are you sure you want to delete the custom field "${customField.name}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<AccountsBloc>().add(
                    DeleteAccountCustomField(accountId, customField.customFieldId),
                  );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showDeleteMultipleCustomFieldsDialog(BuildContext context, List<AccountCustomField> customFields) {
    final List<String> selectedFieldIds = <String>[];
    final List<AccountCustomField> availableFields = List.from(customFields);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Delete Multiple Custom Fields'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Select the custom fields you want to delete:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ...availableFields.map((field) => CheckboxListTile(
                  title: Text(field.name),
                  subtitle: Text('Value: ${field.value}'),
                  value: selectedFieldIds.contains(field.customFieldId),
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        selectedFieldIds.add(field.customFieldId);
                      } else {
                        selectedFieldIds.remove(field.customFieldId);
                      }
                    });
                  },
                )),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: selectedFieldIds.isEmpty
                  ? null
                  : () {
                      Navigator.of(context).pop();
                      if (selectedFieldIds.length == 1) {
                        // Single field - use single delete
                        context.read<AccountsBloc>().add(
                              DeleteAccountCustomField(accountId, selectedFieldIds.first),
                            );
                      } else {
                        // Multiple fields - use bulk delete
                        context.read<AccountsBloc>().add(
                              DeleteMultipleAccountCustomFields(accountId, selectedFieldIds),
                            );
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text('Delete ${selectedFieldIds.length} Field${selectedFieldIds.length == 1 ? '' : 's'}'),
            ),
          ],
        ),
      ),
    );
  }

  void _showFullHistoryDialog(BuildContext context, AccountCustomField customField) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('History for ${customField.name}'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: customField.auditLogs.length,
            itemBuilder: (context, index) {
              final log = customField.auditLogs[index];
              return _buildAuditLogItem(context, log);
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Color _parseColor(String colorString) {
    try {
      if (colorString.startsWith('#')) {
        return Color(int.parse(colorString.substring(1), radix: 16) + 0xFF000000);
      }
      return Colors.blue;
    } catch (e) {
      return Colors.blue;
    }
  }

  IconData _parseIcon(String iconString) {
    switch (iconString) {
      case 'add_circle':
        return Icons.add_circle;
      case 'edit':
        return Icons.edit;
      case 'delete':
        return Icons.delete;
      default:
        return Icons.info;
    }
  }
}
