import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/tag.dart';
import '../bloc/tags_bloc.dart';
import '../bloc/tags_event.dart';
import '../bloc/tags_state.dart';
import 'export_tags_dialog.dart';

class TagsMultiSelectActionBar extends StatelessWidget {
  final List<Tag> selectedTags;

  const TagsMultiSelectActionBar({super.key, required this.selectedTags});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedCount = selectedTags.length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
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
            icon: const Icon(Icons.close, color: Colors.white),
            tooltip: 'Exit selection mode',
          ),
          const SizedBox(width: 8),
          // Selection count
          Text(
            '$selectedCount selected',
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          // Action buttons
          if (selectedCount > 0) ...[
            // Select All button
            TextButton.icon(
              onPressed: () => _selectAllTags(context),
              icon: const Icon(Icons.select_all, color: Colors.white),
              label: const Text(
                'Select All',
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(width: 8),
            // Deselect All button
            TextButton.icon(
              onPressed: () {
                context.read<TagsBloc>().add(DeselectAllTags());
              },
              icon: const Icon(Icons.clear_all, color: Colors.white),
              label: const Text(
                'Deselect All',
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(width: 8),
            // Export button
            TextButton.icon(
              onPressed: () {
                _exportSelectedTags(context);
              },
              icon: const Icon(Icons.download, color: Colors.white),
              label: const Text(
                'Export',
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(width: 8),
            // Delete button
            TextButton.icon(
              onPressed: () {
                _showDeleteConfirmation(context);
              },
              icon: const Icon(Icons.delete, color: Colors.white),
              label: const Text(
                'Delete',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _exportSelectedTags(BuildContext context) {
    if (selectedTags.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No tags selected for export'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    _showExportDialog(context, selectedTags);
  }

  void _showExportDialog(BuildContext context, List<Tag> tags) {
    showDialog(
      context: context,
      builder: (context) => ExportTagsDialog(tags: tags),
    ).then((result) {
      if (result != null && result is Map<String, dynamic>) {
        final format = result['format'] as String;
        context.read<TagsBloc>().add(
          ExportSelectedTags(tags: tags, format: format),
        );
      }
    });
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Tags'),
        content: Text(
          'Are you sure you want to delete ${selectedTags.length} selected tags? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteSelectedTags(context);
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No tags selected for deletion'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    context.read<TagsBloc>().add(DeleteSelectedTags(tags: selectedTags));
  }

  void _selectAllTags(BuildContext context) {
    // Get all tags from the current state
    final tagsBloc = context.read<TagsBloc>();
    final state = tagsBloc.state;

    List<Tag> allTags = [];

    if (state is TagsWithSelection) {
      allTags = state.tags;
    }

    if (allTags.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No tags available to select'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    context.read<TagsBloc>().add(SelectAllTags(tags: allTags));
  }
}
