import 'package:flutter/material.dart';
import '../../domain/entities/tag.dart';

class TagCardWidget extends StatelessWidget {
  final Tag tag;
  final VoidCallback? onTap;

  const TagCardWidget({
    super.key,
    required this.tag,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: InkWell(
        onTap: onTap,
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
                  Icon(
                    Icons.label,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
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
}
