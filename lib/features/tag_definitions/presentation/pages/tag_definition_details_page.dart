import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/tag_definitions_bloc.dart';
import '../bloc/tag_definitions_event.dart';
import '../bloc/tag_definitions_state.dart';

class TagDefinitionDetailsPage extends StatelessWidget {
  final String tagDefinitionId;

  const TagDefinitionDetailsPage({
    super.key,
    required this.tagDefinitionId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => context.read<TagDefinitionsBloc>()
        ..add(GetTagDefinitionById(tagDefinitionId)),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Tag Definition Details'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                context.read<TagDefinitionsBloc>().add(
                  GetTagDefinitionById(tagDefinitionId),
                );
              },
              tooltip: 'Refresh',
            ),
          ],
        ),
        body: BlocBuilder<TagDefinitionsBloc, TagDefinitionsState>(
          builder: (context, state) {
            if (state is SingleTagDefinitionLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is SingleTagDefinitionLoaded) {
              return _buildTagDefinitionDetails(context, state.tagDefinition);
            } else if (state is SingleTagDefinitionError) {
              return _buildErrorState(context, state.message, state.id);
            }
            return const Center(child: Text('No tag definition loaded'));
          },
        ),
      ),
    );
  }

  Widget _buildTagDefinitionDetails(BuildContext context, dynamic tagDefinition) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeaderCard(context, tagDefinition),
          const SizedBox(height: 16),
          _buildDetailsCard(context, tagDefinition),
          const SizedBox(height: 16),
          _buildObjectTypesCard(context, tagDefinition),
          const SizedBox(height: 16),
          _buildAuditLogsCard(context, tagDefinition),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context, dynamic tagDefinition) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: tagDefinition.isControlTag
                        ? Colors.red.shade600
                        : Colors.blue.shade600,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    tagDefinition.isControlTag ? 'CONTROL TAG' : 'CUSTOM TAG',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.category,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              tagDefinition.name,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            if (tagDefinition.description.isNotEmpty)
              Text(
                tagDefinition.description,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(
                    alpha: 0.7,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsCard(BuildContext context, dynamic tagDefinition) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Tag Definition Details',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDetailRow('ID', tagDefinition.id, Icons.fingerprint),
            _buildDetailRow('Type', tagDefinition.isControlTag ? 'Control Tag' : 'Custom Tag', Icons.category),
            _buildDetailRow('Name', tagDefinition.name, Icons.label),
            if (tagDefinition.description.isNotEmpty)
              _buildDetailRow('Description', tagDefinition.description, Icons.description),
          ],
        ),
      ),
    );
  }

  Widget _buildObjectTypesCard(BuildContext context, dynamic tagDefinition) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.link,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Applicable Object Types (${tagDefinition.applicableObjectTypes.length})',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (tagDefinition.applicableObjectTypes.isEmpty)
              _buildEmptyObjectTypes(context)
            else
              _buildObjectTypesList(context, tagDefinition.applicableObjectTypes),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyObjectTypes(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.3,
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(
            alpha: 0.3,
          ),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.link_off,
            size: 48,
            color: Theme.of(context).colorScheme.outline.withValues(
              alpha: 0.6,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No Object Types',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.outline.withValues(
                alpha: 0.8,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'This tag definition is not applicable to any object types',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.outline.withValues(
                alpha: 0.6,
              ),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildObjectTypesList(BuildContext context, List<String> objectTypes) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: objectTypes.map((type) => _buildObjectTypeChip(context, type)).toList(),
    );
  }

  Widget _buildObjectTypeChip(BuildContext context, String objectType) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _getObjectTypeColor(objectType),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getObjectTypeColor(objectType).withValues(
            alpha: 0.3,
          ),
        ),
      ),
      child: Text(
        objectType,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildAuditLogsCard(BuildContext context, dynamic tagDefinition) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.history,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Audit Logs (${tagDefinition.auditLogs.length})',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (tagDefinition.auditLogs.isEmpty)
              _buildEmptyAuditLogs(context)
            else
              _buildAuditLogsList(context, tagDefinition.auditLogs),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyAuditLogs(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.3,
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(
            alpha: 0.3,
          ),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.history_toggle_off,
            size: 48,
            color: Theme.of(context).colorScheme.outline.withValues(
              alpha: 0.6,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No Audit Logs',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.outline.withValues(
                alpha: 0.8,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'No audit history available for this tag definition',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.outline.withValues(
                alpha: 0.6,
              ),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAuditLogsList(BuildContext context, List<dynamic> auditLogs) {
    return Column(
      children: auditLogs.asMap().entries.map((entry) {
        final index = entry.key;
        final log = entry.value;
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(
              alpha: 0.3,
            ),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withValues(
                alpha: 0.2,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.history,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Log Entry ${index + 1}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                log.toString(),
                style: const TextStyle(fontSize: 11),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: Colors.grey.shade600,
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontFamily: 'monospace',
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message, String id) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Error loading tag definition',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Failed to load tag definition with ID: $id',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.error.withValues(
                  alpha: 0.8,
                ),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.error.withValues(
                alpha: 0.7,
              ),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              context.read<TagDefinitionsBloc>().add(
                GetTagDefinitionById(id),
              );
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Colors.white,
            ),
          ),
        ],
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
