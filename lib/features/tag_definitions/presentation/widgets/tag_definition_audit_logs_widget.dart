import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/tag_definition_audit_log.dart';

class TagDefinitionAuditLogsWidget extends StatelessWidget {
  final List<TagDefinitionAuditLog> auditLogs;
  final String tagDefinitionId;

  const TagDefinitionAuditLogsWidget({
    super.key,
    required this.auditLogs,
    required this.tagDefinitionId,
  });

  @override
  Widget build(BuildContext context) {
    if (auditLogs.isEmpty) {
      return _buildEmptyState(context);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context),
        const SizedBox(height: 16),
        _buildAuditLogsList(context),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.history,
          color: Theme.of(context).colorScheme.primary,
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          'Audit Logs with History (${auditLogs.length})',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.history_toggle_off,
            size: 64,
            color: Theme.of(context).colorScheme.outline.withValues(
              alpha: 0.6,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No Audit Logs',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).colorScheme.outline.withValues(
                alpha: 0.8,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No audit history available for this tag definition',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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

  Widget _buildAuditLogsList(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: auditLogs.length,
      itemBuilder: (context, index) {
        final auditLog = auditLogs[index];
        return _buildAuditLogCard(context, auditLog, index);
      },
    );
  }

  Widget _buildAuditLogCard(BuildContext context, TagDefinitionAuditLog auditLog, int index) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM dd, yyyy HH:mm:ss');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: _buildChangeTypeIcon(auditLog.changeType),
        title: Text(
          '${auditLog.changeType} - ${dateFormat.format(auditLog.changeDate)}',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          'Changed by: ${auditLog.changedBy}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(
              alpha: 0.7,
            ),
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAuditLogDetails(context, auditLog),
                const SizedBox(height: 16),
                _buildHistorySection(context, auditLog.history),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChangeTypeIcon(String changeType) {
    IconData iconData;
    Color iconColor;

    switch (changeType.toUpperCase()) {
      case 'INSERT':
        iconData = Icons.add_circle;
        iconColor = Colors.green;
        break;
      case 'UPDATE':
        iconData = Icons.edit;
        iconColor = Colors.blue;
        break;
      case 'DELETE':
        iconData = Icons.delete;
        iconColor = Colors.red;
        break;
      default:
        iconData = Icons.info;
        iconColor = Colors.grey;
    }

    return Icon(iconData, color: iconColor, size: 24);
  }

  Widget _buildAuditLogDetails(BuildContext context, TagDefinitionAuditLog auditLog) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM dd, yyyy HH:mm:ss');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Change Details',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        _buildDetailRow('Change Type', auditLog.changeType, Icons.category),
        _buildDetailRow('Change Date', dateFormat.format(auditLog.changeDate), Icons.schedule),
        _buildDetailRow('Object Type', auditLog.objectType, Icons.type_specimen),
        _buildDetailRow('Object ID', auditLog.objectId, Icons.fingerprint),
        _buildDetailRow('Changed By', auditLog.changedBy, Icons.person),
        if (auditLog.reasonCode != null)
          _buildDetailRow('Reason Code', auditLog.reasonCode!, Icons.help_outline),
        if (auditLog.comments != null)
          _buildDetailRow('Comments', auditLog.comments!, Icons.comment),
        _buildDetailRow('User Token', auditLog.userToken, Icons.vpn_key),
      ],
    );
  }

  Widget _buildHistorySection(BuildContext context, TagDefinitionHistory history) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM dd, yyyy HH:mm:ss');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Historical Data',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.secondary,
          ),
        ),
        const SizedBox(height: 8),
        _buildDetailRow('Record ID', history.recordId.toString(), Icons.numbers),
        _buildDetailRow('Account Record ID', history.accountRecordId.toString(), Icons.account_balance),
        _buildDetailRow('Tenant Record ID', history.tenantRecordId.toString(), Icons.business),
        _buildDetailRow('Name', history.name, Icons.label),
        _buildDetailRow('Applicable Object Types', history.applicableObjectTypes, Icons.link),
        _buildDetailRow('Description', history.description, Icons.description),
        _buildDetailRow('Is Active', history.isActive.toString(), Icons.check_circle),
        _buildDetailRow('Table Name', history.tableName, Icons.table_chart),
        _buildDetailRow('History Table Name', history.historyTableName, Icons.history),
        if (history.id != null)
          _buildDetailRow('History ID', history.id!, Icons.fingerprint),
        _buildDetailRow('Created Date', dateFormat.format(history.createdDate), Icons.create),
        _buildDetailRow('Updated Date', dateFormat.format(history.updatedDate), Icons.update),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 16,
            color: Colors.grey.shade600,
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 140,
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
}
