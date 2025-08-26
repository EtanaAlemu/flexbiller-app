import 'package:flutter/material.dart';
import '../../domain/entities/tag_definition.dart';
import '../pages/tag_definition_details_page.dart';

class TagDefinitionCardWidget extends StatelessWidget {
  final TagDefinition tagDefinition;
  final VoidCallback? onTap;

  const TagDefinitionCardWidget({
    super.key,
    required this.tagDefinition,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: InkWell(
        onTap: onTap ?? () => _navigateToDetails(context),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
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
                  const Spacer(),
                  Icon(
                    Icons.category,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                tagDefinition.name,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              if (tagDefinition.description.isNotEmpty) ...[
                Text(
                  tagDefinition.description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(
                      alpha: 0.7,
                    ),
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
              ],
              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      'ID',
                      tagDefinition.id,
                      Icons.fingerprint,
                    ),
                  ),
                  Expanded(
                    child: _buildInfoItem(
                      'Object Types',
                      '${tagDefinition.applicableObjectTypes.length}',
                      Icons.link,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildObjectTypesChips(context, tagDefinition.applicableObjectTypes),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      'Audit Logs',
                      '${tagDefinition.auditLogs.length}',
                      Icons.history,
                    ),
                  ),
                  Expanded(
                    child: _buildInfoItem(
                      'Type',
                      tagDefinition.isControlTag ? 'Control Tag' : 'Custom Tag',
                      Icons.info,
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

  void _navigateToDetails(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TagDefinitionDetailsPage(
          tagDefinitionId: tagDefinition.id,
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
            Icon(
              icon,
              size: 14,
              color: Colors.grey.shade600,
            ),
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

  Widget _buildObjectTypesChips(BuildContext context, List<String> objectTypes) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: objectTypes.map((type) => _buildObjectTypeChip(context, type)).toList(),
    );
  }

  Widget _buildObjectTypeChip(BuildContext context, String objectType) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getObjectTypeColor(objectType),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getObjectTypeColor(objectType).withValues(
            alpha: 0.3,
          ),
        ),
      ),
      child: Text(
        objectType,
        style: const TextStyle(
          fontSize: 10,
          color: Colors.white,
          fontWeight: FontWeight.w500,
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
      case 'BUNDLE':
        return Colors.purple;
      case 'PAYMENT':
        return Colors.teal;
      case 'USER':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }
}
