import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../bloc/tag_definitions_bloc.dart';
import '../bloc/tag_definitions_event.dart';
import '../bloc/tag_definitions_state.dart';
import '../widgets/delete_tag_definition_dialog.dart';

class DeleteTagDefinitionDemoPage extends StatefulWidget {
  const DeleteTagDefinitionDemoPage({super.key});

  @override
  State<DeleteTagDefinitionDemoPage> createState() =>
      _DeleteTagDefinitionDemoPageState();
}

class _DeleteTagDefinitionDemoPageState
    extends State<DeleteTagDefinitionDemoPage> {
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
        appBar: AppBar(title: const Text('Delete Tag Definition Demo')),
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
                              Icons.delete_forever,
                              color: Theme.of(context).colorScheme.error,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Delete Tag Definition',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'This demo allows you to delete a specific tag definition by its ID:',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 8),
                        _buildFeatureItem('• Enter a tag definition ID'),
                        _buildFeatureItem('• View tag definition details before deletion'),
                        _buildFeatureItem('• Confirm deletion with warning dialog'),
                        _buildFeatureItem('• Handle success and error states'),
                        _buildFeatureItem('• Refresh tag definitions list after deletion'),
                        _buildFeatureItem('• ⚠️ This action cannot be undone'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _idController,
                  decoration: const InputDecoration(
                    labelText: 'Tag Definition ID',
                    hintText: 'Enter the tag definition ID to delete',
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
                  onPressed: _deleteTagDefinition,
                  icon: const Icon(Icons.delete_forever),
                  label: const Text('Delete Tag Definition'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Theme.of(context).colorScheme.error,
                    foregroundColor: Colors.white,
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
                  'premium_customer (Custom Tag)',
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
                    color: Theme.of(context).colorScheme.errorContainer.withValues(
                      alpha: 0.1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.error.withValues(
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
                            Icons.warning_amber_rounded,
                            color: Theme.of(context).colorScheme.error,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '⚠️ Important Warning:',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '• Deleting a tag definition is a permanent action\n'
                        '• This will remove the tag definition from the system\n'
                        '• Any existing tags using this definition may be affected\n'
                        '• Control tags may have special restrictions\n'
                        '• Consider reviewing audit logs before deletion',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.error.withValues(
                            alpha: 0.8,
                          ),
                        ),
                      ),
                    ],
                  ),
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
                          'DELETE /api/tagDefinitions/{id}',
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Permanently removes a tag definition from the system. Returns 200 or 204 on successful deletion.',
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

  void _deleteTagDefinition() {
    if (_formKey.currentState!.validate()) {
      final id = _idController.text.trim();
      
      // First, get the tag definition details to show in the confirmation dialog
      context.read<TagDefinitionsBloc>().add(GetTagDefinitionById(id));
      
      showDialog(
        context: context,
        builder: (context) => BlocBuilder<TagDefinitionsBloc, TagDefinitionsState>(
          builder: (context, state) {
            if (state is SingleTagDefinitionLoading) {
              return const AlertDialog(
                content: Center(child: CircularProgressIndicator()),
              );
            } else if (state is SingleTagDefinitionLoaded) {
              return DeleteTagDefinitionDialog(
                tagDefinition: state.tagDefinition,
                onConfirm: () => _confirmDelete(id),
              );
            } else if (state is SingleTagDefinitionError) {
              return AlertDialog(
                title: const Text('Error'),
                content: Text('Failed to load tag definition: ${state.message}'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('OK'),
                  ),
                ],
              );
            }
            return const AlertDialog(
              content: Text('Loading tag definition...'),
            );
          },
        ),
      );
    }
  }

  void _confirmDelete(String id) {
    context.read<TagDefinitionsBloc>().add(DeleteTagDefinition(id));
    
    showDialog(
      context: context,
      builder: (context) => BlocBuilder<TagDefinitionsBloc, TagDefinitionsState>(
        builder: (context, state) {
          if (state is DeleteTagDefinitionLoading) {
            return const AlertDialog(
              content: Center(child: CircularProgressIndicator()),
            );
          } else if (state is DeleteTagDefinitionSuccess) {
            return AlertDialog(
              title: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  const Text('Success!'),
                ],
              ),
              content: Text(
                'Tag definition with ID "${state.deletedId}" has been successfully deleted.',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          } else if (state is DeleteTagDefinitionError) {
            return AlertDialog(
              title: const Text('Error'),
              content: Text('Failed to delete tag definition: ${state.message}'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            );
          }
          return const AlertDialog(
            content: Text('Processing deletion...'),
          );
        },
      ),
    );
  }
}
