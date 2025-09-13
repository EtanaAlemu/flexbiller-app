import 'package:flutter/material.dart';
import '../../domain/entities/tag.dart';

class ExportTagsDialog extends StatefulWidget {
  final List<Tag> tags;

  const ExportTagsDialog({Key? key, required this.tags}) : super(key: key);

  @override
  State<ExportTagsDialog> createState() => _ExportTagsDialogState();
}

class _ExportTagsDialogState extends State<ExportTagsDialog> {
  String _selectedFormat = 'csv';
  bool _includeAllFields = true;
  List<String> _selectedFields = [
    'Tag ID',
    'Tag Definition Name',
    'Object Type',
    'Object ID',
    'Tag Definition ID',
    'Audit Logs Count',
  ];

  final List<String> _availableFields = [
    'Tag ID',
    'Tag Definition Name',
    'Object Type',
    'Object ID',
    'Tag Definition ID',
    'Audit Logs Count',
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.download, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          const Text('Export Tags'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Export ${widget.tags.length} tags to:',
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
                  } else {
                    _selectedFields = [];
                  }
                });
              },
            ),
            if (!_includeAllFields) ...[
              const SizedBox(height: 8),
              Container(
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
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
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _selectedFields.isEmpty && !_includeAllFields
              ? null
              : _exportTags,
          child: const Text('Export'),
        ),
      ],
    );
  }

  void _exportTags() {
    // Return the selected format and fields
    Navigator.of(context).pop({
      'format': _selectedFormat,
      'fields': _includeAllFields ? _availableFields : _selectedFields,
    });
  }
}
