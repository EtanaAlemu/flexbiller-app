import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../bloc/subscriptions_bloc.dart';
import '../bloc/subscriptions_event.dart';
import '../bloc/subscriptions_state.dart';
import '../../domain/entities/subscription_audit_log.dart';

class SubscriptionAuditLogsDemoPage extends StatefulWidget {
  const SubscriptionAuditLogsDemoPage({super.key});

  @override
  State<SubscriptionAuditLogsDemoPage> createState() =>
      _SubscriptionAuditLogsDemoPageState();
}

class _SubscriptionAuditLogsDemoPageState
    extends State<SubscriptionAuditLogsDemoPage> {
  final TextEditingController _subscriptionIdController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _subscriptionIdController.text = '41b74b4b-4a19-4a5c-9be7-20b805e08c14';
  }

  @override
  void dispose() {
    _subscriptionIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GetIt.instance<SubscriptionsBloc>(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Subscription Audit Logs Demo')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'This demo allows you to retrieve audit logs with history for a subscription.',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _subscriptionIdController,
                  decoration: const InputDecoration(
                    labelText: 'Subscription ID',
                    border: OutlineInputBorder(),
                    hintText: 'e.g., 41b74b4b-4a19-4a5c-9be7-20b805e08c14',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a subscription ID';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _getSubscriptionAuditLogs,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Get Subscription Audit Logs'),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: BlocBuilder<SubscriptionsBloc, SubscriptionsState>(
                    builder: (context, state) {
                      if (state is GetSubscriptionAuditLogsWithHistoryLoading) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (state is GetSubscriptionAuditLogsWithHistorySuccess) {
                        return _buildAuditLogsList(state.auditLogs);
                      } else if (state is GetSubscriptionAuditLogsWithHistoryError) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.error_outline,
                                color: Colors.red,
                                size: 64,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Error: ${state.message}',
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 16,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      }
                      return const Center(
                        child: Text(
                          'Enter a subscription ID and click the button to retrieve audit logs.',
                          style: TextStyle(fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _getSubscriptionAuditLogs() {
    if (_formKey.currentState!.validate()) {
      final subscriptionId = _subscriptionIdController.text.trim();
      context.read<SubscriptionsBloc>().add(GetSubscriptionAuditLogsWithHistory(
        subscriptionId,
      ));
    }
  }

  Widget _buildAuditLogsList(List<SubscriptionAuditLog> auditLogs) {
    if (auditLogs.isEmpty) {
      return const Center(
        child: Text(
          'No audit logs found for this subscription.',
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      itemCount: auditLogs.length,
      itemBuilder: (context, index) {
        final auditLog = auditLogs[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ExpansionTile(
            title: Text(
              '${auditLog.changeType ?? 'N/A'} - ${auditLog.objectType ?? 'N/A'}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              'Changed by: ${auditLog.changedBy ?? 'N/A'} on ${_formatDate(auditLog.changeDate)}',
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow('Change Type', auditLog.changeType),
                    _buildInfoRow('Change Date', _formatDate(auditLog.changeDate)),
                    _buildInfoRow('Object Type', auditLog.objectType),
                    _buildInfoRow('Object ID', auditLog.objectId),
                    _buildInfoRow('Changed By', auditLog.changedBy),
                    _buildInfoRow('Reason Code', auditLog.reasonCode),
                    _buildInfoRow('Comments', auditLog.comments),
                    _buildInfoRow('User Token', auditLog.userToken),
                    if (auditLog.history != null) ...[
                      const Divider(),
                      const Text(
                        'History Details:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildHistoryInfo(auditLog.history!),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value ?? 'N/A'),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryInfo(SubscriptionAuditHistory history) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow('ID', history.id),
        _buildInfoRow('Created Date', _formatDate(history.createdDate)),
        _buildInfoRow('Updated Date', _formatDate(history.updatedDate)),
        _buildInfoRow('Record ID', history.recordId?.toString()),
        _buildInfoRow('Account Record ID', history.accountRecordId?.toString()),
        _buildInfoRow('Tenant Record ID', history.tenantRecordId?.toString()),
        _buildInfoRow('Bundle ID', history.bundleId),
        _buildInfoRow('External Key', history.externalKey),
        _buildInfoRow('Category', history.category),
        _buildInfoRow('Start Date', _formatDate(history.startDate)),
        _buildInfoRow('Bundle Start Date', _formatDate(history.bundleStartDate)),
        _buildInfoRow('Charged Through Date', _formatDate(history.chargedThroughDate)),
        _buildInfoRow('Migrated', history.migrated?.toString()),
        _buildInfoRow('Table Name', history.tableName),
        _buildInfoRow('History Table Name', history.historyTableName),
      ],
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}:${date.second.toString().padLeft(2, '0')}';
  }
}
