import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/tag_definition.dart';
import '../bloc/tag_definitions_bloc.dart';
import '../bloc/tag_definitions_event.dart';
import 'export_tag_definitions_dialog.dart';

class TagDefinitionsMultiSelectActionBar extends StatelessWidget {
  final List<TagDefinition> selectedTagDefinitions;
  final bool isAllSelected;
  final List<TagDefinition> allTagDefinitions;
  final TagDefinitionsBloc bloc;

  const TagDefinitionsMultiSelectActionBar({
    super.key,
    required this.selectedTagDefinitions,
    required this.isAllSelected,
    required this.allTagDefinitions,
    required this.bloc,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedCount = selectedTagDefinitions.length;

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
          IconButton(
            onPressed: () {
              context.read<TagDefinitionsBloc>().add(DisableMultiSelectMode());
            },
            icon: const Icon(Icons.close),
            tooltip: 'Exit multi-select',
            style: IconButton.styleFrom(
              foregroundColor: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$selectedCount selected',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: isAllSelected
                ? () => context.read<TagDefinitionsBloc>().add(
                    DeselectAllTagDefinitions(),
                  )
                : () => _selectAllTagDefinitions(context),
            icon: Icon(
              isAllSelected ? Icons.check_box : Icons.check_box_outline_blank,
            ),
            tooltip: isAllSelected ? 'Deselect all' : 'Select all',
            style: IconButton.styleFrom(
              foregroundColor: isAllSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withOpacity(0.4),
            ),
          ),
          IconButton(
            onPressed: selectedTagDefinitions.isNotEmpty
                ? () => _exportSelectedTagDefinitions(context)
                : null,
            icon: const Icon(Icons.download),
            tooltip: 'Export selected',
            style: IconButton.styleFrom(
              foregroundColor: selectedTagDefinitions.isNotEmpty
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withOpacity(0.4),
            ),
          ),
          IconButton(
            onPressed: selectedTagDefinitions.isNotEmpty
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

  void _selectAllTagDefinitions(BuildContext context) {
    context.read<TagDefinitionsBloc>().add(SelectAllTagDefinitions());
  }

  void _exportSelectedTagDefinitions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ExportTagDefinitionsDialog(
        selectedTagDefinitions: selectedTagDefinitions,
      ),
    ).then((result) async {
      if (result != null) {
        final selectedFormat = result['format'] as String;
        await _performExport(context, selectedFormat);
      }
    });
  }

  Future<void> _performExport(BuildContext context, String format) async {
    // Dispatch export event to BLoC - the BLoC will handle the export and emit states
    context.read<TagDefinitionsBloc>().add(
      ExportSelectedTagDefinitions(format),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Selected Tag Definitions'),
        content: Text(
          'Are you sure you want to delete ${selectedTagDefinitions.length} selected tag definitions? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteSelectedTagDefinitions(context);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _deleteSelectedTagDefinitions(BuildContext context) {
    bloc.add(DeleteSelectedTagDefinitions());
  }
}
