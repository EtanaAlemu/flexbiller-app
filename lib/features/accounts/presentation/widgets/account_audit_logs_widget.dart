import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/account_audit_log.dart';
import '../bloc/accounts_bloc.dart';
import '../bloc/accounts_event.dart';
import '../bloc/accounts_state.dart';

class AccountAuditLogsWidget extends StatelessWidget {
  final String accountId;

  const AccountAuditLogsWidget({Key? key, required this.accountId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccountsBloc, AccountsState>(
      builder: (context, state) {
        if (state is AccountAuditLogsLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is AccountAuditLogsFailure) {
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
                  'Failed to load audit logs',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  state.message,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<AccountsBloc>().add(LoadAccountAuditLogs(accountId));
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (state is AccountAuditLogsLoaded) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Audit Logs (${state.auditLogs.length})',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () {
                      context.read<AccountsBloc>().add(RefreshAccountAuditLogs(accountId));
                    },
                    tooltip: 'Refresh Audit Logs',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (state.auditLogs.isEmpty)
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.history_outlined,
                        size: 64,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No audit logs found',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'This account has no audit history',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: state.auditLogs.length,
                    itemBuilder: (context, index) {
                      final log = state.auditLogs[index];
                      return _buildAuditLogCard(context, log);
                    },
                  ),
                ),
            ],
          );
        }

        return const Center(child: Text('No audit log data available'));
      },
    );
  }

  Widget _buildAuditLogCard(BuildContext context, AccountAuditLog log) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getActionIcon(log.action),
                  color: _getActionColor(log.action),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    log.description,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getActionColor(log.action).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    log.action,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: _getActionColor(log.action),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.person,
                  size: 16,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
                const SizedBox(width: 4),
                Text(
                  'User: ${log.userName}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.category,
                  size: 16,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
                const SizedBox(width: 4),
                Text(
                  'Entity: ${log.entityType}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  size: 16,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
                const SizedBox(width: 4),
                Text(
                  'Time: ${_formatDateTime(log.timestamp)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
            if (log.oldValue.isNotEmpty || log.newValue.isNotEmpty) ...[
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (log.oldValue.isNotEmpty) ...[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Previous Value:',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.errorContainer.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              log.oldValue,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  if (log.newValue.isNotEmpty) ...[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'New Value:',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              log.newValue,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ],
            if (log.ipAddress != null || log.userAgent != null) ...[
              const SizedBox(height: 12),
              if (log.ipAddress != null) ...[
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'IP: ${log.ipAddress}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
              ],
              if (log.userAgent != null) ...[
                Row(
                  children: [
                    Icon(
                      Icons.computer,
                      size: 16,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'User Agent: ${log.userAgent}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  IconData _getActionIcon(String action) {
    switch (action.toUpperCase()) {
      case 'CREATE':
        return Icons.add_circle;
      case 'UPDATE':
        return Icons.edit;
      case 'DELETE':
        return Icons.delete;
      case 'LOGIN':
        return Icons.login;
      case 'LOGOUT':
        return Icons.logout;
      case 'VIEW':
        return Icons.visibility;
      case 'DOWNLOAD':
        return Icons.download;
      case 'UPLOAD':
        return Icons.upload;
      default:
        return Icons.info;
    }
  }

  Color _getActionColor(String action) {
    switch (action.toUpperCase()) {
      case 'CREATE':
        return Colors.green;
      case 'UPDATE':
        return Colors.blue;
      case 'DELETE':
        return Colors.red;
      case 'LOGIN':
        return Colors.orange;
      case 'LOGOUT':
        return Colors.grey;
      case 'VIEW':
        return Colors.purple;
      case 'DOWNLOAD':
        return Colors.teal;
      case 'UPLOAD':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
