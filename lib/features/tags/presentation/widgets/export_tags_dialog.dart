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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 8,
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
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.download_rounded,
                      color: colorScheme.onPrimary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Export Tags',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${widget.tags.length} tags ready to export',
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Icon(icon, size: 20, color: colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildFormatSelector(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          _buildFormatOption(
            theme,
            colorScheme,
            'csv',
            'CSV',
            'Comma-separated values',
            Icons.table_chart_rounded,
          ),
          Container(height: 1, color: colorScheme.outline.withOpacity(0.1)),
          _buildFormatOption(
            theme,
            colorScheme,
            'excel',
            'Excel',
            'Microsoft Excel format',
            Icons.table_view_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildFormatOption(
    ThemeData theme,
    ColorScheme colorScheme,
    String value,
    String title,
    String subtitle,
    IconData icon,
  ) {
    final isSelected = _selectedFormat == value;

    return InkWell(
      onTap: () => setState(() => _selectedFormat = value),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 20,
                color: isSelected
                    ? colorScheme.onPrimary
                    : colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            Radio<String>(
              value: value,
              groupValue: _selectedFormat,
              onChanged: (val) => setState(() => _selectedFormat = val!),
              activeColor: colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldSelector(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      children: [
        // Include all fields toggle
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surfaceVariant.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Icon(
                Icons.select_all_rounded,
                color: colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Include all fields',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Switch(
                value: _includeAllFields,
                onChanged: (value) {
                  setState(() {
                    _includeAllFields = value;
                    if (_includeAllFields) {
                      _selectedFields = List.from(_availableFields);
                    }
                  });
                },
                activeColor: colorScheme.primary,
              ),
            ],
          ),
        ),

        if (!_includeAllFields) ...[
          const SizedBox(height: 16),
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: colorScheme.surfaceVariant.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
            ),
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _availableFields.length,
              itemBuilder: (context, index) {
                final field = _availableFields[index];
                final isSelected = _selectedFields.contains(field);

                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 2),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selectedFields.remove(field);
                          } else {
                            _selectedFields.add(field);
                          }
                        });
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isSelected
                                  ? Icons.check_box_rounded
                                  : Icons.check_box_outline_blank_rounded,
                              size: 20,
                              color: isSelected
                                  ? colorScheme.primary
                                  : colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                field,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: isSelected
                                      ? colorScheme.primary
                                      : colorScheme.onSurface,
                                  fontWeight: isSelected
                                      ? FontWeight.w500
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildExportSummary(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primaryContainer.withOpacity(0.3),
            colorScheme.secondaryContainer.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withOpacity(0.1)),
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
          const SizedBox(height: 16),
          _buildSummaryItem(
            theme,
            colorScheme,
            Icons.label_rounded,
            '${widget.tags.length} tags',
            'will be exported',
          ),
          const SizedBox(height: 8),
          _buildSummaryItem(
            theme,
            colorScheme,
            Icons.folder_rounded,
            'Download folder',
            'file will be saved here',
          ),
          const SizedBox(height: 8),
          _buildSummaryItem(
            theme,
            colorScheme,
            Icons.file_present_rounded,
            _selectedFormat.toUpperCase(),
            'export format',
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
    ThemeData theme,
    ColorScheme colorScheme,
    IconData icon,
    String title,
    String subtitle,
  ) {
    return Row(
      children: [
        Icon(icon, size: 16, color: colorScheme.onSurface.withOpacity(0.7)),
        const SizedBox(width: 12),
        Expanded(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface,
                  ),
                ),
                TextSpan(
                  text: ' $subtitle',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
