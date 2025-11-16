import 'package:flutter/material.dart';

/// Base widget for multi-select action bars
/// Provides common UI structure and callbacks for actions
class MultiSelectActionBarBase extends StatelessWidget {
  final int selectedCount;
  final int totalCount;
  final VoidCallback onClose;
  final VoidCallback? onSelectAll;
  final VoidCallback? onDeselectAll;
  final VoidCallback? onExport;
  final VoidCallback? onDelete;
  final bool showExport;
  final bool showDelete;
  final String itemName; // e.g., "payments", "products", "bundles"

  const MultiSelectActionBarBase({
    Key? key,
    required this.selectedCount,
    required this.totalCount,
    required this.onClose,
    this.onSelectAll,
    this.onDeselectAll,
    this.onExport,
    this.onDelete,
    this.showExport = true,
    this.showDelete = true,
    this.itemName = 'items',
  }) : super(key: key);

  bool get isAllSelected => selectedCount == totalCount && totalCount > 0;
  bool get hasSelection => selectedCount > 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Close button
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.close),
            tooltip: 'Close multi-select',
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          ),

          const SizedBox(width: 8),

          // Selection count
          Flexible(
            child: Text(
              '$selectedCount selected',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          const SizedBox(width: 8),

          // Select All / Deselect All button
          Flexible(
            child: TextButton(
              onPressed: isAllSelected ? onDeselectAll : onSelectAll,
              child: Text(
                isAllSelected ? 'Deselect All' : 'Select All',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),

          // Action buttons
          if (hasSelection) ...[
            const SizedBox(width: 4),
            if (showDelete)
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete),
                tooltip: 'Delete selected',
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                style: IconButton.styleFrom(foregroundColor: colorScheme.error),
              ),
            if (showExport)
              IconButton(
                onPressed: onExport,
                icon: const Icon(Icons.download),
                tooltip: 'Export selected',
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                style: IconButton.styleFrom(
                  foregroundColor: hasSelection
                      ? colorScheme.primary
                      : colorScheme.onSurface.withOpacity(0.4),
                ),
              ),
          ],
        ],
      ),
    );
  }
}
