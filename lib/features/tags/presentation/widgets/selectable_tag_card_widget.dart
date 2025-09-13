import 'package:flutter/material.dart';
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
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      elevation: isSelected ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: isSelected
            ? BorderSide(color: theme.colorScheme.primary, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
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
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
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
                  // Object type badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getObjectTypeColor(tag.objectType),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      tag.objectType,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.label, color: theme.colorScheme.primary, size: 20),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                tag.tagDefinitionName,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      'Tag ID',
                      tag.tagId,
                      Icons.fingerprint,
                    ),
                  ),
                  Expanded(
                    child: _buildInfoItem(
                      'Object ID',
                      tag.objectId,
                      Icons.link,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      'Definition ID',
                      tag.tagDefinitionId,
                      Icons.category,
                    ),
                  ),
                  Expanded(
                    child: _buildInfoItem(
                      'Audit Logs',
                      '${tag.auditLogs.length}',
                      Icons.history,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: Colors.grey.shade600),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            fontFamily: 'monospace',
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
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
    context.read<TagsBloc>().add(EnableMultiSelectMode());
    // Add a small delay to ensure the multi-select mode is enabled
    Future.delayed(const Duration(milliseconds: 100), () {
      context.read<TagsBloc>().add(SelectTag(tag));
    });
  }

  void _showTagDetails(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Tag: ${tag.tagDefinitionName}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
