import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/tag.dart';
import '../bloc/tags_bloc.dart';
import '../bloc/tags_event.dart';
import 'export_tags_dialog.dart';
import 'package:flexbiller_app/core/widgets/custom_snackbar.dart';

class TagsMultiSelectActionBar extends StatelessWidget {
  final List<Tag> selectedTags;
  final bool isAllSelected;
  final List<Tag> allTags;

  const TagsMultiSelectActionBar({
    super.key,
    required this.selectedTags,
    this.isAllSelected = false,
    this.allTags = const [],
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedCount = selectedTags.length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.onSurface.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Close button
          IconButton(
            onPressed: () {
              context.read<TagsBloc>().add(DisableMultiSelectMode());
            },
            icon: const Icon(Icons.close),
            tooltip: 'Exit multi-select',
            style: IconButton.styleFrom(
              foregroundColor: theme.colorScheme.onSurface,
            ),
          ),

          const SizedBox(width: 8),

          // Selection count
          Text(
            '$selectedCount selected',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),

          const Spacer(),

          // Select all / Deselect all button
          IconButton(
            onPressed: isAllSelected
                ? () => context.read<TagsBloc>().add(DeselectAllTags())
                : () => _selectAllTags(context),
            icon: Icon(
              isAllSelected ? Icons.check_box : Icons.check_box_outline_blank,
            ),
            tooltip: isAllSelected ? 'Deselect all' : 'Select all',
            style: IconButton.styleFrom(
              foregroundColor: isAllSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface,
            ),
          ),

          // Export button
          IconButton(
            onPressed: selectedTags.isNotEmpty
                ? () => _exportSelectedTags(context)
                : null,
            icon: const Icon(Icons.download),
            tooltip: 'Export selected',
            style: IconButton.styleFrom(
              foregroundColor: selectedTags.isNotEmpty
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withOpacity(0.4),
            ),
          ),

          // Delete button
          IconButton(
            onPressed: selectedTags.isNotEmpty
                ? () => _showDeleteConfirmation(context)
                : null,
            icon: const Icon(Icons.delete),
            tooltip: 'Delete selected',
            style: IconButton.styleFrom(
              foregroundColor: theme.colorScheme.error,
            ),
          ),
        ],
      ),
    );
  }

  void _exportSelectedTags(BuildContext context) {
    if (selectedTags.isEmpty) {
      CustomSnackBar.showWarning(
        context,
        message: 'No tags selected for export',
      );
      return;
    }

    _showExportDialog(context);
  }

  Future<void> _showExportDialog(BuildContext context) async {
    final result = await showDialog(
      context: context,
      builder: (context) => ExportTagsDialog(tags: selectedTags),
    );
    if (result != null) {
      final selectedFormat = result['format'] as String;
      await _performExport(context, selectedFormat);
    }
  }

  Future<void> _performExport(BuildContext context, String format) async {
    // Dispatch export event to BLoC - the BLoC will handle the export and emit states
    context.read<TagsBloc>().add(
      ExportSelectedTags(tags: selectedTags, format: format),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    // Capture the original context that has access to TagsBloc
    final originalContext = context;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Tags'),
        content: Text(
          'Are you sure you want to delete ${selectedTags.length} selected tags? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _deleteSelectedTags(originalContext);
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

  void _deleteSelectedTags(BuildContext context) {
    if (selectedTags.isEmpty) {
      CustomSnackBar.showWarning(
        context,
        message: 'No tags selected for deletion',
      );
      return;
    }

    context.read<TagsBloc>().add(DeleteSelectedTags(tags: selectedTags));
  }

  void _selectAllTags(BuildContext context) {
    if (allTags.isEmpty) {
      CustomSnackBar.showWarning(
        context,
        message: 'No tags available to select',
      );
      return;
    }

    context.read<TagsBloc>().add(SelectAllTags(tags: allTags));
  }
}
