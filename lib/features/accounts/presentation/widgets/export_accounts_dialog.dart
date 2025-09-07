import 'package:flutter/material.dart';
import '../../domain/entities/account.dart';

class ExportAccountsDialog extends StatefulWidget {
  final List<Account> accounts;

  const ExportAccountsDialog({Key? key, required this.accounts})
    : super(key: key);

  @override
  State<ExportAccountsDialog> createState() => _ExportAccountsDialogState();
}

class _ExportAccountsDialogState extends State<ExportAccountsDialog> {
  String _selectedFormat = 'csv';
  bool _includeAllFields = true;
  List<String> _selectedFields = [
    'Account ID',
    'Name',
    'Email',
    'Company',
    'Phone',
    'Address',
    'Currency',
    'Balance',
  ];

  final List<String> _availableFields = [
    'Account ID',
    'Name',
    'Email',
    'Company',
    'Phone',
    'Address',
    'City',
    'State',
    'Country',
    'Currency',
    'Time Zone',
    'Balance',
    'CBA',
    'Created At',
    'Notes',
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.download, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          const Text('Export Accounts'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Export ${widget.accounts.length} accounts to:',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),

            // Format Selection
            Text(
              'Format:',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('CSV'),
                    subtitle: const Text('Comma-separated values'),
                    value: 'csv',
                    groupValue: _selectedFormat,
                    onChanged: (value) {
                      setState(() {
                        _selectedFormat = value!;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Excel'),
                    subtitle: const Text('Microsoft Excel format'),
                    value: 'excel',
                    groupValue: _selectedFormat,
                    onChanged: (value) {
                      setState(() {
                        _selectedFormat = value!;
                      });
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Field Selection
            Text(
              'Fields to include:',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            CheckboxListTile(
              title: const Text('Include all fields'),
              value: _includeAllFields,
              onChanged: (value) {
                setState(() {
                  _includeAllFields = value!;
                  if (_includeAllFields) {
                    _selectedFields = List.from(_availableFields);
                  }
                });
              },
            ),

            if (!_includeAllFields) ...[
              const SizedBox(height: 8),
              Container(
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView.builder(
                  itemCount: _availableFields.length,
                  itemBuilder: (context, index) {
                    final field = _availableFields[index];
                    return CheckboxListTile(
                      title: Text(field),
                      value: _selectedFields.contains(field),
                      onChanged: (value) {
                        setState(() {
                          if (value!) {
                            _selectedFields.add(field);
                          } else {
                            _selectedFields.remove(field);
                          }
                        });
                      },
                    );
                  },
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Export Info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Export Information',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• ${widget.accounts.length} accounts will be exported',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    '• File will be saved to app documents folder',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    '• Format: ${_selectedFormat.toUpperCase()}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton.icon(
          onPressed: _selectedFields.isEmpty
              ? null
              : () {
                  Navigator.of(
                    context,
                  ).pop({'format': _selectedFormat, 'fields': _selectedFields});
                },
          icon: const Icon(Icons.download),
          label: const Text('Export'),
        ),
      ],
    );
  }
}
