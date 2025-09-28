import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/tag.dart';
import '../bloc/tags_bloc.dart';
import '../bloc/tags_event.dart';

class SelectableTagCardWidget extends StatelessWidget {
  final Tag tag;
  final bool isSelected;
  final bool isMultiSelectMode;

  const SelectableTagCardWidget({
    super.key,
    required this.tag,
    required this.isSelected,
    required this.isMultiSelectMode,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected
            ? BorderSide(color: theme.colorScheme.primary, width: 2)
            : BorderSide(
                color: theme.colorScheme.outline.withOpacity(0.1),
                width: 1,
              ),
      ),
      child: GestureDetector(
        onTap: () {
          if (isMultiSelectMode) {
            _toggleSelection(context);
          } else {
            _showTagDetails(context);
          }
        },
        onLongPress: () {
          if (!isMultiSelectMode) {
            _enableMultiSelectModeAndSelect(context);
          }
        },
        child: InkWell(
          onTap: () {
            if (isMultiSelectMode) {
              _toggleSelection(context);
            } else {
              _showTagDetails(context);
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: isSelected
                  ? theme.colorScheme.primaryContainer.withOpacity(0.1)
                  : theme.colorScheme.surface,
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // Selection checkbox
                  if (isMultiSelectMode)
                    Container(
                      margin: const EdgeInsets.only(right: 12.0),
                      child: Checkbox(
                        value: isSelected,
                        onChanged: (value) => _toggleSelection(context),
                        activeColor: theme.colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  // Tag icon
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: _getObjectTypeColor(tag.objectType),
                    child: Icon(Icons.label, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  // Tag details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tag.tagDefinitionName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${tag.objectType} • ${tag.objectId.substring(0, 8)}...',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  // Object type badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getObjectTypeColor(
                        tag.objectType,
                      ).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      tag.objectType,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: _getObjectTypeColor(tag.objectType),
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getObjectTypeColor(String objectType) {
    switch (objectType.toUpperCase()) {
      case 'ACCOUNT':
        return Colors.blue;
      case 'SUBSCRIPTION':
        return Colors.green;
      case 'INVOICE':
        return Colors.orange;
      case 'PAYMENT':
        return Colors.purple;
      case 'USER':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  void _toggleSelection(BuildContext context) {
    if (isSelected) {
      context.read<TagsBloc>().add(DeselectTag(tag));
    } else {
      context.read<TagsBloc>().add(SelectTag(tag));
    }
  }

  void _enableMultiSelectModeAndSelect(BuildContext context) {
    // Provide haptic feedback for long press
    HapticFeedback.mediumImpact();

    // Enable multi-select mode and select the tag in one event
    context.read<TagsBloc>().add(EnableMultiSelectModeAndSelect(tag));
  }

  void _showTagDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(tag.tagDefinitionName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Tag ID', tag.tagId),
            _buildDetailRow('Object Type', tag.objectType),
            _buildDetailRow('Object ID', tag.objectId),
            _buildDetailRow('Definition ID', tag.tagDefinitionId),
            _buildDetailRow('Audit Logs', '${tag.auditLogs.length}'),
          ],
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontFamily: 'monospace')),
          ),
        ],
      ),
    );
  }
}
