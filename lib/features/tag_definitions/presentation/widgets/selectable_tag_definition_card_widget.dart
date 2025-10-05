import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/tag_definitions_bloc.dart';
import '../bloc/tag_definitions_event.dart';
import '../pages/tag_definition_details_page.dart';

class SelectableTagDefinitionCardWidget extends StatelessWidget {
  final dynamic tagDefinition;
  final bool isSelected;
  final bool isMultiSelectMode;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const SelectableTagDefinitionCardWidget({
    super.key,
    required this.tagDefinition,
    this.isSelected = false,
    this.isMultiSelectMode = false,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: GestureDetector(
        onTap: isMultiSelectMode
            ? () => _toggleSelection(context)
            : (onTap ?? () => _navigateToDetails(context)),
        onLongPress: () => _enableMultiSelectModeAndSelect(context),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: isSelected && isMultiSelectMode
                ? Border.all(color: theme.colorScheme.primary, width: 2)
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                if (isMultiSelectMode) ...[
                  Checkbox(
                    value: isSelected,
                    onChanged: (_) => _toggleSelection(context),
                    activeColor: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                ],
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: tagDefinition.isControlTag
                        ? Colors.red.shade600
                        : Colors.blue.shade600,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    tagDefinition.isControlTag ? 'CONTROL' : 'CUSTOM',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    tagDefinition.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (!isMultiSelectMode) ...[
                  Icon(
                    Icons.arrow_forward_ios,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                    size: 16,
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'delete') {
                        _showDeleteDialog(context);
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem<String>(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete_outline,
                              color: theme.colorScheme.error,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            const Text('Delete'),
                          ],
                        ),
                      ),
                    ],
                    icon: Icon(
                      Icons.more_vert,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      size: 20,
                    ),
                    tooltip: 'More options',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _enableMultiSelectModeAndSelect(BuildContext context) {
    print('🔍 Widget: Long press detected for tag: ${tagDefinition.name}');
    HapticFeedback.mediumImpact();
    context.read<TagDefinitionsBloc>().add(
      EnableMultiSelectModeAndSelect(tagDefinition),
    );
  }

  void _toggleSelection(BuildContext context) {
    print(
      '🔍 Widget: Toggle selection for tag: ${tagDefinition.name}, isSelected: $isSelected',
    );
    if (isSelected) {
      print('🔍 Widget: Deselecting tag');
      context.read<TagDefinitionsBloc>().add(
        DeselectTagDefinition(tagDefinition),
      );
    } else {
      print('🔍 Widget: Selecting tag');
      context.read<TagDefinitionsBloc>().add(
        SelectTagDefinition(tagDefinition),
      );
    }
  }

  void _navigateToDetails(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            TagDefinitionDetailsPage(tagDefinitionId: tagDefinition.id),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    final bloc = context.read<TagDefinitionsBloc>();
    showDialog(
      context: context,
      builder: (dialogContext) => DeleteTagDefinitionDialog(
        tagDefinition: tagDefinition,
        onConfirm: () {
          bloc.add(DeleteTagDefinition(tagDefinition.id));
        },
      ),
    );
  }
}

class DeleteTagDefinitionDialog extends StatelessWidget {
  final dynamic tagDefinition;
  final VoidCallback? onConfirm;

  const DeleteTagDefinitionDialog({
    super.key,
    required this.tagDefinition,
    this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text('Delete Tag Definition'),
      content: Text(
        'Are you sure you want to delete "${tagDefinition.name}"? This action cannot be undone.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.of(context).pop();
            onConfirm?.call();
          },
          style: FilledButton.styleFrom(
            backgroundColor: theme.colorScheme.error,
          ),
          child: const Text('Delete'),
        ),
      ],
    );
  }
}
