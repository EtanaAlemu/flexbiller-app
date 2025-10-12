import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../domain/entities/bundle.dart';

class ExportBundlesDialog extends StatefulWidget {
  final List<Bundle> bundles;

  const ExportBundlesDialog({Key? key, required this.bundles})
    : super(key: key);

  @override
  State<ExportBundlesDialog> createState() => _ExportBundlesDialogState();
}

class _ExportBundlesDialogState extends State<ExportBundlesDialog> {
  String _selectedFormat = 'csv';
  bool _includeAllFields = true;
  List<String> _selectedFields = [
    'Bundle ID',
    'Account ID',
    'External Key',
    'Subscriptions Count',
    'Status',
    'Created Date',
  ];

  final List<String> _availableFields = [
    'Bundle ID',
    'Account ID',
    'External Key',
    'Subscriptions Count',
    'Status',
    'Created Date',
    'Timeline Events Count',
    'Audit Logs Count',
    'Product Names',
    'Plan Names',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.file_download_rounded,
                    color: colorScheme.onPrimaryContainer,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Export Bundles',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Export ${widget.bundles.length} selected bundle(s)',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onPrimaryContainer.withOpacity(
                              0.8,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Format Selection
                    _buildSectionTitle(
                      'Export Format',
                      Icons.file_download_rounded,
                    ),
                    const SizedBox(height: 16),
                    _buildFormatSelector(theme, colorScheme),

                    const SizedBox(height: 32),

                    // Field Selection
                    _buildSectionTitle('Fields to Include', Icons.list_rounded),
                    const SizedBox(height: 16),
                    _buildFieldSelector(theme, colorScheme),

                    const SizedBox(height: 24),

                    // Export Summary
                    _buildExportSummary(theme, colorScheme),
                  ],
                ),
              ),
            ),

            // Actions
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.surfaceVariant.withOpacity(0.3),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  FilledButton.icon(
                    onPressed: _selectedFields.isEmpty
                        ? null
                        : () {
                            Navigator.of(context).pop({
                              'format': _selectedFormat,
                              'fields': _selectedFields,
                            });
                          },
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    icon: const Icon(Icons.download_rounded),
                    label: const Text('Export'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildFormatSelector(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          RadioListTile<String>(
            title: Row(
              children: [
                Icon(
                  Icons.table_chart_rounded,
                  size: 20,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                const Text('CSV'),
              ],
            ),
            subtitle: const Text('Comma-separated values'),
            value: 'csv',
            groupValue: _selectedFormat,
            onChanged: (value) {
              setState(() {
                _selectedFormat = value!;
              });
            },
            activeColor: colorScheme.primary,
          ),
          RadioListTile<String>(
            title: Row(
              children: [
                Icon(
                  Icons.table_view_rounded,
                  size: 20,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                const Text('Excel'),
              ],
            ),
            subtitle: const Text('Microsoft Excel format'),
            value: 'excel',
            groupValue: _selectedFormat,
            onChanged: (value) {
              setState(() {
                _selectedFormat = value!;
              });
            },
            activeColor: colorScheme.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildFieldSelector(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          // Include All Fields Toggle
          SwitchListTile(
            title: const Text('Include All Fields'),
            subtitle: const Text('Export all available fields'),
            value: _includeAllFields,
            onChanged: (value) {
              setState(() {
                _includeAllFields = value;
                if (value) {
                  _selectedFields = List.from(_availableFields);
                } else {
                  _selectedFields = [];
                }
              });
            },
            activeColor: colorScheme.primary,
          ),
          const Divider(),
          // Individual Field Selection
          if (!_includeAllFields) ...[
            const SizedBox(height: 8),
            ..._availableFields.map(
              (field) => CheckboxListTile(
                title: Text(field),
                value: _selectedFields.contains(field),
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      _selectedFields.add(field);
                    } else {
                      _selectedFields.remove(field);
                    }
                  });
                },
                activeColor: colorScheme.primary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildExportSummary(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.primary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 20,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Export Summary',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '• ${widget.bundles.length} bundle(s) will be exported',
            style: theme.textTheme.bodySmall,
          ),
          Text(
            '• Format: ${_selectedFormat.toUpperCase()}',
            style: theme.textTheme.bodySmall,
          ),
          Text(
            '• Fields: ${_includeAllFields ? _availableFields.length : _selectedFields.length} selected',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
