import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../bloc/tag_definitions_bloc.dart';
import '../bloc/tag_definitions_event.dart';
import '../bloc/tag_definitions_state.dart';
import '../widgets/tag_definition_audit_logs_widget.dart';

class GetTagDefinitionAuditLogsDemoPage extends StatefulWidget {
  const GetTagDefinitionAuditLogsDemoPage({super.key});

  @override
  State<GetTagDefinitionAuditLogsDemoPage> createState() =>
      _GetTagDefinitionAuditLogsDemoPageState();
}

class _GetTagDefinitionAuditLogsDemoPageState
    extends State<GetTagDefinitionAuditLogsDemoPage> {
  final TextEditingController _idController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _idController.text = 'c85e37ac-aaca-43fb-8d7c-c641c20f825d';
  }

  @override
  void dispose() {
    _idController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GetIt.instance<TagDefinitionsBloc>(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Get Tag Definition Audit Logs Demo')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
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
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Get Tag Definition Audit Logs with History',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'This demo allows you to retrieve detailed audit logs with history for a specific tag definition:',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 8),
                        _buildFeatureItem('• Enter a tag definition ID'),
                        _buildFeatureItem('• View comprehensive audit trail'),
                        _buildFeatureItem('• See detailed change history'),
                        _buildFeatureItem('• Track INSERT, UPDATE, DELETE operations'),
                        _buildFeatureItem('• View historical data snapshots'),
                        _buildFeatureItem('• Handle errors and loading states'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _idController,
                  decoration: const InputDecoration(
                    labelText: 'Tag Definition ID',
                    hintText: 'Enter the tag definition ID to retrieve audit logs',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.fingerprint),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a tag definition ID';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _getAuditLogs,
                  icon: const Icon(Icons.history),
                  label: const Text('Get Audit Logs'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                Text(
                  'Sample Tag Definition IDs for testing:',
                  style: Theme.of(context).textTheme.titleSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                _buildSampleId(
                  'c85e37ac-aaca-43fb-8d7c-c641c20f825d',
                  'premium_customer (Has audit logs)',
                ),
                _buildSampleId(
                  '00000000-0000-0000-0000-000000000009',
                  'AUTO_INVOICING_REUSE_DRAFT (Control Tag)',
                ),
                _buildSampleId(
                  '00000000-0000-0000-0000-000000000001',
                  'AUTO_PAY_OFF (Control Tag)',
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer.withValues(
                      alpha: 0.1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary.withValues(
                        alpha: 0.3,
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.api,
                            color: Theme.of(context).colorScheme.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'API Endpoint:',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Text(
                          'GET /api/tagDefinitions/{id}/auditLogsWithHistory',
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Returns detailed audit logs with complete history for a specific tag definition, including all changes (INSERT, UPDATE, DELETE) with timestamps, user information, and historical data snapshots.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(text, style: const TextStyle(fontSize: 14)),
    );
  }

  Widget _buildSampleId(String id, String description) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          setState(() {
            _idController.text = id;
          });
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                id,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _getAuditLogs() {
    if (_formKey.currentState!.validate()) {
      final id = _idController.text.trim();
      context.read<TagDefinitionsBloc>().add(GetTagDefinitionAuditLogsWithHistory(id));
      
      showDialog(
        context: context,
        builder: (context) => BlocBuilder<TagDefinitionsBloc, TagDefinitionsState>(
          builder: (context, state) {
            if (state is AuditLogsWithHistoryLoading) {
              return const AlertDialog(
                content: Center(child: CircularProgressIndicator()),
              );
            } else if (state is AuditLogsWithHistoryLoaded) {
              return Dialog(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.95,
                  height: MediaQuery.of(context).size.height * 0.9,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'Audit Logs with History',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                      const Divider(),
                      Expanded(
                        child: SingleChildScrollView(
                          child: TagDefinitionAuditLogsWidget(
                            auditLogs: state.auditLogs,
                            tagDefinitionId: state.tagDefinitionId,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            } else if (state is AuditLogsWithHistoryError) {
              return AlertDialog(
                title: const Text('Error'),
                content: Text('Failed to load audit logs: ${state.message}'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('OK'),
                  ),
                ],
              );
            }
            return const AlertDialog(
              content: Text('No audit logs loaded'),
            );
          },
        ),
      );
    }
  }
}
